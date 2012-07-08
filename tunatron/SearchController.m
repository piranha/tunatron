//
//  SearchController.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/2/12.
//  Copyright (c) 2012 Witty Bullet. All rights reserved.
//

#import "SearchController.h"
#import "iTunes.h"
#import "Track.h"
#import "ScoredTrack.h"

@implementation SearchController
@synthesize table = _table;

@synthesize found = _found;
@synthesize tracks = _tracks;
@synthesize itunes = _itunes;
@synthesize source = _source;
@synthesize currentSearch = _currentSearch;

- (void)awakeFromNib {
    self.table.target = self;
    self.table.doubleAction = @selector(handleTableDoubleAction:);
    self.table.enterAction = @selector(handleTableEnterAction:);

    self.found = [NSMutableArray new];
    self.itunes = [SBApplication
                   applicationWithBundleIdentifier:@"com.apple.iTunes"];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    // setup 'search is done' queue and event handler
    self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_OR, 0, 0, queue);
    dispatch_source_set_event_handler(self.source, ^{
        NSMutableArray * found = [self innerSearchFor:self.currentSearch];

        [self updateFound:found];
    });
    dispatch_resume(self.source);

    // load library asynchronously so application start is not that slow
    dispatch_async(queue, ^(void) {
        [self readLibrary];
    });
}


#pragma mark - Searching

- (void)searchFor:(NSString *)value {
    self.currentSearch = value;
    dispatch_source_merge_data(self.source, 1);
}

- (NSMutableArray *)innerSearchFor:(NSString *)value {
    value = [value lowercaseString];
    NSMutableArray *found = [NSMutableArray new];

    [self.tracks
     enumerateObjectsUsingBlock:^(Track *track, NSUInteger idx, BOOL *stop) {
         ScoredTrack * scored = [track scoredTrack:value];
         if (scored) {
             [found addObject:scored];
         }
    }];

    [found sortUsingSelector:@selector(score)];
    return found;
}


- (void)updateFound:(NSMutableArray *)replacement {
    NSRange allFound = NSMakeRange(0, self.found.count);
    [self.found
     replaceObjectsInRange:allFound
     withObjectsFromArray:replacement];
    [self.table reloadData];
}



#pragma mark - iTunes Communication

- (void)play:(Track *)track {
    iTunesSource *source = [[self.itunes sources] objectAtIndex:0];
    // Second playlist is 'Music' one, which is sorted and all that stuff
    iTunesPlaylist *pl = [[source playlists] objectAtIndex:1];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"persistentID == %@",
                              track.id];
    NSArray *tracks = [[pl tracks] filteredArrayUsingPredicate:predicate];

    [[tracks objectAtIndex:0] playOnce:NO];
}

- (void)playSelectedTrack {
    NSUInteger idx = self.table.selectedRowIndexes.firstIndex;
    if (idx == NSNotFound)
        idx = 0;
    ScoredTrack *current = [self.found objectAtIndex:idx];
    if (current) {
        //        NSLog(@"Starting %lu with score %f for %@",
        //              idx,
        //              current.score,
        //              current.track.repr);
        [self play:current.track];
    }
}

- (int)currentTrackIndex {
    if (self.itunes.playerState == iTunesEPlSStopped)
        return 0;
    NSString * id = self.itunes.currentTrack.persistentID;
    return [self.found
            indexOfObjectPassingTest:^BOOL(ScoredTrack *st, NSUInteger idx, BOOL *stop) {
                return [st.track.id isEqualToString:id];
            }];
}


#pragma mark - Window Delegation

- (void)bringCurrentTrackIntoVisibility {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        int idx = [self currentTrackIndex];
        [self.table scrollRowToVisible:idx];
        self.table.selectedRow = idx;
    });
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [self bringCurrentTrackIntoVisibility];
}


#pragma mark - Search Input delegation

- (void)controlTextDidChange:(NSNotification *)note {
    NSSearchField *field = [note object];
    [self searchFor:[field stringValue]];
}

- (BOOL)control:(NSControl *)control
       textView:(NSTextView *)textView
doCommandBySelector:(SEL)selector {
    if (selector == @selector(insertNewline:)) {
        [self playSelectedTrack];
        return YES;
    }

    if (selector == @selector(moveDown:) || selector == @selector(moveUp:)) {
        NSInteger index = self.table.selectedRow;

        if (selector == @selector(moveUp:)) {
            if (index == NSNotFound) {
                return YES;
            }
            index = index - 1;
        }
        else if (selector == @selector(moveDown:)) {
            if (index == (self.found.count - 1)) {
                return YES;
            }
            if (index == NSNotFound) {
                index = 0;
            } else {
                index++;
            }
        }

        self.table.selectedRow = index;
        [self.table scrollRowToVisible:index];
        return YES;
    }

    if (selector == @selector(moveUp:)) {
        return YES;
    }

    return NO;
}


#pragma mark - Table Delegation

- (void)handleTableDoubleAction:(id)event {
    NSInteger idx = self.table.clickedRow;
    ScoredTrack *clicked = [self.found objectAtIndex:idx];
    [self play:clicked.track];
}

- (void)handleTableEnterAction:(id)event {
    [self playSelectedTrack];
}


# pragma mark - Table Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.found.count;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {
    ScoredTrack * item = [self.found objectAtIndex:row];

    if (item == NULL) {
        NSLog(@"No track at index %ld", row);
        return NULL;
    }

    return [item.track stringForColumn:tableColumn];
}


#pragma mark - Utility

- (void)readLibrary {
    NSString * libraryPath = [self iTunesLibraryPath];
    NSDictionary * tracks = [[NSDictionary
                              dictionaryWithContentsOfFile:libraryPath]
                             objectForKey:@"Tracks"];

    self.tracks = [NSMutableArray arrayWithCapacity:tracks.count];
    for (NSString * key in [tracks keyEnumerator]) {
        [self.tracks
         addObject:[Track withDictionary:[tracks objectForKey:key]]];
    }

    [self.tracks
     sortUsingComparator:^NSComparisonResult(Track *t1, Track *t2) {
         return [t2 compare:t1];
     }];

    [self searchFor:self.currentSearch];
    [self bringCurrentTrackIntoVisibility];
}

- (NSString *)iTunesLibraryPath {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userPref = [userDefaults persistentDomainForName:@"com.apple.iApps"];

    NSArray *recentDatabases = [userPref objectForKey:@"iTunesRecentDatabases"];
    NSString *path = [recentDatabases objectAtIndex:0];
    if (!path)
        return ITUNESLIBRARY;
    return [[NSURL URLWithString:path] path];
}

@end

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
#import "SearchIndex.h"

@implementation SearchController
@synthesize table = _table;

@synthesize found = _found;
@synthesize tracks = _tracks;
@synthesize index = _index;
@synthesize itunes = _itunes;
@synthesize source = _source;

@synthesize currentSearch = _currentSearch;
@synthesize currentTrack = _currentTrack;
@synthesize previouslyPlayingTrack = _previouslyPlayingTrack;


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
        NSArray * found = [self innerSearchFor:self.currentSearch];
        [self updateFound:found];
    });
    dispatch_resume(self.source);

    // load library asynchronously so application starts faster
    dispatch_async(queue, ^(void) {
        [self readLibrary];
    });

    // listen to iTunes notifications to update currently playing song
    NSDistributedNotificationCenter *nc = [NSDistributedNotificationCenter
                                           defaultCenter];
    [nc addObserver:self
           selector:@selector(playingTrackChanged:)
               name:@"com.apple.iTunes.playerInfo"
             object:nil];
}


#pragma mark - Searching

- (void)searchFor:(NSString *)value {
    self.currentSearch = value;
    dispatch_source_merge_data(self.source, 1);
}

- (NSArray *)innerSearchFor:(NSString *)value {
    NSArray *foundTracks = [self.index search:[value lowercaseString]];
    NSMutableArray *found = [NSMutableArray new];

    [foundTracks enumerateObjectsUsingBlock:^(Track *track, NSUInteger idx, BOOL *stop) {
        [found addObject:[ScoredTrack withScore:1.0 andTrack:track]];
    }];

    return found;
}


- (void)updateFound:(NSArray *)replacement {
    NSRange allFound = NSMakeRange(0, self.found.count);
    [self.found
     replaceObjectsInRange:allFound
     withObjectsFromArray:replacement];
    [self.table reloadData];
    [self scrollToSelected];
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
    iTunesTrack *found = [tracks objectAtIndex:0];

    if (found.id == self.itunes.currentTrack.id) {
        [self.itunes stop];
    }

    [found playOnce:NO];
}

- (void)playSelectedTrack {
    ScoredTrack *current = [self.found objectAtIndex:self.table.selectedRow];
    if (current) {
        [self play:current.track];
    }
}

- (Track *)playingTrack {
    if (self.itunes.playerState == iTunesEPlSStopped)
        return nil;
    return [self trackById:self.itunes.currentTrack.persistentID];
}

- (void)playingTrackChanged:(NSNotification *)notification {
    NSString *id = [notification.userInfo objectForKey:@"PersistentID"];
    // persistent id comes as a string with decimal number in notification,
    // unlike library, where it is stored as uppercase hex
    id = [[NSString stringWithFormat:@"%lx", id.integerValue] uppercaseString];

    Track *track = [self trackById:id];
    NSInteger idx = NSNotFound;

    // so if know nothing about playing and nothing is selected why just not
    // select newly started song?
    if (self.previouslyPlayingTrack == nil &&
        self.table.selectedRow == NSNotFound) {

        idx = [self trackVisibleIndex:track];

    } else {
        NSInteger previdx = [self
                             trackVisibleIndex:self.previouslyPlayingTrack];

        // if the previously playing track had been selected, then we are going
        // to put selection on this new song
        if (previdx == self.table.selectedRow) {
            idx = [self trackVisibleIndex:track];
        }
    }

    if (idx != NSNotFound) {
        [self selectAndScrollTo:idx];
    }

    self.previouslyPlayingTrack = track;
}

#pragma mark - Window Delegation

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [self scrollToPlaying];
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

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (self.table.selectedRow == NSNotFound) {
        return;
    }
    ScoredTrack * current = [self.found objectAtIndex:self.table.selectedRow];
    self.currentTrack = current.track;
}

- (void)selectAndScrollTo:(NSInteger)idx {
    if (idx == NSNotFound) {
        [self.table deselectAll:self];
        return;
    }

    self.table.selectedRow = idx;
    [self.table scrollRowToVisible:idx];

    // idea here is that if selected row is too close to an edge (here -
    // less than 5 rows between it and an edge), then it should be centered
    NSRange range = [self.table rowsInRect:self.table.visibleRect];
    if (range.location + 5 > idx) {
        [self.table scrollRowToVisible:idx - (range.length / 2)];
    } else if (range.location + range.length - 5 < idx) {
        [self.table scrollRowToVisible:idx + (range.length / 2)];
    }
}

- (void)scrollToPlaying {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        self.previouslyPlayingTrack = [self playingTrack];
        NSInteger idx = [self trackVisibleIndex:self.previouslyPlayingTrack];
        [self selectAndScrollTo:idx];
    });
}

- (void)scrollToSelected {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if (self.currentTrack == nil) {
            [self.table scrollRowToVisible:0];
            return;
        }

        NSInteger idx = [self trackVisibleIndex:self.currentTrack];

        if (idx == NSNotFound) {
            [self.table scrollRowToVisible:0];
            return;
        }

        [self selectAndScrollTo:idx];
    });
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
         return [t1 compare:t2];
     }];

    self.index = [SearchIndex withTracks:self.tracks];

    [self searchFor:self.currentSearch];
    [self scrollToPlaying];
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

- (Track *)trackById:(NSString *)id {
    for (Track *track in [self.tracks objectEnumerator]) {
        if ([track.id isEqualToString:id]) {
            return track;
        }
    }
    return nil;
}

- (NSInteger)trackVisibleIndex:(Track *)track {
    return [self.found
            indexOfObjectPassingTest:^BOOL(ScoredTrack *st, NSUInteger idx, BOOL *stop) {
                return st.track == track;
            }];
}

@end

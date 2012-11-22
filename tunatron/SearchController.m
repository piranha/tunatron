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
#import "CDEvents/CDEvents.h"

@implementation SearchController
@synthesize table = _table;

@synthesize found = _found;
@synthesize tracks = _tracks;
@synthesize index = _index;
@synthesize itunes = _itunes;
@synthesize searchQueue = _searchQueue;
@synthesize fsevents = _fsevents;
@synthesize libraryDate = _libraryDate;

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

    // setup search queue/handler
    [self setupSearch];

    // watcher will load library for a first time
    [self iTunesLibraryWatch];

    // listen to iTunes notifications to update currently playing song
    NSDistributedNotificationCenter *nc = [NSDistributedNotificationCenter
                                           defaultCenter];
    [nc addObserver:self
           selector:@selector(playingTrackChanged:)
               name:@"com.apple.iTunes.playerInfo"
             object:nil];
}


#pragma mark - Searching

- (void)setupSearch {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    // setup 'search is done' queue and event handler
    self.searchQueue = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_OR, 0, 0, queue);
    dispatch_source_set_event_handler(self.searchQueue, ^{
        //        NSDate *start = [NSDate date];
        //        NSString *s = self.currentSearch;

        NSArray * found = [self innerSearchFor:self.currentSearch];

        //        NSTimeInterval duration = fabs([start timeIntervalSinceNow]);
        //        NSLog(@"Search '%@' has taken %fs", s, duration);

        [self updateFound:found];
    });
    dispatch_resume(self.searchQueue);
}

- (void)searchFor:(NSString *)value {
    self.currentSearch = value;

    // send event to search queue
    dispatch_source_merge_data(self.searchQueue, 1);
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
    NSRange allFound;

    @synchronized(self.found) {
        allFound = NSMakeRange(0, self.found.count);
        [self.found
         replaceObjectsInRange:allFound
         withObjectsFromArray:replacement];
    }

    [self.table reloadData];
    [self scrollToSelected];
}


#pragma mark - iTunes Communication

- (void)play:(Track *)track {
    iTunesSource *source = [self.itunes sources][0];
    // Second playlist is 'Music' one, which is sorted and all that stuff
    iTunesPlaylist *pl = [source playlists][1];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"persistentID == %@",
                              track.id];
    NSArray *tracks = [[pl tracks] filteredArrayUsingPredicate:predicate];
    iTunesTrack *found = tracks[0];

    if (found.id == self.itunes.currentTrack.id) {
        [self.itunes stop];
    }

    [found playOnce:NO];
}

- (void)playSelectedTrack {
    if (self.found.count == 0) return;
    ScoredTrack *current;

    if (self.table.selectedRow == NSNotFound) {
        current = self.found[0];
    } else {
        current = self.found[self.table.selectedRow];
    }

    [self play:current.track];
}

- (Track *)playingTrack {
    if (self.itunes.playerState == iTunesEPlSStopped)
        return nil;
    return [self trackById:self.itunes.currentTrack.persistentID];
}

- (void)playingTrackChanged:(NSNotification *)notification {
    NSString *id = (notification.userInfo)[@"PersistentID"];
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

    if (selector == @selector(cancelOperation:) &&
        [control stringValue].length == 0) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"hide" object:nil];
        return YES;
    }

    if (selector == @selector(noop:)) {
        NSEvent *ev = [NSApp currentEvent];
        NSUInteger flags = ev.modifierFlags & NSDeviceIndependentModifierFlagsMask;
        if ([ev.characters isEqualToString:@"c"] &&
            (flags & NSCommandKeyMask) == NSCommandKeyMask){

            NSPasteboard *board = [NSPasteboard generalPasteboard];
            [board declareTypes:@[NSPasteboardTypeString]
                          owner:nil];
            [board setString:[self currentTrack].shortRepr
                     forType:NSPasteboardTypeString];
            return YES;
        }
    }

    return NO;
}


#pragma mark - Table Delegation

- (void)handleTableDoubleAction:(id)event {
    NSInteger idx = self.table.clickedRow;
    ScoredTrack *clicked = self.found[idx];
    [self play:clicked.track];
}

- (void)handleTableEnterAction:(id)event {
    [self playSelectedTrack];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (self.table.selectedRow == NSNotFound) {
        return;
    }
    ScoredTrack * current = self.found[self.table.selectedRow];
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
    ScoredTrack * item;

    @synchronized(self.found) {
        item = self.found[row];
    }

    if (item == NULL) {
        NSLog(@"No track at index %ld", row);
        return NULL;
    }

    return item.track[tableColumn.identifier];
}

- (void)tableView:tableView
willDisplayCell:(id)cell
forTableColumn:(NSTableColumn *)tableColumn
        row:(NSInteger)row {
    if ([tableColumn.identifier isEqualToString:@"year"]) {
        NSNumberFormatter *f = [NSNumberFormatter new];
        [f setUsesGroupingSeparator:NO];
        [cell setFormatter:f];
    }
}

#pragma mark - Utility

- (void)readLibrary {
    NSString * libraryPath = [self iTunesLibraryPath];
    NSDictionary * tracks = [NSDictionary
                              dictionaryWithContentsOfFile:libraryPath][@"Tracks"];

    self.tracks = [NSMutableArray arrayWithCapacity:tracks.count];
    for (NSString * key in [tracks keyEnumerator]) {
        [self.tracks
         addObject:[Track withDictionary:tracks[key]]];
    }

    [self.tracks
     sortUsingComparator:^NSComparisonResult(Track *t1, Track *t2) {
         return [t1 compare:t2];
     }];

    self.index = [SearchIndex withTracks:self.tracks];

    [self searchFor:self.currentSearch];
    [self scrollToPlaying];
}

- (void)checkLibraryModifications {
    NSFileManager *man = [NSFileManager new];
    NSString *path = [self iTunesLibraryPath];
    NSDictionary *attrs = [man attributesOfItemAtPath:path error:NULL];
    NSDate *mod = [attrs fileModificationDate];

    if (self.libraryDate == nil ||
        [self.libraryDate compare:mod] == NSOrderedAscending) {

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^(void) {
            [self readLibrary];
        });
    }

    self.libraryDate = mod;
}

- (NSString *)iTunesLibraryPath {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userPref = [userDefaults persistentDomainForName:@"com.apple.iApps"];

    NSArray *recentDatabases = userPref[@"iTunesRecentDatabases"];
    NSString *path = recentDatabases[0];
    if (!path)
        return ITUNESLIBRARY;
    return [[NSURL URLWithString:path] path];
}

- (void)iTunesLibraryWatch {
    NSURL *url = [NSURL URLWithString:
                  [[[self iTunesLibraryPath]
                   stringByDeletingLastPathComponent]
                   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    self.fsevents = [[CDEvents alloc]
                     initWithURLs:@[url]
                     block:^(CDEvents *watcher, CDEvent *event) {
                         [self checkLibraryModifications];
                     }];

    [self checkLibraryModifications];
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
    NSArray * found;

    @synchronized(self.found) {
        found = [self.found copy];
    }

    return [found
            indexOfObjectPassingTest:^BOOL(ScoredTrack *st, NSUInteger idx, BOOL *stop) {
                return st.track == track;
            }];
}

@end

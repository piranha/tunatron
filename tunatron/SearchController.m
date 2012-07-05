//
//  SearchController.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
    self.found = [NSMutableArray new];
    self.itunes = [SBApplication
                   applicationWithBundleIdentifier:@"com.apple.iTunes"];

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

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_OR, 0, 0, queue);
    dispatch_source_set_event_handler(self.source, ^{
        NSDate *start = [NSDate date];
        NSString *searchString = [NSString stringWithString:self.currentSearch];
        NSMutableArray * found = [self innerSearchFor:searchString];
        NSTimeInterval duration = fabs([start timeIntervalSinceNow]);
//        NSLog(@"Search %@ has taken shit %f", searchString, duration);

        [self updateFound:found];
    });
    dispatch_resume(self.source);
    [self searchFor:@""];
}

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

// search input delegation

- (void)controlTextDidChange:(NSNotification *)note {
    NSSearchField *field = [note object];
    [self searchFor:[field stringValue]];
}


// table data source

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

// utility

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

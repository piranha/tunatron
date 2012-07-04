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

@implementation SearchController
@synthesize table = _table;

@synthesize found = _found;
@synthesize tracks = _tracks;
@synthesize itunes = _itunes;

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

    [self searchFor:@""];
}

- (void)searchFor:(NSString *)value {
    [self.found removeAllObjects];
    value = [value lowercaseString];

    [self.tracks
     enumerateObjectsUsingBlock:^(Track *track, NSUInteger idx, BOOL *stop) {
         if ([track matches:value]) {
             [self.found addObject:[NSNumber numberWithInt:idx]];
         }
    }];

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
    NSNumber *idx = [self.found objectAtIndex:row];

    if (idx == NULL) {
        NSLog(@"No song at index %ld", row);
        return NULL;
    }

    Track *track = [self.tracks objectAtIndex:[idx integerValue]];

    return [track stringForColumn:tableColumn];
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

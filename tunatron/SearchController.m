//
//  SearchController.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchController.h"
#import "iTunes.h"
#import "Song.h"

@implementation SearchController
@synthesize table = _table;

@synthesize songs = _songs;
@synthesize tracks = _tracks;

- (void)awakeFromNib {
    self.songs = [NSMutableArray new];

    NSString * libraryPath = [self iTunesLibraryPath];
    NSDictionary * library = [NSDictionary
                              dictionaryWithContentsOfFile:libraryPath];
    self.tracks = [library objectForKey:@"Tracks"];

    [self searchFor:@""];
}

- (void)searchFor:(NSString *)value {
    NSString *name = [NSString stringWithFormat:@"%d", [self.tracks count]];
    Song *song = [Song newWithArtist:value name:name];

    if (self.songs.count) {
        [self.songs replaceObjectAtIndex:0 withObject:song];
    } else {
        [self.songs addObject:song];
    }
    [self.table reloadData];
}

// search input delegation

- (void)controlTextDidChange:(NSNotification *)note {
    NSSearchField *field = [note object];
    [self searchFor:[field stringValue]];
}


// table data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.songs.count;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {
    Song *song = [self.songs objectAtIndex:row];

    if (!song) {
        NSLog(@"No song at index %ld", row);
        return NULL;
    }

    return [song stringForColumn:tableColumn];
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

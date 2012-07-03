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

@synthesize library = _library;
@synthesize songs = _songs;

@synthesize itunes = _itunes;
@synthesize tracks = _tracks;

- (void)awakeFromNib {
    self.songs = [NSMutableArray new];
    self.itunes = [SBApplication
                   applicationWithBundleIdentifier:@"com.apple.itunes"];

//    NSPredicate *libraryPred = [NSPredicate
//                                predicateWithFormat:@"kind == '%i'",
//                                iTunesESrcLibrary];
    iTunesSource *library = [[self.itunes sources]
//                              filteredArrayUsingPredicate:libraryPred]
                             objectAtIndex:0];
//    NSPredicate *plPred = [NSPredicate
//                           predicateWithFormat:@"kind == %i",
//                           iTunesESpKMusic];
    iTunesPlaylist *pl = [[library playlists]
                          objectAtIndex:0];

    self.tracks = [pl tracks];

    NSString *name = [NSString stringWithFormat:@"%d", [self.library count]];

    Song *song = [Song newWithArtist:@"Q" name:name];
    [self.songs addObject:song];
}

- (void)controlTextDidChange:(NSNotification *)note {
    NSSearchField *field = [note object];
    NSString *val = [field stringValue];
//    NSLog(@"text: %@", val);

    NSPredicate *pred = [NSPredicate
                         predicateWithFormat:@"artist contains[cd] %@",
                         val];
    NSArray *found = [self.tracks filteredArrayUsingPredicate:pred];

    NSString *name = [NSString stringWithFormat:@"%d", [found count]];
    Song *song = [Song newWithArtist:val name:name];

    [self.songs replaceObjectAtIndex:0 withObject:song];
    [self.table reloadData];


}

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

@end

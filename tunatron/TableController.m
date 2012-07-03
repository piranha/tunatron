//
//  TableController.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableController.h"
#import "Song.h"

@implementation TableController

@synthesize songs = _songs;

- (void)awakeFromNib {
    self.songs = [NSMutableArray new];
    
    Song *song = [[Song alloc] initWithArtist:@"Q" andName:@"A"];
    [self.songs addObject:song];
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

//
//  SearchController.h
//  tunatron
//
//  Created by Alexander Solovyov on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define ITUNESLIBRARY [@"~/Music/iTunes/iTunes Music Library.xml" stringByStandardizingPath]

@class iTunesApplication;
@class SBElementArray;

@interface SearchController : NSObject <NSTableViewDataSource>

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

@property (strong) NSMutableArray *songs;
@property (strong) NSDictionary *tracks;

// UI elements
@property (weak) IBOutlet NSTableView *table;

@end

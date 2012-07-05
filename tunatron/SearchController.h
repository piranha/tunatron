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

@interface SearchController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row;

@property (strong) NSMutableArray *found;
@property (strong) NSMutableArray *tracks;
@property (strong) iTunesApplication *itunes;
@property dispatch_source_t source;

@property (copy) NSString *currentSearch;

// UI elements
@property (weak) IBOutlet NSTableView *table;

@end

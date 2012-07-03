//
//  SearchController.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchController.h"
#import "iTunes.h"

@implementation SearchController

- (void)controlTextDidChange:(NSNotification *)note {
    NSSearchField *field = [note object];
    NSString *val = [field stringValue];
    NSLog(@"text: %@", val);
        
//    iTunesApplication *it = [SBApplication 
//                        applicationWithBundleIdentifier:@"com.apple.itunes"];
    
}

@end

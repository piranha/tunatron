//
//  NSBetterTableView.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/5/12.
//  Copyright (c) 2012 Witty Bullet. All rights reserved.
//

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#import "NSBetterTableView.h"

@implementation NSBetterTableView

@synthesize enterAction = _enterAction;

- (void)keyDown:(NSEvent *)event {
    unichar c = [event.charactersIgnoringModifiers characterAtIndex:0];

    if (c == 13) {
        if (self.enterAction && self.target) {
            [self.target performSelector:self.enterAction withObject:event];
        }
        return;
    }

    [super keyDown:event];
}

- (NSInteger)selectedRow {
    NSIndexSet *indexes = self.selectedRowIndexes;
    return indexes.firstIndex;
}

- (void)setSelectedRow:(NSInteger)index {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:index];
    [self selectRowIndexes:indexes byExtendingSelection:NO];
}

@end

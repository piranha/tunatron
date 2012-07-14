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

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
    // empirically determined color, matches iTunes etc.
    NSColor *evenColor = [NSColor colorWithCalibratedRed:0.929
                                                   green:0.953
                                                    blue:0.996
                                                   alpha:1.0];
    NSColor *oddColor = [NSColor whiteColor];

    float rowHeight = self.rowHeight + self.intercellSpacing.height;
    NSRect visibleRect = self.visibleRect;
    NSRect highlightRect;

    highlightRect.origin = NSMakePoint(NSMinX(visibleRect),
                                       (int)(NSMinY(clipRect) / rowHeight) * rowHeight);
    highlightRect.size = NSMakeSize(NSWidth(visibleRect),
                                    rowHeight - self.intercellSpacing.height);

    while (NSMinY(highlightRect) < NSMaxY(clipRect)) {
        NSRect clippedHighlightRect = NSIntersectionRect(highlightRect, clipRect);
        int row = (int)((NSMinY(highlightRect) + rowHeight / 2.0) / rowHeight);
        NSColor *rowColor = (0 == row % 2) ? evenColor : oddColor;
        [rowColor set];
        NSRectFill(clippedHighlightRect);
        highlightRect.origin.y += rowHeight;
    }

    [super highlightSelectionInClipRect: clipRect];
}

@end

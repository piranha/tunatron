//
//  StatusItemView.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatusItemView.h"

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

+ (id)withMenu:(NSMenu *)menu andImage:(NSString *)image {
    NSStatusItem * statusItem = [[NSStatusBar systemStatusBar]
                                 statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
    statusItem.menu = menu;
    statusItem.image = [NSImage imageNamed:image];

    StatusItemView * new = [[self alloc] initWithStatusItem:statusItem];

    return new;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem {
    CGFloat width = [statusItem length];
    CGFloat height = [[NSStatusBar systemStatusBar] thickness];
    NSRect rect = NSMakeRect(0.0, 0.0, width, height);
    
    if (self = [self initWithFrame:rect]) {
        _statusItem = statusItem;
        self.statusItem.view = self;
    }
    return self;
}

- (void)mouseDown:(NSEvent *)event {
    [NSApp sendAction:self.action to:self.target from:self];
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.statusItem
     drawStatusBarBackgroundInRect:dirtyRect
     withHighlight:self.isHighlighted];

    NSImage * icon = self.statusItem.image;
    NSSize size = icon.size;
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - size.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - size.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);
    [icon compositeToPoint:iconPoint operation:NSCompositeSourceOver];  
}

#pragma mark - Setters

- (void)setHighlighted:(BOOL)isHighlighted {
    if (self.isHighlighted == isHighlighted)
        return;
    _isHighlighted = isHighlighted;
    self.needsDisplay = YES;
}

@end

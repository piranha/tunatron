//
//  StatusItemView.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatusItemView.h"

@implementation StatusItemView

@synthesize image = _image;
@synthesize menu = _menu;
@synthesize statusItem = _statusItem;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

# pragma mark - Initialization

+ (id)withMenu:(NSMenu *)menu {
    return [[self alloc] initWithMenu:menu];
}

- (id)initWithMenu:(NSMenu *)menu {
    if (!(self = [self init])) {
        return self;
    }
    self.menu = menu;
    menu.delegate = self;
    return self;
}

- (id)init {
    NSStatusItem * statusItem = [[NSStatusBar systemStatusBar]
                                 statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);

    if (!(self = [super initWithFrame:itemRect])) {
        return self;
    }
    _statusItem = statusItem;
    self.statusItem.view = self;
    return self;
}

#pragma mark - Menu Handling

- (void)menuWillOpen:(NSMenu *)menu {
    self.isHighlighted = true;
}

- (void)menuDidClose:(NSMenu *)menu {
    self.isHighlighted = false;
}

#pragma mark - UI Rendering

- (void)drawRect:(NSRect)dirtyRect {
    [self.statusItem
     drawStatusBarBackgroundInRect:dirtyRect
     withHighlight:self.isHighlighted];

    NSImage * icon = self.image;
    NSSize size = icon.size;
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - size.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - size.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);
    [icon drawAtPoint:iconPoint
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0];
}

#pragma mark - Mouse Tracking

- (void)mouseDown:(NSEvent *)event {
    self.isHighlighted = true;
    [NSApp sendAction:self.action to:self.target from:self];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 
                                            30 * NSEC_PER_MSEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.isHighlighted = false;
    });
}

- (void)rightMouseDown:(NSEvent *)event {
    [self.statusItem popUpStatusItemMenu:self.menu];
//    [NSApp sendAction:self.rightAction to:self.target from:self];
}

#pragma mark - Setters

- (void)setHighlighted:(BOOL)isHighlighted {
    if (self.isHighlighted == isHighlighted)
        return;
    _isHighlighted = isHighlighted;
    self.needsDisplay = YES;
}

@end

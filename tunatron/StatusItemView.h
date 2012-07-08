//
//  StatusItemView.h
//  tunatron
//
//  Created by Alexander Solovyov on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define STATUS_ITEM_VIEW_WIDTH 24.0

@interface StatusItemView : NSView <NSMenuDelegate>

@property (nonatomic, strong) NSImage * image;
@property (weak) NSMenu * menu;
@property (nonatomic, strong, readonly, retain) NSStatusItem * statusItem;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;

+ withMenu:(NSMenu *)menu;
- (id)initWithMenu:(NSMenu *)menu;

@end

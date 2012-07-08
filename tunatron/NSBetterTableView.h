//
//  NSBetterTableView.h
//  tunatron
//
//  Created by Alexander Solovyov on 7/5/12.
//  Copyright (c) 2012 Witty Bullet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBetterTableView : NSTableView

@property SEL enterAction;
@property NSInteger selectedRow;

@end

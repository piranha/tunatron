//
//  PreferencesController.h
//  tunatron
//
//  Created by Alexander Solovyov on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASShortcut/MASShortcutView+UserDefaults.h"

FOUNDATION_EXPORT NSString * const GLOBAL_SHORTCUT;

@interface PreferencesController : NSWindowController

@property (weak) IBOutlet MASShortcutView *shortcutView;

@end

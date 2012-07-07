//
//  PreferencesController.h
//  tunatron
//
//  Created by Alexander Solovyov on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ShortcutRecorder/SRRecorderControl.h"

@interface PreferencesController : NSWindowController

@property IBOutlet SRRecorderControl *shortcutRecorder;

@end

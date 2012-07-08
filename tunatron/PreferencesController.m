//
//  PreferencesController.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"

NSString *const GLOBAL_SHORTCUT = @"GlobalShortcut";

@implementation PreferencesController

@synthesize shortcutView = _shortcutView;

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.shortcutView.associatedUserDefaultsKey = GLOBAL_SHORTCUT;
}

//- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder 
//               isKeyCode:(signed short)keyCode 
//           andFlagsTaken:(unsigned int)flags 
//                  reason:(NSString **)aReason {
//    return NO;
//}
//
//- (void)shortcutRecorder:(SRRecorderControl *)aRecorder 
//       keyComboDidChange:(KeyCombo)newKeyCombo {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setInteger:newKeyCombo.code forKey:@"key"];
//    [defaults setInteger:newKeyCombo.flags forKey:@"flags"];
//}

@end

//
//  PreferencesController.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

- (id)initWithWindow:(NSWindow *)window {
    if (self = [super initWithWindow:window]) {
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
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

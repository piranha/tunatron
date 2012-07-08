//
//  AppDelegate.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/2/12.
//  Copyright (c) 2012 Witty Bullet. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusItemView.h"
#import "MASShortcut/MASShortcut+UserDefaults.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize statusMenu = _statusMenu;
@synthesize statusItemView = _statusItemView;
@synthesize preferencesController = _preferencesController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItemView = [StatusItemView withMenu:self.statusMenu];
    self.statusItemView.image = [NSImage imageNamed:@"fish-glyph-24"];
    self.statusItemView.target = self;
    self.statusItemView.action = @selector(toggleWindow);

    self.window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces;
    self.window.isVisible = NO;

    [MASShortcut
     registerGlobalShortcutWithUserDefaultsKey:GLOBAL_SHORTCUT
     handler:^(void) {
         [self toggleWindow];
     }];

}

- (void)activateWindow {
    self.window.isVisible = YES;
    self.window.orderedIndex = 0;
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)toggleWindow {
    if (self.window.isKeyWindow) {
        self.window.isVisible = NO;
    } else {
        [self activateWindow];
    }
}

- (void)showPreferences:(id)sender {
    if (!self.preferencesController) {
        self.preferencesController = [[PreferencesController alloc]
                                      initWithWindowNibName:@"Preferences"];
    }

    [self.preferencesController showWindow:self];
}

- (IBAction)showSearch:(id)sender {
    [self activateWindow];
}

- (IBAction)quit:(id)sender {
    [NSApp terminate:nil];
}

@end

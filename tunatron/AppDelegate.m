//
//  AppDelegate.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/2/12.
//  Copyright (c) 2012 Witty Bullet. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusItemView.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize statusMenu = _statusMenu;
@synthesize statusItemView = _statusItemView;
@synthesize preferencesController = _preferencesController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
    return YES;
}

- (void)awakeFromNib {
    self.statusItemView = [StatusItemView 
                           withMenu:self.statusMenu 
                           andImage:@"fish-glyph-24"];
    self.statusItemView.target = self;
    self.statusItemView.action = @selector(toggleWindow:);
}

- (void)toggleWindow:(id)sender {
    self.window.isVisible = !self.window.isVisible;
}

- (void)showPreferences:(id)sender {
    NSLog(@"%@", self.statusItemView);
    NSLog(@"%@", self.statusItemView.statusItem);
    return;
    if (!self.preferencesController) {
        self.preferencesController = [[PreferencesController alloc] 
                                      initWithWindowNibName:@"Preferences"];
    }
    
    [self.preferencesController showWindow:self];
}

@end

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
    [self toggleWindow];
}

- (void)awakeFromNib {
    self.statusItemView = [StatusItemView withMenu:self.statusMenu];
    self.statusItemView.image = [NSImage imageNamed:@"fish-glyph-24"];
    self.statusItemView.target = self;
    self.statusItemView.action = @selector(toggleWindow);
}

- (void)toggleWindow {
    self.window.isVisible = !self.window.isVisible;
}

- (void)showPreferences:(id)sender {
    if (!self.preferencesController) {
        self.preferencesController = [[PreferencesController alloc] 
                                      initWithWindowNibName:@"Preferences"];
    }
    
    [self.preferencesController showWindow:self];
}

@end

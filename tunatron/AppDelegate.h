//
//  AppDelegate.h
//  tunatron
//
//  Created by Alexander Solovyov on 7/2/12.
//  Copyright (c) 2012 Witty Bullet. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"

@class StatusItemView;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) StatusItemView *statusItemView;
@property (retain) PreferencesController *preferencesController;

- (IBAction)showPreferences:(id)sender;
- (IBAction)showSearch:(id)sender;
- (IBAction)quit:(id)sender;

@end

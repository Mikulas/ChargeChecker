//
//  AppDelegate.h
//  Battery Checker
//
//  Created by Mikuláš Dítě on 30/12/13.
//  Copyright (c) 2013 Mikuláš Dítě. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (strong, nonatomic) NSStatusItem *statusBar;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *labelBattery;
@property (weak) IBOutlet NSMenuItem *labelStatus;
@property (weak) IBOutlet NSMenuItem *labelRemind;
@property (weak) IBOutlet NSMenuItem *labelRemindSeparator;

@property Boolean notifiedDrain;
@property Boolean notifiedOvercharge;

@end

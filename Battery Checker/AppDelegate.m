//
//  AppDelegate.m
//  Battery Checker
//
//  Created by Mikuláš Dítě on 30/12/13.
//  Copyright (c) 2013 Mikuláš Dítě. All rights reserved.
//

#import "AppDelegate.h"
#include <IOKit/ps/IOPowerSources.h>
#include <IOKit/ps/IOPSKeys.h>

@implementation AppDelegate

@synthesize statusBar = _statusBar;

struct BatStat
{
    bool draining;
    double percent;
};

- (void) awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    //self.statusBar.title = @"What";
    self.statusBar.image = [NSImage imageNamed:@"icon"];

    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.notifiedDrain = false;
    self.notifiedOvercharge = false;

//    [self showNotification:self title:@"test 2" text:@"test 2"];

    [self performSelectorInBackground:@selector(checkBattery) withObject:nil];
    [NSTimer scheduledTimerWithTimeInterval:30.0
                                     target:self
                                   selector:@selector(checkBattery)
                                   userInfo:nil
                                    repeats:YES];
}

- (IBAction)remindAgain:(id)sender {
    self.notifiedOvercharge = false;
    self.notifiedDrain = false;
    [self checkBattery];
}

- (void)checkBattery{
    struct BatStat bat = [self getBatStat];
    self.labelBattery.title = [NSString stringWithFormat:@"%.0f %%, %@",
                               bat.percent * 100, bat.draining ? @"draining" : @"charging"];
    self.labelStatus.title = bat.draining ? @"You will notified at 20 %" : @"You will notified at 80 %";

    if (bat.draining) {
        self.notifiedOvercharge = false;
    } else {
        self.notifiedDrain = false;
    }

    if (bat.percent <= .2 && bat.draining)
    {
        if (!self.notifiedDrain) {
            self.notifiedDrain = true;
            NSLog(@"draining (%f, %@)", bat.percent, bat.draining ? @"draining" : @"charging");
            [self showNotification:self title:@"Battery draining." text:@"Plug-in the charger."];

            [self.labelRemindSeparator setHidden:false];
            [self.labelRemind setHidden:false];
            [self.labelRemind setTitle:@"Plug-in the charger"];
        }
    }
    else if (bat.percent >= .8 && !bat.draining)
    {
        if (!self.notifiedOvercharge) {
            self.notifiedOvercharge = true;
            NSLog(@"overcharged (%f, %@)", bat.percent, bat.draining ? @"draining" : @"charging");
            [self showNotification:self title:@"Battery overcharging." text:@"Unplug the charger."];

            [self.labelRemindSeparator setHidden:false];
            [self.labelRemind setHidden:false];
            [self.labelRemind setTitle:@"Unplug the charger"];
        }
    }
    else
    {
        [self.labelRemindSeparator setHidden:true];
        [self.labelRemind setHidden:true];
        NSLog(@"everything fine, waiting (%f, %@)", bat.percent, bat.draining ? @"draining" : @"charging");
    }
}

- (struct BatStat)getBatStat{
    CFTypeRef blob = IOPSCopyPowerSourcesInfo();
	CFArrayRef sources = IOPSCopyPowerSourcesList(blob);

	CFDictionaryRef pSource = NULL;
	const void *psValue;

    struct BatStat bs;
    bs.draining = true;
    bs.percent = 1; // just something

	long numOfSources = CFArrayGetCount(sources);
	for (int i = 0 ; i < numOfSources ; i++)
	{
		pSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, i));
		if (!pSource) return bs; // wont happen to me

		psValue = (CFStringRef)CFDictionaryGetValue(pSource, CFSTR(kIOPSNameKey));

		int curCapacity = 0;
		int maxCapacity = 0;

		psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSCurrentCapacityKey));
		CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &curCapacity);

		psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSMaxCapacityKey));
		CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &maxCapacity);

        bs.draining = CFDictionaryGetValue(pSource, CFSTR(kIOPSIsChargingKey)) == kCFBooleanFalse;
		bs.percent = (double)curCapacity / (double)maxCapacity;
//        NSLog(@"drain %d", bs.draining ? 1 : 0);
//        NSLog(@"percent %f", bs.percent);

        return bs;
	}
    return bs;
}

- (IBAction)showNotification:(id)sender title:(NSString*)title text:(NSString*)text {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = text;
    notification.soundName = NSUserNotificationDefaultSoundName;

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end

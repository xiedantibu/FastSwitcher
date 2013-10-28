//
//  AZAppDelegate.m
//  FastSwitcher
//
//  Created by Alvin on 13-10-22.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZAppDelegate.h"
#import "AZHotKeyManager.h"
#import "AZResourceManager.h"
#import "AZAppController.h"

@implementation AZAppDelegate

/*
 * Add "Application is agent (UIElement)" to plist,
 * and set TRUE to hide the application in app switcher
 */

//static CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
//    
//    NSDate *tempTimeStamp = [NSDate date];
//
//    EventHotKeyID hotKeyRef;
//    EventRecord record;
//    EventHotKeyRef hotkey;
//    
//    
//    EventRef eventRef;
//    CreateEventWithCGEvent(NULL, event, kEventAttributeNone, &eventRef);
//    GetEventParameter(eventRef, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyRef), NULL, &hotKeyRef);
//
//    GetEventParameter(eventRef, kEventParamDirectObject, typeEventInfo, NULL, sizeof(record), NULL, &record);
//    
//    return event;
//}
//
//    
//    // listen any key but for flags
//    CGEventMask eventMask = CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventKeyDown);
//    CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, eventMask, eventCallback, NULL);
//    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
//    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
//    CGEventTapEnable(eventTap, true);
//    CFRelease(eventTap);
//    CFRelease(runLoopSource);

- (void)awakeFromNib {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shownInStatusBar"]) {
        [self showStatusBar];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    isFirstActive = YES;
    
    [self listenEvents];
    
    NSArray *appsArray = [[AZResourceManager sharedInstance] readSelectedAppsList];
    [[AZHotKeyManager sharedInstance] registerHotKey:appsArray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showStatusBar) name:@"SHOW_STATUS_BAR" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideStatusBar) name:@"HIDE_STATUS_BAR" object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shownInStatusBar"] && !isFirstActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_PREFERENCE_VIEW" object:nil];
    }
    isFirstActive = NO;
}

- (void)showStatusBar {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:self.statusMenu];
    [statusItem setTitle:@"FS"];
    [statusItem setHighlightMode:YES];
}

- (void)hideStatusBar {
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
}

#pragma mark - Handle events

- (void)listenEvents {
    // get modify key
    NSInteger modifyKey = [self getModifyKey];
    
    // get delay interval
    NSTimeInterval interval = [self getDelayInterval];
    
    // Clear previous monitors
    if (self.globalMonitor != nil && self.localMonitor != nil) {
        [NSEvent removeMonitor:self.globalMonitor];
        [NSEvent removeMonitor:self.localMonitor];
    }
    
    // Global monitor
    self.globalMonitor = 
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask | NSKeyDownMask handler: ^(NSEvent *event) {
        BOOL shownSwitcherView = [[NSUserDefaults standardUserDefaults] boolForKey:@"shownSwitcherView"];
        
        NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;

        if(shownSwitcherView && flags == modifyKey && !self.window.isFadingOut && !isTapping){
            isTapping = YES;
            
            // check hot key enable
            if (hasTapped) {
                hasTapped = NO;
                self.enableHotKey = NO;
                [self.timerDelay invalidate];
                [self.timerDisabelHotKey invalidate];
                return;
            }
            hasTapped = YES;
            self.timerDisabelHotKey = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(cancelHoykeyDisable) userInfo:nil repeats:NO];

            if (self.window == nil) {
                self.window  = [[AZAppsSwitchWindow alloc] init];
            }
            self.timerDelay = [NSTimer scheduledTimerWithTimeInterval:interval 
                                                               target:self 
                                                             selector:@selector(switcherViewFadeIn) 
                                                             userInfo:nil 
                                                              repeats:NO];
        } else {
            if ([self.timerDelay isValid]) [self.timerDelay invalidate];
            if (isTapping) [self.window fadeOut];
            isTapping = NO;
        }
    }];
    
    self.localMonitor = 
    [NSEvent addLocalMonitorForEventsMatchingMask:NSFlagsChangedMask | NSKeyDownMask handler:^(NSEvent *event) {
        BOOL shownSwitcherView = [[NSUserDefaults standardUserDefaults] boolForKey:@"shownSwitcherView"];
        
        NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;

        if(shownSwitcherView && flags == modifyKey && !self.window.isFadingOut && !isTapping){
            isTapping = YES;
            // check hot key enable
            if (hasTapped) {
                hasTapped = NO;
                self.enableHotKey = NO;
                [self.timerDelay invalidate];
                [self.timerDisabelHotKey invalidate];
                return event;
            }
            hasTapped = YES;
            self.timerDisabelHotKey = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(cancelHoykeyDisable) userInfo:nil repeats:NO];
            
            if (self.window == nil) {
                self.window  = [[AZAppsSwitchWindow alloc] init];
            }
            self.timerDelay = [NSTimer scheduledTimerWithTimeInterval:interval 
                                                               target:self 
                                                             selector:@selector(switcherViewFadeIn) 
                                                             userInfo:nil 
                                                              repeats:NO];
        } else {
            if ([self.timerDelay isValid]) [self.timerDelay invalidate];
            if (isTapping) [self.window fadeOut];
            isTapping = NO;
        }
        return event;
    }];
}

- (NSInteger)getModifyKey {
    NSInteger modifyKeyIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"modifyKey"];
    NSInteger modifyKey = 0;
    switch (modifyKeyIndex) {
        case 0:
            modifyKey = NSCommandKeyMask;
            break;
        case 1:
            modifyKey = NSAlternateKeyMask;
            break;
        case 2:
            modifyKey = NSControlKeyMask;
            break;
        case 3:
            modifyKey = NSShiftKeyMask;
            break;
        default:
            modifyKey = NSCommandKeyMask;
            break;
    }
    return modifyKey;
}

- (NSTimeInterval)getDelayInterval {
    NSTimeInterval interval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"delayInterval"];
    return interval;
}

- (void)refreshWindow {
    self.window = nil;
    self.window = [[AZAppsSwitchWindow alloc] init];
}

- (void)switcherViewFadeIn {
    if (isTapping) {
        [self.window fadeIn];
    }
}

- (void)cancelHoykeyDisable {
    hasTapped = NO;
}

@end

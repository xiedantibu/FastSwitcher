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

- (void)listenEvents {
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask | NSPeriodicMask handler: ^(NSEvent *event) {
        NSLog(@"global press");
        NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
        if(flags == NSAlternateKeyMask && !self.window.isFadingOut){
            isTapping = YES;
            if (self.window == nil) {
                self.window  = [[AZAppsSwitchWindow alloc] init];
            }
            [self.window fadeIn];
        } else {
            if (isTapping) [self.window fadeOut];
            isTapping = NO;
        }
    }];
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSFlagsChangedMask | NSPeriodicMask handler:^(NSEvent *event) {
        NSLog(@"local press");
        NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
        if(flags == NSAlternateKeyMask && !self.window.isFadingOut){
            isTapping = YES;
            if (self.window == nil) {
                self.window  = [[AZAppsSwitchWindow alloc] init];
            }

            [self.window fadeIn];
        } else  {
            if (isTapping) [self.window fadeOut];
            isTapping = NO;
        }
        return event;
    }];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self listenEvents];
    
    NSArray *appsArray = [[AZResourceManager sharedInstance] readSelectedAppsList];
    [[AZHotKeyManager sharedInstance] registerHotKey:appsArray];
}

- (void)awakeFromNib {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"FS"];
    [statusItem setHighlightMode:YES];
}

@end

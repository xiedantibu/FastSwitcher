//
//  AZAppDelegate.h
//  FastSwitcher
//
//  Created by Alvin on 13-10-22.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AZAppsSwitchWindow.h"

@interface AZAppDelegate : NSObject <NSApplicationDelegate> {
    BOOL isFirstActive;
    BOOL isTapping;
    BOOL hasTapped;
}

@property (nonatomic, strong) id globalMonitor;
@property (nonatomic, strong) id localMonitor;
@property (nonatomic, assign) BOOL enableHotKey;
@property (nonatomic, strong) NSTimer *timerDelay;
@property (nonatomic, strong) NSTimer *timerDisabelHotKey;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, weak) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) AZAppsSwitchWindow *window;

- (void)listenEvents;

@end

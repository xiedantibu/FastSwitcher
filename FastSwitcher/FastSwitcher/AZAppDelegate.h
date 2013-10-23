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
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    
    BOOL isTapping;
}

@property (nonatomic, strong) AZAppsSwitchWindow *window;

@end

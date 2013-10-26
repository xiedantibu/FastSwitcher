//
//  AZAppController.m
//  AppShortCut
//
//  Created by Alvin on 13-10-17.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZAppController.h"
#import "AZPrefsWindowController.h"

@implementation AZAppController

- (void)awakeFromNib {
}

- (void)showPreferencePanel:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [[AZPrefsWindowController sharedPreferenceWindowController] showWindow:nil];
}

- (void)showAboutPanel:(id)sender {
    
}

- (void)exit:(id)sender {
    [NSApp terminate:self];
}

@end

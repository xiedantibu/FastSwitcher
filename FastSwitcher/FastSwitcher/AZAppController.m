//
//  AZAppController.m
//  AppShortCut
//
//  Created by Alvin on 13-10-17.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZAppController.h"
#import "AZPreferenceWindowController.h"

@implementation AZAppController

- (void)awakeFromNib {
}

- (void)showPreferencePanel:(id)sender {
    if (!preferenceController) {
        preferenceController = [[AZPreferenceWindowController alloc] init];
    }
    [NSApp activateIgnoringOtherApps:YES];
    [preferenceController showWindow:self];
}

- (void)showAboutPanel:(id)sender {
    
}

- (void)exit:(id)sender {
    [NSApp terminate:self];
}

@end

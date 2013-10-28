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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPreferencePanel:) name:@"SHOW_PREFERENCE_VIEW" object:nil];
}

- (void)showPreferencePanel:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [[AZPrefsWindowController sharedPreferenceWindowController] showWindow:nil];
}

- (void)showAboutPanel:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [[AZPrefsWindowController sharedPreferenceWindowController] loadViewForIdentifier:@"Updates"];
}

- (void)exit:(id)sender {
    [NSApp terminate:self];
}

@end

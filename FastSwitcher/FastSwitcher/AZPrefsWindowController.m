//
//  AZPrefsWindowController.m
//  FastSwitcher
//
//  Created by Alvin on 13-10-24.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZPrefsWindowController.h"

@interface AZPrefsWindowController ()

@end

@implementation AZPrefsWindowController

- (void)setupToolbar {
    NSNib *nib = [[NSNib alloc] initWithNibNamed:[AZPrefsWindowController nibName] bundle:nil];
    NSArray *topLevelObjects;
    if (! [nib instantiateWithOwner:nil topLevelObjects:&topLevelObjects]) // error
        NSLog(@"shit");
    for (id topLevelObject in topLevelObjects) {
        if ([topLevelObject isKindOfClass:[AZAppsSelectionView class]]) {
            self.appsSelectionView = topLevelObject;
        } else if ([topLevelObject isKindOfClass:[AZConfigView class]]) {
            self.configView = topLevelObject;
        } else if ([topLevelObject isKindOfClass:[AZAboutView class]]) {
            self.aboutView = topLevelObject;
        }
    }
    
    [self addView:self.appsSelectionView label:@"General"];
    [self addView:self.configView label:@"Advanced"];
    [self addView:self.aboutView label:@"Updates"];
}

@end

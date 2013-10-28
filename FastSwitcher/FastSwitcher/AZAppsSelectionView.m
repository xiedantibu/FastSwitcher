//
//  AZAppsSelectionView.m
//  FastSwitcher
//
//  Created by Alvin on 13-10-24.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZAppsSelectionView.h"
#import "AZAppsManager.h"
#import "AZAppModel.h"
#import "AZResourceManager.h"
#import "AZHotKeyManager.h"

@interface AZAppsSelectionView ()

@property (nonatomic, strong) NSArray *appsList;

@end

@implementation AZAppsSelectionView

- (void)awakeFromNib {
    self.appsList = [[AZAppsManager sharedInstance] getApps];
    // setup popupMenu    
    NSMenu *menu = [[NSMenu alloc] init];
    // empty object
    NSMenuItem *emptyMenuItem = [[NSMenuItem alloc] init];
    [emptyMenuItem setTitle:NSLocalizedString(@"空", nil)];
    [menu addItem:emptyMenuItem];
    // seperator
    [menu addItem:[NSMenuItem separatorItem]];
    
    for (AZAppModel *app in self.appsList) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] init];
        menuItem.title = app.appDisplayName;
        NSImage *image = [AZResourceManager imageNamed:app.appIconPath inBundle:[NSBundle bundleWithURL:app.appBundleURL]];
        [image setSize:NSMakeSize(16, 16)];
        menuItem.image = image;
        
        [menu addItem:menuItem];
    }
    
    for (int i = 1000; i < 1010; i++) {
        NSPopUpButton *popUpBtn = [self viewWithTag:i];
        [popUpBtn removeAllItems];
        [popUpBtn setMenu:[menu copy]];
    }
    
    // setup preference
    NSArray *selectedApps = [[AZResourceManager sharedInstance] readSelectedAppsList];
    AZAppModel *app = nil;
    id data = nil;
    for (NSInteger i = 0; i < selectedApps.count; i++) {
        if (i == 0) {
            data = [selectedApps lastObject];
            if ([data isEqualTo:[NSNull null]]) continue;
            app = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            NSPopUpButton *popUpBtn = [self viewWithTag:1000];
            if ([((AZAppModel *)self.appsList[app.index]).appBundleURL isEqualTo:app.appBundleURL]) {
                [popUpBtn selectItemAtIndex:app.index + 2];
            } else {
                for (NSInteger i = 0; i < self.appsList.count; i++) {
                    AZAppModel *temp = self.appsList[i];
                    if ([temp.appBundleURL isEqualTo:app.appBundleURL]) {
                        [popUpBtn selectItemAtIndex:i + 2];
                        break;
                    }
                }
            }
        } else {
            data = selectedApps[i - 1];
            if ([data isEqualTo:[NSNull null]]) continue;
            app = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            NSPopUpButton *popUpBtn = [self viewWithTag:1000 + i];
            if ([((AZAppModel *)self.appsList[app.index]).appBundleURL isEqualTo:app.appBundleURL]) {
                [popUpBtn selectItemAtIndex:app.index + 2];
            } else {
                for (NSInteger i = 0; i < self.appsList.count; i++) {
                    AZAppModel *temp = self.appsList[i];
                    if ([temp.appBundleURL isEqualTo:app.appBundleURL]) {
                        [popUpBtn selectItemAtIndex:i + 2];
                        break;
                    }
                }
            }
        }
    }
}

- (void)selectApp:(id)sender {
    NSPopUpButton *popUpBtn = (NSPopUpButton *)sender;
    NSInteger tag = popUpBtn.tag - 1001;
    NSInteger index = [popUpBtn indexOfSelectedItem];
    
    NSMutableArray *appsArray = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        [appsArray addObject:[NSNull null]];
    }
    
    NSMutableArray *temp = [[[AZResourceManager sharedInstance] readSelectedAppsList] mutableCopy];
    for (int i = 0; i < temp.count; i++) {
        [appsArray replaceObjectAtIndex:i withObject:temp[i]];
    }
    tag = tag < 0 ? 9 : tag;
    if (index == 0) {
        [appsArray replaceObjectAtIndex:tag withObject:[NSNull null]];
    } else {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.appsList[index - 2]];
        [appsArray replaceObjectAtIndex:tag withObject:data];
    }
    
    [[AZResourceManager sharedInstance] saveSelectedApps:appsArray];
    [[AZHotKeyManager sharedInstance] registerHotKey:appsArray];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_WINDOW" object:nil];
}

@end

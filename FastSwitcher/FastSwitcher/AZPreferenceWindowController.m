//
//  AZPreferenceWindowController.m
//  AppShortCut
//
//  Created by Alvin on 13-10-18.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZPreferenceWindowController.h"
#import "AZAppsManager.h"
#import "AZAppModel.h"
#import "AZResourceManager.h"
#import "AZHotKeyManager.h"

@interface AZPreferenceWindowController ()

@property (nonatomic, strong) NSArray *appsList;

@end

@implementation AZPreferenceWindowController

- (id)init {
    self.loginItemEnable = YES;
    self = [super initWithWindowNibName:@"AZPreferenceWindowController"];

    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.loginItemCheckBox bind:@"enabled" toObject:self withKeyPath:@"loginItemEnable" options:nil];

    self.appsList = [[AZAppsManager sharedInstance] getApps];
    
    // setup popupMenu    
    NSMenu *menu = [[NSMenu alloc] init];
    
    // empty object
    NSMenuItem *emptyMenuItem = [[NSMenuItem alloc] init];
    [emptyMenuItem setTitle:NSLocalizedString(@"空", nil)];
    [menu addItem:emptyMenuItem];
    // sep
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
        NSPopUpButton *popUpBtn = [self.window.initialFirstResponder viewWithTag:i];
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

            NSPopUpButton *popUpBtn = [self.window.initialFirstResponder viewWithTag:1000];
            [popUpBtn selectItemAtIndex:app.index + 2];
        } else {
            data = selectedApps[i - 1];
            if ([data isEqualTo:[NSNull null]]) continue;
            app = [NSKeyedUnarchiver unarchiveObjectWithData:data];

            NSPopUpButton *popUpBtn = [self.window.initialFirstResponder viewWithTag:1000 + i];
            [popUpBtn selectItemAtIndex:app.index + 2];
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
}

#pragma mark - login item

- (BOOL)isLoginItemEnable{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"LOGIN_ITEM_ENABLE"];
}

- (void)setLoginItemEnable:(BOOL)loginItemEnable {
    if (self.loginItemEnable != loginItemEnable) {
        [[NSUserDefaults standardUserDefaults] setBool:loginItemEnable forKey:@"LOGIN_ITEM_ENABLE"];
        [self resetLoginItemRegistration];
    }
}

- (void)resetLoginItemRegistration {
    if (self.loginItemEnable) {
        [self addAppAsLoginItem];
    } else {
        [self removeAppFromLoginItem];
    }
}

- (void)addAppAsLoginItem {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of 
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}	
    
	CFRelease(loginItems);
}

- (void)removeAppFromLoginItem {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(int i = 0 ; i < [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(__bridge NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

@end

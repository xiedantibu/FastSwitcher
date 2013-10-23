//
//  AZPreferenceWindowController.h
//  AppShortCut
//
//  Created by Alvin on 13-10-18.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AZPreferenceWindowController : NSWindowController

@property (nonatomic, getter = isLoginItemEnable) BOOL loginItemEnable;
@property (nonatomic, weak) IBOutlet NSButton       *loginItemCheckBox;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app1;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app2;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app3;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app4;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app5;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app6;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app7;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app8;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app9;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app0;

- (IBAction)selectApp:(id)sender;

@end

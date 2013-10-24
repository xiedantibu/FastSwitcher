//
//  AZConfigView.h
//  FastSwitcher
//
//  Created by Alvin on 13-10-24.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MASShortcutView.h>

@interface AZConfigView : NSView

@property (nonatomic, getter = isLoginItemEnable) BOOL  loginItemEnable;
@property (nonatomic, weak) IBOutlet NSButton           *loginItemCheckBox;
@property (nonatomic, weak) IBOutlet MASShortcutView    *shortcutView;

@end

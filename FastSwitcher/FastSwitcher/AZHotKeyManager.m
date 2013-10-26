//
//  AZHotKeyManager.m
//  AppShortCut
//
//  Created by Alvin on 13-10-19.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZHotKeyManager.h"
#import <Carbon/Carbon.h>
#import "AZAppModel.h"
#import "AZResourceManager.h"

/* key codes
 * spacebar 49
 * a        0
 * 1        17
 * F1       122
 * left arrow   123
 * down arrow   125
 * right arrow  124
 * up arrow     126
 * enter        36
 * backspace    51
 * `            50
 */

id AZReg;

@implementation AZHotKeyManager

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);

+ (id)sharedInstance {
    if (!AZReg) {
        AZReg = [[[self class] allocWithZone:nil] init];
    }
    return AZReg;
}

- (void)registerHotKey:(NSArray *)apps {
    [self unregisterHotKey];
    
    EventHotKeyRef  hotKeyRef;
    EventHotKeyID   hotKeyID;
    EventTypeSpec   eventType;
    
    NSMutableArray *array = [NSMutableArray array];
    int keyCodes[] = {18, 19, 20, 21, 23, 22, 26, 28, 25, 29};
    for (unsigned int i = 0; i < 10; i++) {
        if ([apps[i] isEqualTo:[NSNull null]]) continue;
        
        hotKeyID.signature = (OSType)[[NSString stringWithFormat:@"app%u", i] UTF8String];
        hotKeyID.id = i;
        
        RegisterEventHotKey(keyCodes[i], optionKey, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
        NSLog(@"keycode %d", keyCodes[i]);
        if (hotKeyRef != nil) {
            NSData *data = [NSData dataWithBytes:hotKeyRef length:sizeof(EventHotKeyRef)];
            [array addObject:data];
        }
    }
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:array forKey:@"HOT_KEY"];
    [def synchronize];
    
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    InstallApplicationEventHandler(&hotKeyHandler, 1, &eventType, NULL, NULL);
}

- (void)unregisterHotKey {
    EventHotKeyRef  myHotKeyRef;
    
    NSArray *hotKeyRefs = [[NSUserDefaults standardUserDefaults] objectForKey:@"HOT_KEY"];    
    for (NSData *value in hotKeyRefs) {
        [value getBytes:&myHotKeyRef length:sizeof(EventHotKeyRef)];
        UnregisterEventHotKey(myHotKeyRef);
    }
}

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData) {
    EventHotKeyID hotKeyRef;
    GetEventParameter(anEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyRef), NULL, &hotKeyRef);
    
    NSArray *appsArray = [[AZResourceManager sharedInstance] readSelectedAppsList];
    if (appsArray.count < 10 || [appsArray[hotKeyRef.id] isEqual:[NSNull null]]) return noErr;
    
    AZAppModel *app = [NSKeyedUnarchiver unarchiveObjectWithData:appsArray[hotKeyRef.id]];
    
    NSString *pathUrl = nil;
    if (app.isSysApp) {
        pathUrl = [NSString stringWithFormat:@"/System/Library/CoreServices/%@", app.appName];
    } else {
        pathUrl = [NSString stringWithFormat:@"/Applications/%@", app.appName];
    }
    [[NSWorkspace sharedWorkspace] launchApplication:pathUrl];
    return noErr;
}

@end
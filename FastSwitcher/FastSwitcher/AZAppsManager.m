//
//  AZAppsManager.m
//  FastSwitcher
//
//  Created by Alvin on 13-10-22.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZAppsManager.h"
#import "AZAppModel.h"
#import "AZResourceManager.h"

@implementation AZAppsManager

static AZAppsManager *AZAm = nil;

+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AZAm = [[[self class] alloc] init];
    });
    return AZAm;
}

#pragma mark - get Apps

- (NSArray *)getApps {
    NSMutableArray *appsArray = [NSMutableArray array];
    
    NSArray *cachedAppsInfo = [[AZResourceManager sharedInstance] readCachedApps];
    
    if (cachedAppsInfo != nil && cachedAppsInfo.count > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // installed apps
            NSString *appsPath = @"/Applications/";
            if (([[NSFileManager defaultManager] fileExistsAtPath:appsPath])) {
                NSArray *apps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appsPath error:nil];
                NSInteger index = 0;
                for (NSString *name in apps) {
                    if ([name hasSuffix:@".app"]) {
                        AZAppModel *app = [[AZAppModel alloc] init];
                        NSBundle *appBundle = [NSBundle bundleWithPath:[appsPath stringByAppendingPathComponent:name]];
                        NSString *displayName = [[appBundle localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                        NSString *iconName = [[appBundle infoDictionary] objectForKey:@"CFBundleIconFile"];
                        
                        if (displayName == nil) {
                            displayName = [[name componentsSeparatedByString:@".app"] objectAtIndex:0];
                        }
                        app.appBundleURL = appBundle.bundleURL;
                        app.appName = name;
                        app.appDisplayName = name;
                        app.appIconPath = iconName;
                        app.isSysApp = NO;
                        app.index = index++;
                        
                        [appsArray addObject:app];
                    } else {
                        //                NSArray *temp = [self appsForSubFolder:[appsPath stringByAppendingPathComponent:name]];
                        //                if (temp != nil && temp.count > 0) 
                        //                    [appsArray addObjectsFromArray:temp];
                    }
                }
            }
            NSLog(@"save");
            [[AZResourceManager sharedInstance] cacheAllApps:appsArray];
        });
        NSLog(@"get cache");
        return cachedAppsInfo;
    }
    // Depreted method, 
    //    NSArray *arr = nil;
    //    LSInit(1);
    //    _LSCopyAllApplicationURLs(&arr);
    
    // find system apps
    //    NSString *sysAppsPath = @"/System/Library/CoreServices/";
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:sysAppsPath]) {
    //        NSArray *apps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sysAppsPath error:nil];
    //        for (NSString *name in apps) {
    //            if ([name hasSuffix:@".app"]) {
    //                [appsArray addObject:name];
    //            } else {
    //                NSArray *temp = [self appsForSubFolder:[sysAppsPath stringByAppendingPathComponent:name]];
    //                if (temp != nil && temp.count > 0) 
    //                    [appsArray addObjectsFromArray:temp];
    //            }
    //        }
    //    }
    
    // installed apps
    NSString *appsPath = @"/Applications/";
    if (([[NSFileManager defaultManager] fileExistsAtPath:appsPath])) {
        NSArray *apps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appsPath error:nil];
        NSInteger index = 0;
        for (NSString *name in apps) {
            if ([name hasSuffix:@".app"]) {
                AZAppModel *app = [[AZAppModel alloc] init];
                NSBundle *appBundle = [NSBundle bundleWithPath:[appsPath stringByAppendingPathComponent:name]];
                NSString *displayName = [[appBundle localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                NSString *iconName = [[appBundle infoDictionary] objectForKey:@"CFBundleIconFile"];
                
                if (displayName == nil) {
                    displayName = [[name componentsSeparatedByString:@".app"] objectAtIndex:0];
                }
                app.appBundleURL = appBundle.bundleURL;
                app.appName = name;
                app.appDisplayName = displayName;
                app.appIconPath = iconName;
                app.isSysApp = NO;
                app.index = index++;
                
                [appsArray addObject:app];
            } else {
                //                NSArray *temp = [self appsForSubFolder:[appsPath stringByAppendingPathComponent:name]];
                //                if (temp != nil && temp.count > 0) 
                //                    [appsArray addObjectsFromArray:temp];
            }
        }
    }
    [[AZResourceManager sharedInstance] cacheAllApps:appsArray];
    
    return [NSArray arrayWithArray:appsArray];
}

- (NSArray *)appsForSubFolder:(NSString *)path {
    NSMutableArray *apps = [NSMutableArray array];
    BOOL isFolder;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFolder];
    if (isFolder) {
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        for (NSString *name in contents) {
            if ([name hasSuffix:@".app"]) {
                AZAppModel *app = [[AZAppModel alloc] init];
                NSBundle *appBundle = [NSBundle bundleWithPath:[path stringByAppendingPathComponent:name]];
                NSString *displayName = [[appBundle localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                if (displayName == nil) {
                    displayName = [[name componentsSeparatedByString:@".app"] objectAtIndex:0];
                }
                app.appName = name;
                app.appDisplayName = displayName;
                
                [apps addObject:app];
            } 
            else {
                NSArray *temp = [self appsForSubFolder:[path stringByAppendingPathComponent:name]];
                if (temp != nil && temp.count > 0) 
                    [apps addObjectsFromArray:temp];
            }
        }
    }
    return apps;
}

@end

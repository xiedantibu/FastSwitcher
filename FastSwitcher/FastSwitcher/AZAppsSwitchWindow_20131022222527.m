//
//  AZAppsSwitchWindow.m
//  FastSwitcher
//
//  Created by Alvin on 13-10-22.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZAppsSwitchWindow.h"
#import "AZAppModel.h"
#import "AZAppsManager.h"
#import "AZResourceManager.h"
#import "AZAppIconView.h"

#pragma ContentView

CGFloat const iconMargin = 30.0f;
CGFloat const iconOriginY = 20.0f;

@interface AZAppsLaunchContentView : NSView

@property (nonatomic, strong) NSArray *apps;
@property (nonatomic) NSUInteger setupedAppsCount;

@end

@implementation AZAppsLaunchContentView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.apps = [[AZResourceManager sharedInstance] readAppsInfo];
        
        CGFloat originX = iconMargin;
        CGFloat iconSize = [self calculateIconWith:frameRect.size.width];
        
        for (NSUInteger i = 0; i < self.apps.count; i++) {
            if ([self.apps[i] isEqualTo:[NSNull null]]) continue;
            
            AZAppModel *app = [NSKeyedUnarchiver unarchiveObjectWithData:self.apps[i]];
            AZAppIconView *appIcon = [[AZAppIconView alloc] initWithFrame:(NSRect){
                originX,
                iconOriginY,
                iconSize,
                iconSize
            }];
            originX += (iconSize + iconMargin);
            appIcon.image = [AZResourceManager imageNamed:app.appIconPath inBundle:[NSBundle bundleWithURL:app.appBundleURL]];
            [self addSubview:appIcon];
        }
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    NSBezierPath * path;
    path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:15 yRadius:15];
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.3] set];
    [path fill];
}

- (CGFloat)calculateIconWith:(CGFloat)constrainWidth {
    constrainWidth -= (iconMargin * 2);
    return 100.0f;
}

@end

@implementation AZAppsSwitchWindow

- (id)init {
    NSRect rect = [self getScreenResolution];
    rect.origin.y = (rect.size.height - 100 - iconOriginY * 2) / 2;
    rect.size.height = 100 + iconOriginY * 2;
    return [self initWithContentRect:rect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
}

- (id)initWithContentRect:(NSRect)contentRect 
                styleMask:(NSUInteger)aStyle 
                  backing:(NSBackingStoreType)bufferingType 
                    defer:(BOOL)flag {
	if (self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag]) {
		[self setMovableByWindowBackground:NO];
		[self setHasShadow:YES];
		[self setLevel:NSNormalWindowLevel];
        [self setShowsResizeIndicator:NO];
        [self setBackgroundColor:[NSColor clearColor]];
		[self setOpaque:NO];
        
        AZAppsLaunchContentView *contentView = [[AZAppsLaunchContentView alloc] initWithFrame:contentRect];
        [self setContentView:contentView];
    }
	return self;
}

- (void)fadeIn {
    CGFloat alpha = 0;
    [self setAlphaValue:alpha];
    
    // show the window above other apps, but without activate itself
    [self setLevel:NSScreenSaverWindowLevel + 1];
    [self orderFront:nil];
    
    for (int x = 0; x < 10; x++) {
        alpha += 0.1;
        [self setAlphaValue:alpha];
        [NSThread sleepForTimeInterval:0.02];
    }
}

- (void)fadeOut {
    CGFloat alpha = 1;
    [self setAlphaValue:alpha];
    [self makeKeyAndOrderFront:self];
    for (int x = 0; x < 10; x++) {
        alpha -= 0.1;
        [self setAlphaValue:alpha];
        [NSThread sleepForTimeInterval:0.02];
    }
}

- (void)setContentView:(NSView *)aView {
    aView.wantsLayer            = YES;
    aView.layer.frame           = aView.frame;
    aView.layer.cornerRadius    = 20.0;
    aView.layer.masksToBounds   = YES;
    
    [super setContentView:aView];
}

- (NSRect)getScreenResolution {
    NSArray *screenArray = [NSScreen screens];
    NSScreen *mainScreen = [NSScreen mainScreen];
    NSUInteger screenCount = screenArray.count;
    
    for (NSUInteger index = 0; index < screenCount; index++) {
        NSScreen *screen = [screenArray objectAtIndex: index];
        NSRect screenRect = [screen visibleFrame];
        NSString *mString = ((mainScreen == screen) ? @"Main" : @"not-main");
        
        NSLog(@"Screen #%lu (%@) Frame: %@", index, mString, NSStringFromRect(screenRect));
        if (mainScreen == screen) {
            return screenRect;
        }
    }
    return mainScreen.frame;
}

// prevent resize window
- (NSSize)windowWillResize:(NSWindow *) window toSize:(NSSize)newSize {
	if([window showsResizeIndicator])
		return newSize; //resize happens
	else
		return [window frame].size; //no change
}

- (BOOL)windowShouldZoom:(NSWindow *)window toFrame:(NSRect)newFrame {
	//let the zoom happen iff showsResizeIndicator is YES
	return [window showsResizeIndicator];
}

@end

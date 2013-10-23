//
//  AZAppIconView.m
//  AppShortCut
//
//  Created by Alvin on 13-10-21.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZAppIconView.h"

CGFloat const indexLabelWidth = 30.0f;

@implementation AZAppIconView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect index:(NSUInteger)index {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.indexLabel = [[NSTextField alloc] initWithFrame:(NSRect){
            self.frame.size.width - indexLabelWidth, 
            0,
            indexLabelWidth, 
            indexLabelWidth
        }];
        index = (index == 9) ? 0 : index + 1;
        [self.indexLabel setBezeled:NO];
        [self.indexLabel setDrawsBackground:NO];
        [self.indexLabel setEditable:NO];
        [self.indexLabel setSelectable:NO];
        self.indexLabel.font = [NSFont systemFontOfSize:20];
        self.indexLabel.textColor = [NSColor whiteColor];
        self.indexLabel.stringValue = [NSString stringWithFormat:@"%lu", index];
        [self addSubview:self.indexLabel];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
}

@end

//
//  MyBrowser.m
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 12/01/03.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyBrowser.h"

@implementation MyBrowserCell

- (void)setObjectValue:(id<NSCopying>)obj {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = obj;
        if ([dic objectForKey:@"name"]) {
            [super setStringValue:[dic objectForKey:@"name"]];
        }
        if ([dic objectForKey:@"icon"]) {
            NSImage *icon = [dic objectForKey:@"icon"];
            NSSize cellSize = [self cellSize];
            NSSize iconSize = [icon size];
            iconSize.width *= cellSize.height/iconSize.height;
            iconSize.height = cellSize.height;
            [icon setSize:iconSize];
            [super setImage:icon];
        }
    } else {
        [super setObjectValue:obj];
    }
}

@end

@implementation MyBrowser

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setCellClass:[MyBrowserCell class]];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setCellClass:[MyBrowserCell class]];
    }
    return self;
}

@end

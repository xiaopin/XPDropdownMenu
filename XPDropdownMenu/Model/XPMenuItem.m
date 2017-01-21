//
//  XPMenuItem.m
//  https://github.com/xiaopin/XPDropdownMenu
//
//  Created by nhope on 2017/1/19.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPMenuItem.h"

@implementation XPMenuItem

+ (instancetype)itemWithName:(NSString *)name identifier:(NSString *)identifier detail:(NSString *)detail {
    XPMenuItem *item = [[XPMenuItem alloc] init];
    [item setName:name];
    [item setIdentifier:identifier];
    [item setDetail:detail];
    return item;
}

@end

//
//  XPButtonItem.m
//  https://github.com/xiaopin/XPDropdownMenu
//
//  Created by nhope on 2017/1/18.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPButtonItem.h"

@implementation XPButtonItem

+ (instancetype)itemWithName:(NSString *)name {
    return [self itemWithName:name identifier:nil];
}

+ (instancetype)itemWithName:(NSString *)name identifier:(NSString *)identifier {
    XPButtonItem *item = [[XPButtonItem alloc] init];
    item.name = name;
    item.identifier = identifier;
    return item;
}

@end

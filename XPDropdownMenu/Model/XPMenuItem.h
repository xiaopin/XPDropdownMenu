//
//  XPMenuItem.h
//  https://github.com/xiaopin/XPDropdownMenu
//
//  Created by nhope on 2017/1/19.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XPMenuItem : NSObject

/// 标识(当服务器接收的不是名称时,通过给菜单绑定一个标识,最终将该标识发送给服务器)
@property (nonatomic, copy) NSString *identifier;
/// 名称
@property (nonatomic, copy) NSString *name;
/// 详情
@property (nonatomic, copy) NSString *detail;
/// 是否选中
@property (nonatomic, assign, getter=isSelected) BOOL selected;
/// 子菜单数据
@property (nonatomic, strong) NSArray<XPMenuItem*> *subitems;


+ (instancetype)itemWithName:(NSString *)name identifier:(NSString *)identifier detail:(NSString *)detail;

@end

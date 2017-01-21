//
//  XPButtonItem.h
//  https://github.com/xiaopin/XPDropdownMenu
//
//  Created by nhope on 2017/1/18.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XPMenuItem;

@interface XPButtonItem : NSObject

/// 按钮名称(在下拉菜单选中的时候该name会被修改为选中的菜单name,切不可拿name属性来判断身份)
@property (nonatomic, copy) NSString *name;
/// 标识(用户可以给每个item设置唯一的标识用于身份识别)
@property (nonatomic, copy) NSString *identifier;
/// 是否为多菜单,默认`NO`
@property (nonatomic, assign, getter=isMultiplePanel) BOOL multiplePanel;
/// 菜单数据
@property (nonatomic, strong) NSArray<XPMenuItem *> *menuItems;

+ (instancetype)itemWithName:(NSString *)name;
+ (instancetype)itemWithName:(NSString *)name identifier:(NSString *)identifier;

@end

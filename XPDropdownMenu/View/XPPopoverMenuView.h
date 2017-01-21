//
//  XPPopoverMenuView.h
//  https://github.com/xiaopin/XPDropdownMenu
//
//  Created by nhope on 2017/1/19.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPMenuItem;


typedef void(^XPPopoverMenuViewOperationHandler)();


@interface XPPopoverMenuView : UIView

/// 是否为多菜单,默认`NO`
@property (nonatomic, assign, getter=isMultiplePanel) BOOL multiplePanel;
/// 菜单数据
@property (nonatomic, strong) NSArray<XPMenuItem *> *menuItems;


/// 菜单选中后的回调
@property (nonatomic, copy) void(^selectedMenusHandler)(NSArray<XPMenuItem *> *items);
/// 右侧菜单数据为空时的回调
@property (nonatomic, copy) void(^emptyDataOnRightPanelHandler)(XPMenuItem *leftItem, NSInteger index);

//_________________________
//UI相关的block回调
@property (nonatomic, copy) XPPopoverMenuViewOperationHandler willShowHandler;
@property (nonatomic, copy) XPPopoverMenuViewOperationHandler didShowHandler;
@property (nonatomic, copy) XPPopoverMenuViewOperationHandler willHideHandler;
@property (nonatomic, copy) XPPopoverMenuViewOperationHandler didHideHandler;


/// 显示下拉菜单
- (void)showWithYOffset:(CGFloat)offset;
/// 移除下拉菜单
- (void)hide;

/// 刷新右侧菜单数据
- (void)reloadRightPanelData;

@end

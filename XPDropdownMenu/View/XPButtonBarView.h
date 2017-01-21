//
//  XPButtonBarView.h
//  https://github.com/xiaopin/XPDropdownMenu
//
//  Created by nhope on 2017/1/18.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPButtonItem, XPMenuItem, XPButtonBarView;


@protocol XPButtonBarViewDelegate <NSObject>

@optional

/**
 当有两级菜单时,且右侧菜单数据为空时的回调
 用户可以发送网络请求从服务器获取数据,拿到数据后请通过`reloadRightPanelWithItems:atIndex`接口回传数据

 @param barView XPButtonBarView
 @param index   左侧菜单的索引
 @param item    左侧菜单数据
 */
- (void)buttonBarView:(XPButtonBarView *)barView emptyDataAtIndex:(NSInteger)index leftMenuItem:(XPMenuItem *)item;
/// 下拉菜单选中的回调
- (void)buttonBarView:(XPButtonBarView *)barView didSelectedMenus:(NSArray<XPMenuItem *> *)items forButtonItem:(XPButtonItem *)buttonItem;

// **********************UI****************************

/// 下拉菜单即将显示
- (void)buttonBarViewWillShow:(XPButtonBarView *)barView;
/// 下拉菜单显示完毕
- (void)buttonBarViewDidShow:(XPButtonBarView *)barView;
/// 下拉菜单即将消失
- (void)buttonBarViewWillHide:(XPButtonBarView *)barView;
/// 下拉菜单消失完毕
- (void)buttonBarViewDidHide:(XPButtonBarView *)barView;

@end


@interface XPButtonBarView : UIView

@property (nonatomic, weak) id<XPButtonBarViewDelegate> delegate;
/// 导航栏(如果当前控制器有导航栏,请设置该属性为当前导航栏)
@property (nonatomic, weak) UINavigationBar *navigationBar;
/// 按钮数据
@property (nonatomic, strong) NSArray<XPButtonItem *> *buttonItems;


- (void)reloadRightPanelWithItems:(NSArray<XPMenuItem *> *)items atIndex:(NSInteger)index;

/// 重新加载按钮(非必要,设置buttonItems时会自动重新加载)
- (void)reload;

@end

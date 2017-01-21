//
//  XPHelper.h
//  https://github.com/xiaopin/XPDropdownMenu
//
//  Created by nhope on 2017/1/18.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#ifndef XPHelper_h
#define XPHelper_h

#import <UIKit/UIKit.h>

/// 处理Block循环引用
#define weakify(obj)    autoreleasepool{} __weak __typeof(obj) weak##obj = obj;
#define strongify(obj)  autoreleasepool{} __strong __typeof(obj) obj = weak##obj;

/// RGB转颜色
UIKIT_STATIC_INLINE UIColor* xp_colorWithRGB(CGFloat r, CGFloat g, CGFloat b)
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

/// 加载图片
UIKIT_STATIC_INLINE UIImage* xp_loadImage(NSString *name)
{
    if (![name hasSuffix:@".png"]) {
        name = [name stringByAppendingFormat:@"@%@.png",([UIScreen mainScreen].scale==3.0?@"3x":@"2x")];
    }
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"XPMenuResource" ofType:@"bundle"]];
    NSString *path = [bundle pathForResource:name ofType:nil];
    return [UIImage imageWithContentsOfFile:path];
}

/// 颜色转图片
UIKIT_STATIC_INLINE UIImage* xp_color2image(UIColor *color, CGSize imageSize)
{
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, (CGRect){CGPointZero, imageSize});
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/// 文字选中颜色
#define TEXT_SELECTED_COLOR         xp_colorWithRGB(0.0, 180.0, 164.0)
/// 文字普通状态下的颜色
#define TEXT_NORMAL_COLOR           xp_colorWithRGB(30.0, 30.0, 30.0)
/// 详情文字普通状态下的颜色
#define DETAIL_TEXT_NORMAL_COLOR    xp_colorWithRGB(142.0, 142.0, 147.0)
/// 表格cell选中的颜色
#define TABLEVIEW_CELL_SELECTED_COLOR   xp_colorWithRGB(245.0, 242.0, 246.0)

/// 按钮文字大小
#define BUTTON_TEXT_FONT_SIZE   15.0
/// 下拉菜单文字大小
#define TEXT_FONT_SIZE          15.0
/// 下拉菜单描述文字大小
#define DETAIL_TEXT_FONT_SIZE   12.0

/// 左侧面板的宽度占比
#define LEFT_PANEL_WIDTH_SCALE  0.4

#endif /* XPHelper_h */

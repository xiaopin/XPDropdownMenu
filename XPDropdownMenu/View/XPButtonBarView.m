//
//  XPButtonBarView.m
//  https://github.com/xiaopin/XPDropdownMenu
//
//  Created by nhope on 2017/1/18.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPButtonBarView.h"
#import "XPPopoverMenuView.h"

#import "XPButtonItem.h"
#import "XPMenuItem.h"
#import "XPHelper.h"


#pragma mark -

@interface XPBarButton : UIButton

@end

@implementation XPBarButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = CGRectGetHeight(self.frame);
    CGSize textSize = self.titleLabel.frame.size;
    CGSize imageSize = self.imageView.frame.size;
    self.titleLabel.frame = CGRectMake((CGRectGetWidth(self.frame)-textSize.width-imageSize.width-5.0)/2,
                                       (height-textSize.height)/2,
                                       textSize.width,
                                       textSize.height);
    self.imageView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame)+5.0,
                                      (height-imageSize.height)/2,
                                      imageSize.width,
                                      imageSize.height);
}

@end


#pragma mark -

@interface XPButtonBarView ()

@property (nonatomic, strong) UIView *buttonContainerView;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, strong) XPPopoverMenuView *menuView;

@end

@implementation XPButtonBarView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUserInterface];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureUserInterface];
}

#pragma mark - Actions

- (void)buttonAction:(UIButton *)sender {
    if (sender == _selectedButton) {
        _selectedButton.selected = NO;
        _selectedButton = nil;
        [_menuView hide];
        return;
    }
    
    _selectedButton.selected = NO;
    sender.selected = YES;
    _selectedButton = sender;
    
    CGFloat offset = CGRectGetHeight(self.frame)+(_navigationBar?64.0:0.0);
    XPButtonItem *item = _buttonItems[sender.tag];
    self.menuView.multiplePanel = item.multiplePanel;
    self.menuView.menuItems = item.menuItems;
    [self.menuView showWithYOffset:offset];
}

#pragma mark - Public

- (void)reload {
    // remove old button.
    [_buttonContainerView removeConstraints:_buttonContainerView.constraints];
    [_buttonContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (0 == _buttonItems.count) return;
    
    // re-add button.
    CGFloat widthMultiplier = 1.0/_buttonItems.count;
    [_buttonItems enumerateObjectsUsingBlock:^(XPButtonItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        XPBarButton *button = [XPBarButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:item.name forState:UIControlStateNormal];
        [button setTitleColor:TEXT_NORMAL_COLOR forState:UIControlStateNormal];
        [button setTitleColor:TEXT_SELECTED_COLOR forState:UIControlStateSelected];
        [button setImage:xp_loadImage(@"icon-down") forState:UIControlStateNormal];
        [button setImage:xp_loadImage(@"icon-up") forState:UIControlStateSelected];
        [button.titleLabel setFont:[UIFont systemFontOfSize:BUTTON_TEXT_FONT_SIZE]];
        [button setTag:idx]; // bind the index.
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonContainerView addSubview:button];
        
        // AutoLayout
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSArray *constraints =
        @[
          [NSLayoutConstraint constraintWithItem:button
                                       attribute:NSLayoutAttributeLeft
                                       relatedBy:NSLayoutRelationEqual
                                          toItem:_buttonContainerView
                                       attribute:(idx==0?NSLayoutAttributeLeft:NSLayoutAttributeRight)
                                      multiplier:(idx==0?1.0:widthMultiplier*idx)
                                        constant:0.0],
          [NSLayoutConstraint constraintWithItem:button
                                       attribute:NSLayoutAttributeTop
                                       relatedBy:NSLayoutRelationEqual
                                          toItem:_buttonContainerView
                                       attribute:NSLayoutAttributeTop
                                      multiplier:1.0
                                        constant:0.0],
          [NSLayoutConstraint constraintWithItem:button
                                       attribute:NSLayoutAttributeWidth
                                       relatedBy:NSLayoutRelationEqual
                                          toItem:_buttonContainerView
                                       attribute:NSLayoutAttributeWidth
                                      multiplier:widthMultiplier
                                        constant:0],
          [NSLayoutConstraint constraintWithItem:button
                                       attribute:NSLayoutAttributeHeight
                                       relatedBy:NSLayoutRelationEqual
                                          toItem:_buttonContainerView
                                       attribute:NSLayoutAttributeHeight
                                      multiplier:1.0
                                        constant:0.0]
          ];
        [_buttonContainerView addConstraints:constraints];
    }];
}

- (void)reloadRightPanelWithItems:(NSArray<XPMenuItem *> *)items atIndex:(NSInteger)index {
    XPMenuItem *item = _menuView.menuItems[index];
    item.subitems = items;
    [_menuView reloadRightPanelData];
}

#pragma mark - Private

- (void)configureUserInterface {
    self.backgroundColor = xp_colorWithRGB(254.0, 251.0, 255.0);
    _buttonContainerView = [[UIView alloc] init];
    _buttonContainerView.backgroundColor = [UIColor clearColor];
    _buttonContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_buttonContainerView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buttonContainerView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_buttonContainerView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buttonContainerView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(_buttonContainerView)]];
    
    UIView *separatorLine = [[UIView alloc] init];
    separatorLine.backgroundColor = xp_colorWithRGB(234.0, 231.0, 234.0);
    separatorLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:separatorLine];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[separatorLine]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(separatorLine)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorLine(==0.5)]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(separatorLine)]];
}

#pragma mark - setter & getter

- (void)setButtonItems:(NSArray<XPButtonItem *> *)buttonItems {
    _buttonItems = buttonItems;
    [self reload];
}

- (XPPopoverMenuView *)menuView {
    if (nil == _menuView) {
        @weakify(self);
        _menuView = [[XPPopoverMenuView alloc] init];
        _menuView.willShowHandler = ^{
            @strongify(self);
            [self.navigationBar setUserInteractionEnabled:NO];
            if ([self.delegate respondsToSelector:@selector(buttonBarViewWillShow:)]) {
                [self.delegate buttonBarViewWillShow:self];
            }
        };
        _menuView.didShowHandler = ^{
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(buttonBarViewDidShow:)]) {
                [self.delegate buttonBarViewDidShow:self];
            }
        };
        _menuView.willHideHandler = ^{
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(buttonBarViewWillHide:)]) {
                [self.delegate buttonBarViewWillHide:self];
            }
        };
        _menuView.didHideHandler = ^{
            @strongify(self);
            self.selectedButton.selected = NO;
            self.selectedButton = nil;
            [self.navigationBar setUserInteractionEnabled:YES];
            if ([self.delegate respondsToSelector:@selector(buttonBarViewDidHide:)]) {
                [self.delegate buttonBarViewDidHide:self];
            }
        };
        _menuView.selectedMenusHandler = ^(NSArray<XPMenuItem *> *items){
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(buttonBarView:didSelectedMenus:forButtonItem:)]) {
                NSInteger index = self.selectedButton.tag;
                XPButtonItem *buttonItem = self.buttonItems[index];
                if (items.lastObject.name.length) {
                    buttonItem.name = items.lastObject.name;
                    [self.selectedButton setTitle:buttonItem.name forState:UIControlStateNormal];
                    [self.selectedButton setTitle:buttonItem.name forState:UIControlStateSelected];
                }
                [self.delegate buttonBarView:self didSelectedMenus:items forButtonItem:buttonItem];
            }
        };
        _menuView.emptyDataOnRightPanelHandler = ^(XPMenuItem *item, NSInteger index) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(buttonBarView:emptyDataAtIndex:leftMenuItem:)]) {
                [self.delegate buttonBarView:self emptyDataAtIndex:index leftMenuItem:item];
            }
        };
    }
    return _menuView;
}

@end

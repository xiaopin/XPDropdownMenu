//
//  XPPopoverMenuView.m
//  https://github.com/xiaopin/XPDropdownMenu
//
//  Created by nhope on 2017/1/19.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "XPPopoverMenuView.h"
#import "XPMenuItem.h"
#import "XPHelper.h"

typedef NS_ENUM(NSInteger, XPPopoverMenuViewTableViewTag) {
    XPPopoverMenuViewTableViewTagLeft   = 1,
    XPPopoverMenuViewTableViewTagRight  = 2
};


@interface XPPopoverMenuView ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *leftTableView;
@property (nonatomic, strong) UITableView *rightTableView;
@property (nonatomic, assign) NSInteger selectedIndexInLeftPanel;
@property (nonatomic, weak) XPMenuItem *selectedItemInLeftPanel;
@property (nonatomic, weak) XPMenuItem *selectedItemInRightPanel;

@end


@implementation XPPopoverMenuView

static CGFloat const TABLEVIEW_CELL_HEIGHT = 40.0;
static NSTimeInterval const ANIMATION_DURATION = 0.25;

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        [self addSubview:self.contentView];
        
        _selectedIndexInLeftPanel = -1;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [tap setDelegate:self];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == XPPopoverMenuViewTableViewTagLeft) {
        return self.menuItems.count;
    } else if (tableView.tag == XPPopoverMenuViewTableViewTagRight &&
               _multiplePanel && _selectedIndexInLeftPanel != -1) {
        NSInteger count = self.menuItems[_selectedIndexInLeftPanel].subitems.count;
        if (0 == count) {
            if (nil != self.emptyDataOnRightPanelHandler) {
                XPMenuItem *item = _menuItems[_selectedIndexInLeftPanel];
                self.emptyDataOnRightPanelHandler(item, _selectedIndexInLeftPanel);
            }
        }
        return count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = TABLEVIEW_CELL_SELECTED_COLOR;
        
        cell.textLabel.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:DETAIL_TEXT_FONT_SIZE];
        
        UIView *separatorLine = [[UIView alloc] init];
        separatorLine.translatesAutoresizingMaskIntoConstraints = NO;
        separatorLine.backgroundColor = xp_colorWithRGB(234.0, 231.0, 234.0);
        [cell addSubview:separatorLine];
        
        NSMutableArray<NSLayoutConstraint*> *constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[separatorLine]|" options:NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing metrics:nil views:NSDictionaryOfVariableBindings(separatorLine)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorLine(==0.5)]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(separatorLine)]];
        [cell addConstraints:constraints];
    }
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    XPMenuItem *item = nil;
    if (tableView.tag == XPPopoverMenuViewTableViewTagLeft) {
        item = _menuItems[indexPath.row];
        if (item.selected) {
            _selectedIndexInLeftPanel = indexPath.row;
            if (_multiplePanel) {
                [_rightTableView reloadData];
            }
            if (_selectedItemInLeftPanel != item) {
                _selectedItemInLeftPanel.selected = NO;
                _selectedItemInLeftPanel = item;
            }
        }
        cell.backgroundColor = [UIColor whiteColor];
    } else if (tableView.tag == XPPopoverMenuViewTableViewTagRight) {
        item = _menuItems[_selectedIndexInLeftPanel].subitems[indexPath.row];
        if (item.selected && _selectedItemInRightPanel != item) {
            _selectedItemInRightPanel.selected = NO;
            _selectedItemInRightPanel = item;
        }
        cell.backgroundColor = xp_colorWithRGB(243.0, 240.0, 244.0);
    }
    NSString *icon = item.selected ? @"icon-selected" : @"icon-unselected";
    cell.imageView.image = (_multiplePanel && tableView.tag==XPPopoverMenuViewTableViewTagLeft) ? nil : xp_loadImage(icon);
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.detail;
    if (item.selected) {
        cell.textLabel.textColor = TEXT_SELECTED_COLOR;
        cell.detailTextLabel.textColor = TEXT_SELECTED_COLOR;
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        cell.textLabel.textColor = TEXT_NORMAL_COLOR;
        cell.detailTextLabel.textColor = DETAIL_TEXT_NORMAL_COLOR;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isNeedReload = NO;
    if (tableView.tag == XPPopoverMenuViewTableViewTagLeft) {
        if (nil != _selectedItemInLeftPanel) {
            _selectedItemInLeftPanel.selected = NO;
            _selectedItemInLeftPanel = nil;
            isNeedReload = YES;
        }
    } else if (tableView.tag == XPPopoverMenuViewTableViewTagRight) {
        if (nil != _selectedItemInRightPanel) {
            _selectedItemInRightPanel.selected = NO;
            _selectedItemInRightPanel = nil;
            isNeedReload = YES;
        }
    }
    
    if (isNeedReload && tableView.indexPathForSelectedRow) {
        UITableViewCell *oldSelectedCell = [tableView cellForRowAtIndexPath:tableView.indexPathForSelectedRow];
        oldSelectedCell.textLabel.textColor = TEXT_NORMAL_COLOR;
        oldSelectedCell.detailTextLabel.textColor = DETAIL_TEXT_NORMAL_COLOR;
        [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];
    }
    
    UITableViewCell *newSelectedCell = [tableView cellForRowAtIndexPath:indexPath];
    newSelectedCell.textLabel.textColor = TEXT_SELECTED_COLOR;
    newSelectedCell.detailTextLabel.textColor = TEXT_SELECTED_COLOR;
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == XPPopoverMenuViewTableViewTagLeft) {
        XPMenuItem *item = _menuItems[indexPath.row];
        if (item != _selectedItemInLeftPanel) {
            _selectedItemInLeftPanel.selected = NO;
            item.selected = YES;
            _selectedItemInLeftPanel = item;
        }
        if (_multiplePanel) {
            _selectedIndexInLeftPanel = indexPath.row;
            [_rightTableView reloadData];
            if (nil != _selectedItemInRightPanel) {
                _selectedItemInRightPanel.selected = NO;
                _selectedItemInRightPanel = nil;
            }
        } else {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            if (nil != self.selectedMenusHandler) {
                self.selectedMenusHandler(@[item]);
                [self hide];
            }
        }
    } else if (tableView.tag == XPPopoverMenuViewTableViewTagRight) {
        if (nil != self.selectedMenusHandler) {
            XPMenuItem *leftItem = _menuItems[_selectedIndexInLeftPanel];
            XPMenuItem *rightItem = leftItem.subitems[indexPath.row];
            if (rightItem != _selectedItemInRightPanel) {
                _selectedItemInRightPanel.selected = NO;
                rightItem.selected = YES;
                _selectedItemInRightPanel = rightItem;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            self.selectedMenusHandler(@[leftItem, rightItem]);
            [self hide];
        }
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self;
}

#pragma mark - Public

- (void)showWithYOffset:(CGFloat)offset {
    // reset flag data
    _selectedIndexInLeftPanel = -1;
    _selectedItemInLeftPanel = nil;
    _selectedItemInRightPanel = nil;
    
    if (nil == self.superview) {
        if (nil != self.willShowHandler) {
            self.willShowHandler();
        }
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self];
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.frame = CGRectMake(0.0, offset, screenSize.width, screenSize.height-offset);
        [self showAnimationNeedCallback:YES];
    } else {
        CGRect frame = _contentView.frame;
        frame.origin.y = -frame.size.height;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self.contentView setFrame:frame];
        } completion:^(BOOL finished) {
            [self showAnimationNeedCallback:NO];
        }];
    }
}

#pragma mark - Private

- (void)showAnimationNeedCallback:(BOOL)isNeed {
    [_leftTableView reloadData];
    [_rightTableView reloadData];
    
    CGFloat contentWidth = CGRectGetWidth(self.frame);
    CGFloat contentHeight = CGRectGetHeight(self.frame)-100.0;
    if (_multiplePanel == NO) {
        contentHeight = MIN(contentHeight, _menuItems.count*TABLEVIEW_CELL_HEIGHT);
    }
    CGRect frame = CGRectMake(0.0, -contentHeight, contentWidth, contentHeight);
    [_contentView setFrame:frame];
    
    if (_multiplePanel) {
        _leftTableView.frame = CGRectMake(0.0, 0.0, contentWidth*LEFT_PANEL_WIDTH_SCALE, contentHeight);
        _rightTableView.frame = CGRectMake(CGRectGetMaxX(_leftTableView.frame),
                                           0.0,
                                           contentWidth*(1.0-LEFT_PANEL_WIDTH_SCALE),
                                           contentHeight);
    } else {
        _leftTableView.frame = (CGRect){CGPointZero, frame.size};
        _rightTableView.frame = CGRectZero;
    }
    
    frame.origin.y = 0;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.alpha = 1.0;
        [self.contentView setFrame:frame];
    } completion:^(BOOL finished) {
        if (isNeed && nil != self.didShowHandler) {
            self.didShowHandler();
        }
    }];
}

- (void)hide {
    if (nil != self.willHideHandler) {
        self.willHideHandler();
    }
    CGRect rect = _contentView.frame;
    rect.origin.y = -CGRectGetHeight(rect);
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.contentView.frame = rect;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            // reset flag data.
            self.selectedIndexInLeftPanel = 0;
            self.selectedItemInLeftPanel = nil;
            self.selectedItemInRightPanel = nil;
            
            [self removeFromSuperview];
            if (nil != self.didHideHandler) {
                self.didHideHandler();
            }
        }];
    }];
}

- (void)reloadRightPanelData {
    [_rightTableView reloadData];
}

#pragma mark - setter & getter

- (UIView *)contentView {
    if (nil == _contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        [_contentView addSubview:self.leftTableView];
        [_contentView addSubview:self.rightTableView];
    }
    return _contentView;
}

- (UITableView *)leftTableView {
    if (nil == _leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _leftTableView.dataSource = self;
        _leftTableView.delegate = self;
        _leftTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _leftTableView.rowHeight = TABLEVIEW_CELL_HEIGHT;
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _leftTableView.tag = XPPopoverMenuViewTableViewTagLeft;
    }
    return _leftTableView;
}

- (UITableView *)rightTableView {
    if (nil == _rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _rightTableView.dataSource = self;
        _rightTableView.delegate = self;
        _rightTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _rightTableView.rowHeight = TABLEVIEW_CELL_HEIGHT;
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _rightTableView.backgroundColor = xp_colorWithRGB(243.0, 240.0, 244.0);
        _rightTableView.tag = XPPopoverMenuViewTableViewTagRight;
    }
    return _rightTableView;
}

@end

//
//  ViewController.m
//  Example
//
//  Created by nhope on 2017/1/18.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "ViewController.h"
#import "XPButtonBarView.h"

#import "XPButtonItem.h"
#import "XPMenuItem.h"

@interface ViewController ()<XPButtonBarViewDelegate>

@property (nonatomic, strong) NSArray<XPButtonItem *> *buttonItems;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, MAXFLOAT, 50.0)];
    view.backgroundColor = [UIColor purpleColor];
    self.tableView.tableHeaderView = view;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld-%ld",indexPath.section,indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (1 == section) {
        XPButtonBarView *headerView = [[XPButtonBarView alloc] init];
        headerView.delegate = self;
        headerView.navigationBar = self.navigationController.navigationBar;
        headerView.buttonItems = self.buttonItems;
        
        return headerView;
    }
    return nil;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (1 == section) {
        return 40.0;
    }
    return 0.0;
}

#pragma mark - <XPButtonBarViewDelegate>

- (void)buttonBarViewWillShow:(XPButtonBarView *)barView {
    CGRect rect = [self.tableView convertRect:barView.frame toView:barView.superview];
    // 如果有导航栏并且automaticallyAdjustsScrollViewInsets为YES时,请偏移-64pt
    [self.tableView setContentOffset:CGPointMake(0.0, rect.origin.y-64.0) animated:NO];
    self.tableView.scrollEnabled = NO;
    self.tableView.scrollsToTop = NO;
}

- (void)buttonBarViewDidHide:(XPButtonBarView *)barView {
    self.tableView.scrollEnabled = YES;
    self.tableView.scrollsToTop = YES;
}

- (void)buttonBarView:(XPButtonBarView *)barView didSelectedMenus:(NSArray<XPMenuItem *> *)items forButtonItem:(XPButtonItem *)buttonItem {
    NSString *result = buttonItem.identifier;
    for (XPMenuItem *item in items) {
        result = [result stringByAppendingFormat:@"-%@", item.name];
    }
    NSLog(@"%@", result);
    [[[UIAlertView alloc] initWithTitle:result message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)buttonBarView:(XPButtonBarView *)barView emptyDataAtIndex:(NSInteger)index leftMenuItem:(XPMenuItem *)item {
    // 右侧数据为空,可以在此发送数据
    NSLog(@"%ld-%@", index, item.name);
    
    // 这里可以显示一个HUD到keyWindow,禁止用户点击其他菜单按钮
    [[[UIAlertView alloc] initWithTitle:@"正在请求网络，请稍等，5秒后将出现数据。" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    
    // 注意block循环引用,这里演示就不处理了
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // 模拟网络请求回来的数据
            NSMutableArray *subitems = [NSMutableArray array];
            for (int j=0; j<MAX(arc4random_uniform(20), 5); j++) {
                XPMenuItem *subitem = [XPMenuItem itemWithName:[NSString stringWithFormat:@"%@-商圈%d",item.name,j]
                                                    identifier:nil
                                                        detail:[NSString stringWithFormat:@"%u", arc4random_uniform(1000)]];
                [subitems addObject:subitem];
            }
            // 将数据回传给下拉菜单
            [barView reloadRightPanelWithItems:subitems atIndex:index];
        });
    });

}

#pragma mark - Actions

- (IBAction)barButtonItemAction:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - setter & getter

- (NSArray<XPButtonItem *> *)buttonItems {
    if (nil == _buttonItems) {
        XPButtonItem *item1 = [XPButtonItem itemWithName:@"全部" identifier:@"all"];
        item1.menuItems = @[
                            [XPMenuItem itemWithName:@"甜点饮品" identifier:nil detail:@"2843"],
                            [XPMenuItem itemWithName:@"生日蛋糕" identifier:nil detail:@"43"],
                            [XPMenuItem itemWithName:@"火锅" identifier:nil detail:@"243"],
                            [XPMenuItem itemWithName:@"自助餐" identifier:nil detail:@"843"],
                            [XPMenuItem itemWithName:@"小吃快餐" identifier:nil detail:@"53"],
                            [XPMenuItem itemWithName:@"日韩料理" identifier:nil detail:@"843"],
                            [XPMenuItem itemWithName:@"西餐" identifier:nil detail:@"787"],
                            [XPMenuItem itemWithName:@"聚餐宴请" identifier:nil detail:@"245"],
                            ];
        [[item1.menuItems firstObject] setSelected:YES];
        
        XPButtonItem *item2 = [XPButtonItem itemWithName:@"附近" identifier:@"location"];
        XPMenuItem *fujin = [XPMenuItem itemWithName:@"附近" identifier:nil detail:nil];
        // 附近的数据固定
        fujin.subitems = @[
                           [XPMenuItem itemWithName:@"1km" identifier:nil detail:nil],
                           [XPMenuItem itemWithName:@"2km" identifier:nil detail:nil],
                           [XPMenuItem itemWithName:@"3km" identifier:nil detail:nil],
                           [XPMenuItem itemWithName:@"4km" identifier:nil detail:nil],
                           [XPMenuItem itemWithName:@"5km" identifier:nil detail:nil],
                           [XPMenuItem itemWithName:@"6km" identifier:nil detail:nil]
                           ];
        
        // 宝安区的商圈也固定
        XPMenuItem *area1 = [XPMenuItem itemWithName:@"宝安区" identifier:nil detail:nil];
        area1.subitems = @[
                           [XPMenuItem itemWithName:@"商圈1" identifier:nil detail:@"28"],
                           [XPMenuItem itemWithName:@"商圈2" identifier:nil detail:@"0"],
                           [XPMenuItem itemWithName:@"商圈3" identifier:nil detail:@"98"],
                           ];
        // 区域的商圈数据需要请求服务器,则不设置subitems即可
        XPMenuItem *area2 = [XPMenuItem itemWithName:@"南山区" identifier:nil detail:nil];
        XPMenuItem *area3 = [XPMenuItem itemWithName:@"罗湖区" identifier:nil detail:nil];
        XPMenuItem *area4 = [XPMenuItem itemWithName:@"龙华新区" identifier:nil detail:nil];
        NSMutableArray<XPMenuItem*> *marray = [NSMutableArray arrayWithObjects:fujin, area1, area2, area3, area4, nil];
        
        item2.multiplePanel = YES;
        item2.menuItems = marray;
        [[marray firstObject] setSelected:YES];
        [[[marray firstObject].subitems firstObject] setSelected:YES];
        
        XPButtonItem *item3 = [XPButtonItem itemWithName:@"智能排序" identifier:@"order"];
        item3.menuItems = @[
                            [XPMenuItem itemWithName:@"智能排序" identifier:nil detail:nil],
                            [XPMenuItem itemWithName:@"离我最近" identifier:nil detail:nil],
                            [XPMenuItem itemWithName:@"好评优先" identifier:nil detail:nil],
                            [XPMenuItem itemWithName:@"人气最高" identifier:nil detail:nil]
                            ];
        [[item3.menuItems lastObject] setSelected:YES];
        
        _buttonItems = @[item1, item2, item3];
    }
    return _buttonItems;
}


@end

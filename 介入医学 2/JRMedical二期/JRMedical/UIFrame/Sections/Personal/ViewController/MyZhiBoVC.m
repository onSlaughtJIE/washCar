//
//  MyZhiBoVC.m
//  JRMedical
//
//  Created by a on 16/12/21.
//  Copyright © 2016年 idcby. All rights reserved.
//

#import "MyZhiBoVC.h"
#import "HuiFangTableViewCell.h"
#import "EasePublishModel.h"
#import <SDCycleScrollView.h>
#import "UITableView+EmpayData.h"
#import "HuiFangPlayViewController.h"

@interface MyZhiBoVC ()

@end

@implementation MyZhiBoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的直播";
    
    //
    self.tableView.backgroundColor = BG_Color;
    self.tableView.separatorColor = BG_Color;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HuiFangTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
//    UIView *foot = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, Width_Screen, 60))];
//    foot.backgroundColor = BG_Color;
//    self.tableView.tableFooterView = foot;
    
    [self GetLiveVideoList];
}

#pragma mark - Table view datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.dataSource == nil) {
        [tableView tableViewDisplayWitMsg:@"" ifNecessaryForRowCount:self.dataSource.count];
    }
    else {
        [tableView tableViewDisplayWitMsg:@"暂无相关直播信息!" ifNecessaryForRowCount:self.dataSource.count];
    }
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EasePublishModel *model = self.dataSource[indexPath.row];
    
    HuiFangTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.layer.shadowColor = [UIColor blackColor].CGColor;// 阴影颜色
    cell.layer.shadowOffset = CGSizeMake(0, 0);// 偏移距离
    cell.layer.shadowOpacity = 0.5; // 不透明度
    cell.layer.shadowRadius = 5; // 半径
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setHuiFangCellWithModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 290;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EasePublishModel *model = self.dataSource[indexPath.row];
    HuiFangPlayViewController *videoVC = [[HuiFangPlayViewController alloc] init];
    videoVC.VideoUri = model.VideoUri;
    videoVC.VideoName = model.Title;
    [self presentViewController:videoVC animated:YES completion:nil];
}

#pragma mark - 获取直播间列表
- (void)GetLiveVideoList {

    NSString *url = @"api/Customer/MyVideo";
    NSString *params = @"";
    
    [self showLoadding:@"正在加载" time:20];
    [self loadDataApi:url withParams:params refresh:RefreshTypeBoth model:EasePublishModel.class];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

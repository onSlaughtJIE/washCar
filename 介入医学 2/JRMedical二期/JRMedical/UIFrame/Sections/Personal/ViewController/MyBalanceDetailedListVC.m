//
//  MyBalanceDetailedListVC.m
//  JRMedical
//
//  Created by a on 16/12/20.
//  Copyright © 2016年 idcby. All rights reserved.
//

#import "MyBalanceDetailedListVC.h"

#import "MyBalanceDetailedListCell.h"
#import "MyBalanceDetailedListModel.h"

#import "UITableView+EmpayData.h"

@interface MyBalanceDetailedListVC ()

@end

@implementation MyBalanceDetailedListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"消费明细";
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 86, 0, 0);
    self.tableView.backgroundColor = BG_Color;
    [self.tableView registerClass:[MyBalanceDetailedListCell class] forCellReuseIdentifier:NSStringFromClass([MyBalanceDetailedListCell class])];
     
    [self requestListDataArrray];
}

#pragma mark - 请求数据列表
- (void)requestListDataArrray {
    NSString *url = @"api/Customer/CustomerAccountMoney";
    NSString *params = @"";
    [self showLoadding:@"正在加载" time:20];
    [self loadDataApi:url withParams:params refresh:RefreshTypeBoth model:MyBalanceDetailedListModel.class];
}

#pragma mark - Table view datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource == nil) {
        [tableView tableViewDisplayWitMsg:@"" ifNecessaryForRowCount:self.dataSource.count];
    }
    else {
        [tableView tableViewDisplayWitMsg:@"暂无消费记录信息!" ifNecessaryForRowCount:self.dataSource.count];
    }
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyBalanceDetailedListModel *model = self.dataSource[indexPath.row];
    
    MyBalanceDetailedListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MyBalanceDetailedListCell class]) forIndexPath:indexPath];
    [cell setModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001;
}

#pragma mark  点击cell的响应的代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

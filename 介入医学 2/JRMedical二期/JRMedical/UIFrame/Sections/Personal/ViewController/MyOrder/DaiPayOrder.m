//
//  DaiPayOrder.m
//  JRMedical
//
//  Created by a on 16/12/22.
//  Copyright © 2016年 idcby. All rights reserved.
//

#import "DaiPayOrder.h"

#import "MyOrderCell.h"
#import "MyOrderModel.h"
#import "PayOrderVC.h"
#import "OrderDetailVC.h"

#import "UITableView+EmpayData.h"
#import <YYKit.h>

@interface DaiPayOrder ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DaiPayOrder {
    
    NSInteger _section;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BianJiOrderDetail" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BianJiOrderDetailClick) name:@"BianJiOrderDetail" object:nil];
    
    [self.view addSubview:self.tableView];
    
    [self requestListDataArrray];
}

- (void)BianJiOrderDetailClick {
    [self requestListDataArrray];
}

#pragma mark - 请求数据列表
- (void)requestListDataArrray {
    
    NSString *url = @"api/Customer/GetOrderLst";
    NSString *params = [NSString stringWithFormat:@"ZICBDYCOpeType=%@",@"NoPay"];
    
    self.pageSize = 10;//一次加载8条数据
    self.tableType = 1;//TableView表类
    self.baseTableView = self.tableView;//将本类表 赋值给父类去操作
    [self showLoadding:@"" time:20];
    [self loadDataApi:url withParams:params refresh:RefreshTypeBoth model:MyOrderModel.class];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataSource == nil) {
        [tableView tableViewDisplayWitMsg:@"" ifNecessaryForRowCount:self.dataSource.count];
    }
    else {
        [tableView tableViewDisplayWitMsg:@"暂无待支付订单信息!" ifNecessaryForRowCount:self.dataSource.count];
        
    }
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MyOrderModel *model = [self.dataSource objectAtIndex:section];
    return model.LstOrderDetail.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyOrderModel *model = [self.dataSource objectAtIndex:indexPath.section];
    
    NSDictionary *orderDic = model.LstOrderDetail[indexPath.row];
    
    MyOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myOrderCell" forIndexPath:indexPath];
    cell.backgroundColor = BG_Color;
    
    cell.lineView.hidden = YES;
    
    [cell setOrderDic:orderDic];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    MyOrderModel *model = [self.dataSource objectAtIndex:section];
    
    UIView *header = [UIView new];
    header.backgroundColor = [UIColor whiteColor];
    
    UILabel *stateLab = [UILabel new];
    stateLab.textColor = Main_Color;
    stateLab.textAlignment = NSTextAlignmentRight;
    if ([model.OrderState isEqualToString:@"1"]) {
        stateLab.text = @"等待买家付款";
    }
    else if ([model.OrderState isEqualToString:@"2"]) {
        stateLab.text = @"买家已付款";
    }
    else if ([model.OrderState isEqualToString:@"3"]) {
        stateLab.text = @"卖家已发货";
    }
    else if ([model.OrderState isEqualToString:@"4"]) {
        stateLab.text = @"交易成功";
    }
    stateLab.font = [UIFont systemFontOfSize:14];
    [header addSubview:stateLab];
    stateLab.sd_layout.centerYEqualToView(header).rightSpaceToView(header,10).widthIs(120).heightIs(14);
    
    UILabel *orderNo = [UILabel new];
    orderNo.textColor = [UIColor lightGrayColor];
    orderNo.text = [NSString stringWithFormat:@"订单 : %@",model.OrderNO];
    orderNo.font = [UIFont systemFontOfSize:14];
    [header addSubview:orderNo];
    orderNo.sd_layout.centerYEqualToView(header).leftSpaceToView(header,10).rightSpaceToView(stateLab,10).heightIs(14);
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    MyOrderModel *model = [self.dataSource objectAtIndex:section];
    
    UIView *footer = [UIView new];
    footer.backgroundColor = BG_Color;
    
    UIView *topView = [UIView new];
    topView.backgroundColor = [UIColor whiteColor];
    [footer addSubview:topView];
    topView.sd_layout.topSpaceToView(footer,0).leftSpaceToView(footer,0).rightSpaceToView(footer,0).heightIs(40);
    
    UILabel *priceLab = [UILabel new];
    priceLab.textColor = [UIColor lightGrayColor];
    priceLab.text = [NSString stringWithFormat:@"¥%.2f",[model.PayMoneyAmount floatValue]];
    priceLab.font = [UIFont systemFontOfSize:14];
    [topView addSubview:priceLab];
    CGSize size = [Utils sizeForTitle:priceLab.text withFont:[UIFont systemFontOfSize:14]];
    priceLab.sd_layout.centerYEqualToView(topView).rightSpaceToView(topView,10).widthIs(size.width).heightIs(14);
    
    UILabel *numLab = [UILabel new];
    numLab.textColor = [UIColor lightGrayColor];
    numLab.text = [NSString stringWithFormat:@"共%ld件商品",model.LstOrderDetail.count];
    numLab.font = [UIFont systemFontOfSize:14];
    numLab.textAlignment = NSTextAlignmentRight;
    [topView addSubview:numLab];
    numLab.sd_layout.centerYEqualToView(topView).rightSpaceToView(priceLab,10).leftSpaceToView(topView,10).heightIs(14);
    
    UIView *botView = [UIView new];
    botView.backgroundColor = [UIColor whiteColor];
    botView.hidden = YES;
    [footer addSubview:botView];
    botView.sd_layout.topSpaceToView(topView,0.6).leftSpaceToView(footer,0).rightSpaceToView(footer,0).heightIs(60);
    
    UIButton *sure = [UIButton buttonWithType:UIButtonTypeSystem];
    sure.userInteractionEnabled = YES;
    sure.layer.borderColor = Main_Color.CGColor;
    sure.layer.borderWidth = 1;
    sure.clipsToBounds = YES;
    sure.layer.cornerRadius = 5;
    [sure setTitleColor:Main_Color forState:UIControlStateNormal];
    [botView addSubview:sure];
    sure.sd_layout.centerYEqualToView(botView).rightSpaceToView(botView,10).widthIs(80).heightIs(40);
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    cancel.userInteractionEnabled = YES;
    
    cancel.layer.borderColor = BG_Color.CGColor;
    cancel.layer.borderWidth = 1;
    cancel.clipsToBounds = YES;
    cancel.layer.cornerRadius = 5;
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [botView addSubview:cancel];
    cancel.sd_layout.centerYEqualToView(botView).rightSpaceToView(sure,10).widthIs(80).heightIs(40);
    
    if ([model.OrderState isEqualToString:@"1"]) {
        [sure setTitle:@"付款" forState:(UIControlStateNormal)];
        [cancel setTitle:@"取消订单" forState:(UIControlStateNormal)];
        
        [sure bk_whenTapped:^{
            NSDictionary *orderDic = @{@"PayPrice":model.PayMoneyAmount,@"OrderNO":model.OrderNO};
            
            PayOrderVC *poVC = [PayOrderVC new];
            poVC.orderDic = orderDic;
            poVC.from = @"订单列表";
            [self.navigationController pushViewController:poVC animated:YES];
        }];
        
        [cancel bk_whenTapped:^{
            _section = section;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"取消订单"
                                                                message:@"您确认要取消这条订单么?"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确认",nil];
            [alertView show];
        }];
    }
    else if ([model.OrderState isEqualToString:@"3"]) {
        [sure setTitle:@"确认收货" forState:(UIControlStateNormal)];
        [cancel setTitle:@"查看物流" forState:(UIControlStateNormal)];
    }
    else if ([model.OrderState isEqualToString:@"4"]) {
        sure.hidden = YES;
        [cancel setTitle:@"删除订单" forState:(UIControlStateNormal)];
        cancel.sd_layout.centerYEqualToView(botView).rightSpaceToView(botView,10).widthIs(80).heightIs(40);
    }
    
    if ([model.OrderState isEqualToString:@"1"] || [model.OrderState isEqualToString:@"3"] || [model.OrderState isEqualToString:@"4"]) {
        botView.hidden = NO;
    }
    else {
        botView.hidden = YES;
    }
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    MyOrderModel *model = [self.dataSource objectAtIndex:section];
    if ([model.OrderState isEqualToString:@"1"] || [model.OrderState isEqualToString:@"3"] || [model.OrderState isEqualToString:@"4"]) {
        return 110;
    }
    else {
        return 50;
    }
}

#pragma mark  点击cell的响应的代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyOrderModel *model = [self.dataSource objectAtIndex:indexPath.section];
    OrderDetailVC *odVC = [OrderDetailVC new];
    odVC.orderNO = model.OrderNO;
    [self.navigationController pushViewController:odVC animated:YES];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        MyOrderModel *model = [self.dataSource objectAtIndex:_section];
        
        NSString *params = [NSString stringWithFormat:@"ZICBDYCOrderNO=%@",model.OrderNO];
        NSString *url = @"api/Customer/CancelOrder";
        
        [self showLoadding:@"正在取消" time:20];
        
        [self loadDataApi:url withParams:params block:^(int code, BOOL isSuccess, NSObject *modelData) {
            
            NSDictionary *dataDic = (NSDictionary *)modelData;
            NSLog(@"取消订单--------%@",dataDic);
            if (isSuccess) {
                [self.dataSource removeObjectAtIndex:_section];
                [self.tableView reloadData];
            }
            else {
                NSString *msg  = [dataDic objectForKey:@"Msg"];
                if (msg!=nil && ![msg isEqual:@""]) {
                    [self showMessage:msg];
                }else{
                    [self showMessage:[NSString stringWithFormat:@"请求失败 #%d",code]];
                }
            }
        }];
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, Width_Screen, Height_Screen-108) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor  = [UIColor clearColor];
        _tableView.backgroundColor = BG_Color;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        [_tableView registerNib:[UINib nibWithNibName:@"MyOrderCell" bundle:nil] forCellReuseIdentifier:@"myOrderCell"];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

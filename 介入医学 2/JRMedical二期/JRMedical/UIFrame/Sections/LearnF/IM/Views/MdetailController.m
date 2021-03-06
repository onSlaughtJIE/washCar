//
//  MdetailController.m
//  JRMedical
//
//  Created by apple on 16/6/24.
//  Copyright © 2016年 ZC. All rights reserved.
//

#import "MdetailController.h"
#import "ChatViewController.h"
#import "LGAlertView.h"

// 不是好友, 进入这个界面

@interface MdetailController ()<UIAlertViewDelegate, LGAlertViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nickName;
@property (strong, nonatomic) IBOutlet UITextField *hxid;
@property (strong, nonatomic) IBOutlet UIImageView *usepic;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *sex;
@property (weak, nonatomic) IBOutlet UITextField *area;
@property (weak, nonatomic) IBOutlet UITextField *hospital;
@property (weak, nonatomic) IBOutlet UITextField *keshi;
@property (weak, nonatomic) IBOutlet UIButton *beizhuBtn;

@property (nonatomic, strong) NSString *picurl;
@property (nonatomic, strong) NSString *phonenum;
@property (nonatomic, strong) NSString *nickname;

@property (nonatomic, strong) UIAlertView *alert;
@property (strong, nonatomic) LGAlertView *securityAlertView;


@end

@implementation MdetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人信息";
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"jiaxin"] style:(UIBarButtonItemStylePlain) target:self action:@selector(memaddAction:)];
    
    [self getUSerMessage];
    
    [self.beizhuBtn addTarget:self action:@selector(addBeizhu) forControlEvents:(UIControlEventTouchUpInside)];
}


- (void)addBeizhu {
    
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    if ([_userid isEqualToString:loginUsername]) {
        self.beizhuBtn.userInteractionEnabled = NO;
        return;
    } else {
        self.beizhuBtn.userInteractionEnabled = YES;
    }
    
    self.securityAlertView = [[LGAlertView alloc] initWithTextFieldsAndTitle:@"添加备注"
                                                                     message:@""
                                                          numberOfTextFields:1
                                                      textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
                                                          if (index == 0) {
                                                              textField.placeholder = @"请填写备注";
                                                          }
                                                          
                                                          textField.tag = index;
                                                          textField.delegate = self;
                                                          textField.enablesReturnKeyAutomatically = YES;
                                                          textField.autocapitalizationType = NO;
                                                          textField.autocorrectionType = NO;
                                                      }
                                                                buttonTitles:@[@"完成"]
                                                           cancelButtonTitle:@"取消"
                                                      destructiveButtonTitle:nil
                                                                    delegate:self];
    
    [self.securityAlertView setButtonEnabled:YES atIndex:0];
    [self.securityAlertView showAnimated:YES completionHandler:nil];
    
}

- (void)memaddAction:(UIBarButtonItem *)sender {
    NSLog(@"添加好友");
    
    
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    if ([_userid isEqualToString:loginUsername]) {
        [self alertShowWithString:@"您不能加自己为好友"];
        return;
    }
    
    NSArray *buddyList = [[EMClient sharedClient].contactManager getContacts];
    for (NSString *buddy in buddyList) {
        
         if ([_userid isEqualToString:buddy]){
             [self alertShowWithString:@"他(她)已经是您的好友了"];
             return;
        }
        
    }
    
    EMError *error = [[EMClient sharedClient].contactManager addContact:_userid message:@"我想加您为好友"];
    if (!error) {
        NSLog(@"添加好友");
        [self alertShowWithString:@"好友申请发送成功！"];
    } else {
        [self alertShowWithString:@"好友申请发送失败！"];
    }
}

- (void)alertShowWithString:(NSString *)string {
    _alert = [[UIAlertView alloc]initWithTitle:string
                                       message:nil
                                      delegate:self
                             cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];
    [_alert show];
}

- (void)dismissAlert {
    
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
}



- (void)getUSerMessage {
//    /IM/GetCustomerInfoByID
    NSString *urlS = [NSString stringWithFormat:@"%@/api/IM/GetCustomerInfoByID", Server_Int_Url];
    NSString *dataS = [NSString stringWithFormat:@"%@DevIdentity=%@ZICBDYCDevSysInfo=%@ZICBDYCDevTypeInfo=%@ZICBDYCIMEI=%@ZICBDYCID=%@", kPrefixPara, kDevIdentity, kDevSysInfo, kDevTypeInfo, kIMEI, _userid, nil];
    NSString *dataEncrpyt = [TWDes encryptWithContent:dataS type:kDesType key:kDesKey];
    NSString *token = [UserInfo getAccessToken];
    NSDictionary *paraDic = @{kToken:token, kDatas:dataEncrpyt};
    
    [AFManegerHelp POST:urlS parameters:paraDic success:^(id responseObjeck) {
        
        NSLog(@"MdetailController - GetCustomerInfoByID - %@", responseObjeck);
        if ([responseObjeck[@"Success"] integerValue] == 1) {
            NSArray *array = responseObjeck[@"JsonData"];
            for (NSDictionary *d in array) {
                self.picurl = d[@"UserPic"];
                self.phonenum = d[@"ID"];
                self.nickname = d[@"NickName"];
                [self configureAllViews];
                
                self.name.text = [NSString stringWithFormat:@"姓   名 : %@", d[@"XingMing"]];
                self.area.text = [NSString stringWithFormat:@"地   区 : %@", d[@"Region"]];
                self.hospital.text = [NSString stringWithFormat:@"医   院 : %@", d[@"HospitalName"]];
                self.keshi.text = [NSString stringWithFormat:@"科   室 : %@", d[@"DepartmentName"]];
                [self.beizhuBtn setTitle:[NSString stringWithFormat:@"备  注 : %@", d[@"Memo"]] forState:(UIControlStateNormal)];
                
                if ([d[@"Sex"] integerValue] == 1) {
                    self.sex.text = [NSString stringWithFormat:@"性   别 : 男"];
                } else {
                    self.sex.text = [NSString stringWithFormat:@"性   别 : 女"];
                }
                
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"cuowu%@", error);
    }];
}



- (void)configureAllViews {
    self.nickName.text = [NSString stringWithFormat:@"昵   称 : %@", _nickname];
    self.hxid.text = [NSString stringWithFormat:@"会员ID : %@", _phonenum];
    [self.usepic sd_setImageWithURL:[NSURL URLWithString:_picurl] placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
}


// 加为好友
- (IBAction)chatwithmember:(UIButton *)sender {
    
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    if ([_userid isEqualToString:loginUsername]) {
        [self alertShowWithString:@"您不能加自己为好友"];
        return;
    }
    
    NSArray *buddyList = [[EMClient sharedClient].contactManager getContacts];
    for (NSString *buddy in buddyList) {
        
        if ([_userid isEqualToString:buddy]){
            [self alertShowWithString:@"他(她)已经是您的好友了"];
            return;
        }
        
    }
    
    EMError *error = [[EMClient sharedClient].contactManager addContact:_userid message:@"我想加您为好友"];
    if (!error) {
        [self alertShowWithString:@"好友申请发送成功！"];
    } else {
        [self alertShowWithString:@"好友申请发送失败！"];
    }

}



#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark - LGAlertViewDelegate

- (void)alertView:(LGAlertView *)alertView buttonPressedWithTitle:(NSString *)title index:(NSUInteger)index {
    NSLog(@"action {title: %@, index: %lu}", title, (long unsigned)index);
    
    UITextField *field = self.securityAlertView.textFieldsArray[index];
    NSLog(@"field field - %@", field.text);
    
    if ([Utils isBlankString:field.text]) {
        [self showHint:@"请填写备注"];
        
    } else {
        
        NSString *urlS = [NSString stringWithFormat:@"%@/api/IM/AddCustomeMemo", Server_Int_Url];
        NSString *dataS = [NSString stringWithFormat:@"%@DevIdentity=%@ZICBDYCDevSysInfo=%@ZICBDYCDevTypeInfo=%@ZICBDYCIMEI=%@ZICBDYCFriendID=%@ZICBDYCMemo=%@", kPrefixPara, kDevIdentity, kDevSysInfo, kDevTypeInfo, kIMEI, _userid, field.text, nil];
        NSString *dataEncrpyt = [TWDes encryptWithContent:dataS type:kDesType key:kDesKey];
        NSString *token = [UserInfo getAccessToken];
        NSDictionary *paraDic = @{kToken:token, kDatas:dataEncrpyt};
        
        [self showHudInView:self.view hint:@""];
        [AFManegerHelp POST:urlS parameters:paraDic success:^(id responseObjeck) {
            NSLog(@"AddCustomeMemo - %@", responseObjeck);
            [self hideHud];
            if ([responseObjeck[@"Success"] integerValue] == 1) {
                [self showHint:@"添加成功"];
                [self.beizhuBtn setTitle:[NSString stringWithFormat:@"备  注 : %@", field.text] forState:(UIControlStateNormal)];
            }
            
        } failure:^(NSError *error) {
            [self hideHud];
            NSLog(@"cuowu%@", error);
        }];
    }
    
    
    
}

- (void)alertViewCancelled:(LGAlertView *)alertView {
    NSLog(@"cancel");
}

- (void)alertViewDestructiveButtonPressed:(LGAlertView *)alertView {
    NSLog(@"destructive");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

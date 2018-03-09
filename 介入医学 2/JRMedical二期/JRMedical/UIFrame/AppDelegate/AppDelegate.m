//
//  AppDelegate.m
//  JRMedical
//
//  Created by a on 16/11/4.
//  Copyright © 2016年 idcby. All rights reserved.
//

#import "AppDelegate.h"

#import "RootTabBarController.h"
#import "JRLoginViewController.h"
#import "JPushTzDetailVC.h"
#import "IQKeyboardManager.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//支付宝SDK头文件
#import <AlipaySDK/AlipaySDK.h>

#import "LNLocationManager.h"
#import "LNSearchManager.h"
#import "ApplyViewController.h"

// 开屏广告
#import "AppDelegate+XHLaunchAd.h"

// 环信推送
#import "AppDelegate+EaseMob.h"
#define EaseMobAppKey @"idcby#jieruyixue"

// 极光推送
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
static NSString *const jPushTestDemoAppID = @"0543750c25ff00d4e8c3c298";
static NSString *const publishChannel = @"APP Store";

@interface AppDelegate ()<CLLocationManagerDelegate,WXApiDelegate, UNUserNotificationCenterDelegate, JPUSHRegisterDelegate>

@property (nonatomic, strong) LNLocationManager *locationManager;
@property (nonatomic, strong) LNSearchManager *searchManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }
    
    [self loadRootVC];//加载跟视图
    
    
    // 添加开屏广告
    [self setupXHLaunchAd];
    
    // 初始化IQ键盘设置
    [self IQKeyboardManagerInit];
    
    // shareSDK
    [self setShareSdk];
    
    // 极光推送
    [self setJPushWith:application Options:launchOptions];
    
    // 环信设置
    [self setHuanXinWith:application Options:launchOptions];

    [self getDingWeiInfo];//开启定位
    
    //微信支付
    [self setWinXinPay];
    
    
    
    return YES;
}

//#ifdef REDPACKET_AVALABLE

#pragma mark - Alipay

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //    [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:nil];
}
// NOTE: iOS9.0之前使用的API接口
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
        }];
    }
    else
    {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    //if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
    //
    //        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
    //            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
    //            NSLog(@"result = %@",resultDic);
    //        }];
    //    }
    
    return YES;
}
// NOTE: iOS9.0之后使用新的API接口
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
{
    NSLog(@"iOS9.0之后使用新的API接口");
    
    NSString *urlStr = [url absoluteString];
    NSString *headStr = [urlStr substringWithRange:NSMakeRange(0, 2)]; //微信
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"alipay_resultdic - %@", resultDic);
            //            [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAliPayCallBackInfo object:nil userInfo:resultDic];
            
        }];
    }
    //这里判断是否发起的请求为微信支付，如果是的话，用WXApi的方法调起微信客户端的支付页面
    else if ([headStr isEqualToString:@"wx"] && [url.host isEqualToString:@"pay"]) {
        NSLog(@"iOS9.0之后使用新的API接口 - options");
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

//#endif

#pragma mark - 设置微信支付
- (void)setWinXinPay {
    
    //向微信注册wx8548fa7bed61ebe4
    [WXApi registerApp:@"wx8548fa7bed61ebe4" withDescription:@"JRMedical"];
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{// iOS9之后,这个方法已废弃不走
    NSLog(@"handleOpenURL");
    return  [WXApi handleOpenURL:url delegate:self];
}
//微信SDK自带的方法，处理从微信客户端完成操作后返回程序之后的回调方法
- (void)onResp:(BaseResp *)resp
{
    NSLog(@"onResp:(BaseResp *)resp ");
    
    if ([resp isKindOfClass:[PayResp class]]) {
        if (resp.errCode == 0) {
//                @"支付成功"
        }
        else {
            if (resp.errCode == -2) {
//                @"退出支付"
            }
            else {
//                @"支付失败"
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kWeixin_pay_result_success object:@(resp.errCode)];
    }
}

#pragma mark - 获取定位信息
- (void)getDingWeiInfo {
    
    //请求获取定位信息
    [self.locationManager startWithBlock:^{
        
    } completionBlock:^(CLLocation *location) {
        [self.searchManager startReverseGeocode:location completeionBlock:^(LNLocationGeocoder *locationGeocoder, NSError *error) {
            if (!error) {
                NSMutableString *cityString = [NSMutableString stringWithFormat:@"%@",locationGeocoder.city];
                NSMutableString *provinceString = [NSMutableString stringWithFormat:@"%@",locationGeocoder.province];
                
                NSUserDf_Set(cityString, kCity);//城市
                NSUserDf_Set(provinceString, kProvince);//省份
                
                NSLog(@"%@---%@",cityString,provinceString);
            }
            else {
                NSLog(@"%ld",error.code);
            }
        }];
    } failure:^(CLLocation *location, NSError *error) {
        NSLog(@"%ld",error.code);
    }];
}
- (LNLocationManager*)locationManager{
    if (_locationManager == nil) {
        _locationManager = [[LNLocationManager alloc] init];
    }
    return _locationManager;
}
- (LNSearchManager*)searchManager{
    if (_searchManager == nil) {
        _searchManager = [[LNSearchManager alloc] init];
    }
    return _searchManager;
}

#pragma mark - 环信设置
- (void)setHuanXinWith:(UIApplication *)application Options:(NSDictionary *)launchOptions{
    
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"jryx_develop";
#else
    apnsCertName = @"jryx_product";
#endif
    
    NSLog(@"apnsCertName - %@", apnsCertName);
    
    EMOptions *options = [EMOptions optionsWithAppkey:EaseMobAppKey];
    options.apnsCertName = apnsCertName;
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    [[EMClient sharedClient] updatePushOptionsToServer]; 
    options.isAutoAcceptFriendInvitation = NO;
    options.isAutoAcceptGroupInvitation = NO;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *appkey = [ud stringForKey:@"identifier_appkey"];
    if (!appkey) {
        appkey = EaseMobAppKey;
        [ud setObject:appkey forKey:@"identifier_appkey"];
    }
    
    [self easemobApplication:application
didFinishLaunchingWithOptions:launchOptions
                      appkey:appkey
                apnsCertName:apnsCertName
                 otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    
    //iOS8以上 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    
    NSLog(@"环信用户%@^^^^密码%@",NSUserDf_Get(kHXName),NSUserDf_Get(kHXPwd));
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] loginWithUsername:NSUserDf_Get(kHXName) password:NSUserDf_Get(kHXPwd)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!error) {
                
                [AFManegerHelp getUserMessage];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                
                // 加载数据
                [self asyncConversationFromDB];
                
                NSLog(@"环信登录成功");
                [[ApplyViewController shareController] loadDataSourceFromLocalDB];
                
                
            } else {
                NSLog(@"环信登录失败---------%d", error.code);
            }
        });
    });
}

- (void)asyncConversationFromDB
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[EMClient sharedClient].chatManager getAllConversations];
        [array enumerateObjectsUsingBlock:^(EMConversation *conversation, NSUInteger idx, BOOL *stop){
            if(conversation.latestMessage == nil){
                [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId isDeleteMessages:NO completion:nil];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakself.conversationListVC) {
                NSLog(@"12344");
//                [weakself.conversationListVC refreshDataSource];
            }
            
            if (weakself.mainController) {
//                [weakself.mainController setupUnreadMessageCount];
                NSLog(@"1eeee2344");
            }
        });
    });
    
}


#pragma mark - 初始化跟视图
-  (void)loadRootVC {
    
    NSString *isLoginStr = NSUserDf_Get(JRIsLogin);
    if ([isLoginStr isEqualToString:kYesLogin]) {
        RootTabBarController *main = [[RootTabBarController alloc]init];
        self.window.rootViewController = main;
    }
    else {
        
        JRLoginViewController *loginVC = [[JRLoginViewController alloc] init];
        self.window.rootViewController = loginVC;
    }
}

#pragma mark -  设置屏幕横屏关键
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (_allowRotation == 1) {
        return UIInterfaceOrientationMaskAll;
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

#pragma mark - ShareSDK SetUp
- (void)setShareSdk {
    
    [ShareSDK registerApp:@"12f542624ded2"
     
          activePlatforms:@[
                            @(SSDKPlatformSubTypeWechatSession),
                            @(SSDKPlatformSubTypeWechatTimeline),
                            @(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 // 97223a00fc19e5439f2a4a7afaf7470e
                 [appInfo SSDKSetupWeChatByAppId:@"wx8548fa7bed61ebe4"
                                       appSecret:@"97223a00fc19e5439f2a4a7afaf7470e"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"1105340901"
                                      appKey:@"19ruZgNdUyzpNuzu"
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
     }];
    
}


#pragma mark - 初始化IQKeyboardManager
- (void)IQKeyboardManagerInit {
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [[IQKeyboardManager sharedManager] setShouldToolbarUsesTextFieldTintColor:YES];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
}

#pragma mark - 极光推送
- (void)setJPushWith:(UIApplication *)application Options:(NSDictionary *)launchOptions {
    
    
    // 设置别名
    [JPUSHService setAlias:NSUserDf_Get(kHXName) callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
    
    //
    /*
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification)
    {   // 程序完全退出时，添加需求。。。
        NSString *str = [Utils jsonFromDictionary:remoteNotification];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"程序完全退出后通过点击通知进入App"
                                                        message:str
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    */
    
    
    // 注册apns通知
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) // iOS10
    {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
#endif
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) // iOS8, iOS9
    {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    }
    
    /*
     *  launchingOption 启动参数.
     *  appKey 一个JPush 应用必须的,唯一的标识.
     *  channel 发布渠道. 可选.
     *  isProduction 是否生产环境. 如果为开发状态,设置为 NO; 如果为生产状态,应改为 YES.
     *  advertisingIdentifier 广告标识符（IDFA） 如果不需要使用IDFA，传nil.
     * 此接口必须在 App 启动时调用, 否则 JPush SDK 将无法正常工作.
     */
    
    // 如不需要使用IDFA，advertisingIdentifier 可为nil
    // 生产: 1  测试: 0
    // 注册极光推送
    [JPUSHService setupWithOption:launchOptions appKey:jPushTestDemoAppID channel:publishChannel apsForProduction:0 advertisingIdentifier:nil];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0)
        {
            // iOS10获取registrationID放到这里了, 可以存到缓存里, 用来标识用户单独发送推送
            NSLog(@"registrationID获取成功：%@",registrationID);
            [[NSUserDefaults standardUserDefaults] setObject:registrationID forKey:@"registrationID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
}

/*
#pragma mark *** 注册APNs成功并上报DeviceToken ***

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
//    NSLog(@"Appdelegate - deviceToken - %@", deviceToken);
//    [JPUSHService registerDeviceToken:deviceToken];
}


#pragma mark *** 实现注册APNs失败接口（可选） ***
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
*/

#pragma mark *** 添加处理APNs通知回调方法 ***
#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support 处于前台时接收到通知
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
    }
    // 程序运行时收到通知，先弹出消息框
//    [self getPushMessageAtStateActive:userInfo];
    
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support 点击处理事件
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
        //推送打开
        NSLog(@"iOS10后台 - userInfo - %@", userInfo);
        if (userInfo)
        {
            // 取得 APNs 标准信息内容
            //            NSDictionary *aps = [userInfo valueForKey:@"aps"];
            //            NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
            //            NSInteger badge = [[aps valueForKey:@"badge"] integerValue]; //badge数量
            //            NSString *sound = [aps valueForKey:@"sound"]; //播放的声音
            
            // 添加各种需求。。。。。
            [self pushToViewControllerWhenClickPushMessageWith:userInfo];
            
            [JPUSHService handleRemoteNotification:userInfo];
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }
    completionHandler();  // 系统要求执行这个方法
}

// iOS7 及以上接收到通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    NSLog(@"didReceiveRemoteNotification fetchCompletionHandler = %@", userInfo);
    if ([userInfo isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = userInfo[@"aps"];
        NSString *content = dict[@"alert"];
        NSLog(@"content = %@", content);
    }
    if (application.applicationState == UIApplicationStateActive)
    {
        // 程序当前正处于前台
        NSLog(@"程序处于前台运行");
//        [self getPushMessageAtStateActive:userInfo];
        
    }
    else if (application.applicationState == UIApplicationStateInactive)
    { 
        // 程序处于后台
        NSLog(@"程序处于后台"); // 点击通知之后才会走
        [self pushToViewControllerWhenClickPushMessageWith:userInfo];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[EMClient sharedClient] applicationDidEnterBackground:application];
    
    // 清除角标
    [[UIApplication alloc] setApplicationIconBadgeNumber:0];
    // 清空JPush服务器中存储的badge值
    [JPUSHService setBadge:0];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[EMClient sharedClient] applicationWillEnterForeground:application];
    
    // 点击之后 badge清零
    [application setApplicationIconBadgeNumber:0];
    // 清空JPush服务器中存储的badge值
    [JPUSHService setBadge:0];
    [[UNUserNotificationCenter alloc] removeAllPendingNotificationRequests];
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        if (conversation.type == EMConversationTypeChat) {
            unreadCount += conversation.unreadMessagesCount;
        }
    }
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}


// 基于iOS 6 及以下的系统版本
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (_mainController) {
        [_mainController jumpToChatList];
    }
    [self easemobApplication:application didReceiveRemoteNotification:userInfo];
    
    // Required,For systems with less than or equal to iOS6
    NSLog(@"didReceiveRemoteNotification - userInfo - %@", userInfo);
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (_mainController) {
        [_mainController didReceiveLocalNotification:notification];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    [self easemobApplication:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    if (_mainController) {
        [_mainController didReceiveUserNotification:response.notification];
    }
    completionHandler();
}


- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
    
    NSString *callbackString = [NSString stringWithFormat:@"%d, \ntags: %@, \nalias: %@\n", iResCode, tags, alias];
    
    NSLog(@"TagsAlias回调:%@", callbackString);
}


// 如果在程序运行时收到通知，这时消息栏不会显示通知，所以如果想让用户收到通知的话，应该是给用户一个弹框提醒，告诉用户有消息通知,当用户点击提示框中的确认查看按钮时，跳转到指定的页面
#pragma mark -- 程序运行时收到通知
-(void)getPushMessageAtStateActive:(NSDictionary *)pushMessageDic{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:[[pushMessageDic objectForKey:@"aps"]objectForKey:@"alert"]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"查看"
                                                            style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                                
                                                                [self pushToViewControllerWhenClickPushMessageWith:pushMessageDic];
                                                            }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                               
                                                           }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    
    
}

// 跳转到指定页面的方法。跳转到指定页面的话，可能会需要某些参数，这时可以根后台商定，根据参数跳转到相应的页面，同时也让后台把你需要的参数返回来。比如我和后台商定根据“pageType”这个参数确定跳转的页面。如果是跳转到次级页面，这里重要的是要找到正确的viewcontroller，用controller的nav进行push新页面。比如我的DetailViewController是用tabar的第一个item中的FirstViewController的nav进行push出来的，那么，当我点击通知消息想到跳转到DetailViewController,只要找到FirstViewController就可以了。
-(void)pushToViewControllerWhenClickPushMessageWith:(NSDictionary*)msgDic{
    
    
    if ([[msgDic objectForKey:@"PushType"] integerValue]==1){
        
        // 跳转到第一个tabbarItem，这时直接设置 UITabBarController的selectedIndex属性就可以
//        self.tabController.selectedIndex = 0;
        
        if ([self.window.rootViewController isKindOfClass:[RootTabBarController class]]) {
            
            RootTabBarController *mainTab = (RootTabBarController *)self.window.rootViewController;
            mainTab.selectedIndex = 2;
            [[NSNotificationCenter defaultCenter] postNotificationName:kJPushWithAdd object:nil];
            
        } else {
            NSLog(@"未登录");
        }
        
        
        
    }else if ([[msgDic objectForKey:@"PushType"] integerValue]==2){
        //详情，这是从跳转到第一个tabbarItem跳转过去的，所以我们可以先让tabController.selectedIndex =0;然后找到VC的nav。
        
        if ([self.window.rootViewController isKindOfClass:[RootTabBarController class]]) {
            
            RootTabBarController *mainTab = (RootTabBarController *)self.window.rootViewController;
            mainTab.selectedIndex = 4;
            
            NSLog(@"postID - %@", [msgDic objectForKey:@"PostID"]);
            
            NSString *postIDStr = [NSString stringWithFormat:@"%@", [msgDic objectForKey:@"PostID"]];
            
            if (![Utils isBlankString:postIDStr]) {
                JPushTzDetailVC * VC = [[JPushTzDetailVC alloc] init];
                VC.jPushPostID = postIDStr;
                BaseNavigationController *nav = (BaseNavigationController *)mainTab.viewControllers[4];
                [nav pushViewController:VC animated:NO];
            }
            
        } else {
            NSLog(@"未登录");
        }
        
    }
}


@end

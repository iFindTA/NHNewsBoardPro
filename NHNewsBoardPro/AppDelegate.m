//
//  AppDelegate.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/1.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "AppDelegate.h"
#import "NHDefaultVCR.h"
#import "NHDiscoveryVCR.h"
#import "NHPersonalVCR.h"
#import "SloppySwiper.h"
#import "NHSetsEngine.h"
@interface AppDelegate ()

@property (nonatomic, strong) SloppySwiper *defaultSloppy, *faxianSloppy, *mineSloppy, *globalSloppy;

@end

@implementation AppDelegate


//- (void)copyBundleDBToSandbox {
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"NHINFO" ofType:@"DB"];
//    if ([NSString pb_isNull:filePath]) {
//        return ;
//    }
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *dbPath = [NHDBEngine dbPath];
//    NSError *error = nil;
//    if (![fileManager fileExistsAtPath:dbPath]) {
//        if ([fileManager copyItemAtPath:filePath toPath:dbPath error:&error] != YES) {
//            NSLog(@"failed to copy file at :%@",[error localizedDescription]);
//        }else{
//            NSLog(@"success to copy file !");
//        }
//    }else{
//        NSLog(@"sandbox file had exit !");
//    }
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //初始化DB
    [NHDBEngine share];
    NSString *path = [NHDBEngine dbPath];
    NSLog(@"app db path :%@",path);
    // application configure
    [[NHSetsEngine share] configure];
    /// custom read mode
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL nightMode = [[userDefaults objectForKey:NHLaunchModeKey] boolValue];
    if (nightMode) {
        [DKNightVersionManager nightFalling];
    }else{
        [DKNightVersionManager dawnComing];
    }
    /// init window
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:mainBounds];
    self.window.backgroundColor = NHWhiteColor;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    //    NSDictionary *naviAttrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    //    [[UINavigationBar appearance] setTitleTextAttributes:naviAttrs];
    //    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    //    [[UINavigationBar appearance] setNormalBarTintColor:NHNaviBarTintColor];
    //    [[UINavigationBar appearance] setNightBarTintColor:NHNightBgColor];
    NHDefaultVCR *index = [[NHDefaultVCR alloc] init];
    //UINavigationController *defaultNavi = [[UINavigationController alloc] initWithRootViewController:index];
    //defaultNavi.navigationBar.translucent = true;
    //SloppySwiper *defaultSloppy = [[SloppySwiper alloc] initWithNavigationController:defaultNavi];
    //defaultNavi.delegate = defaultSloppy;
    //_defaultSloppy = defaultSloppy;
    
    NHDiscoveryVCR *faxian = [[NHDiscoveryVCR alloc] init];
    //    UINavigationController *faxianNavi = [[UINavigationController alloc] initWithRootViewController:faxian];
    //    SloppySwiper *faxianSloppy = [[SloppySwiper alloc] initWithNavigationController:faxianNavi];
    //    faxianNavi.delegate = faxianSloppy;
    //    _faxianSloppy = faxianSloppy;
    
    NHPersonalVCR *mine = [[NHPersonalVCR alloc] init];
    //    UINavigationController *mineNavi = [[UINavigationController alloc] initWithRootViewController:mine];
    //    SloppySwiper *mineSloppy = [[SloppySwiper alloc] initWithNavigationController:mineNavi];
    //    mineNavi.delegate = mineSloppy;
    //    _mineSloppy = mineSloppy;
    
    NSArray *viewControllers = [NSArray arrayWithObjects:index, faxian, mine, nil];
    UITabBarController *tabBarVCR = [[UITabBarController alloc] init];
    tabBarVCR.view.backgroundColor = NHWhiteColor;
    tabBarVCR.tabBar.normalBarTintColor = NHDarwnBgColor;
    tabBarVCR.tabBar.tintColor = UIColorFromRGB(0xEE0008);
    tabBarVCR.viewControllers = viewControllers;
    
    //global navi
    UINavigationController *globalNavi = [[UINavigationController alloc] initWithRootViewController:tabBarVCR];
    globalNavi.view.backgroundColor = NHWhiteColor;
    SloppySwiper *globalSloppy = [[SloppySwiper alloc] initWithNavigationController:globalNavi];
    globalNavi.delegate = globalSloppy;
    _globalSloppy = globalSloppy;
    globalNavi.navigationBarHidden = true;
    self.window.rootViewController = globalNavi;
    index.rootNaviVCR = globalNavi;
    faxian.rootNaviVCR = globalNavi;
    mine.rootNaviVCR = globalNavi;
    
    //self.window.rootViewController = tabBarVCR;
    [self.window makeKeyAndVisible];
    
    [self addColorChangedBlock:^{
        tabBarVCR.tabBar.nightBarTintColor = NHNightBgColor;
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //[UIPasteboard generalPasteboard].items = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

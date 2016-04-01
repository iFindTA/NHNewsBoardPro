//
//  NHConstaints.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/23.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#ifndef NHConstaints_h
#define NHConstaints_h

#define NHDarwnBgColorHex                0xFFFFFF
#define NHNightBgColorHex                0x5B5B5B
#define NHDarwnTextColorHex              0x000000
#define NHNightTextColorHex              0x999999

#define NHWhiteColor                  [UIColor whiteColor]
#define NHDarwnBgColor                (UIColorFromRGB(NHDarwnBgColorHex))
#define NHNightBgColor                (UIColorFromRGB(NHNightBgColorHex))
#define NHNaviBarDarwnTintColor       ([UIColor redColor])
#define NHNaviBarNightTintColor       (UIColorFromRGB(0xAE0000))

#define NHStatusBarHeight               20.f
#define NHNavigationBarHeight           44.f
#define NHSubNavigationBarHeight        40.f
#define NHToolBarHeight                 46.f
#define NHNaviAndStatusH                (NHStatusBarHeight+NHNavigationBarHeight)
#define NHStatuBounds  ([[UIApplication sharedApplication] statusBarFrame])
#define NHNaviBounds  (self.navigationController.navigationBar.bounds)
#define NHTabBarBounds  (self.tabBarController.tabBar.bounds)
#define NHAbove_h  NHNaviAndStatusH
#define NHDown_h  49.f

#define NHBoundaryOffset   10

#define NHStandardBaseH 568//基线以iPhone5为基准
#define NHEstimateHeight(x) (x * (PBSCREEN_HEIGHT/NHStandardBaseH))

#define NHLaunchModeKey               @"NHLaunchReadModeKey"

#define NHNewsUpdateInterval        600//新闻刷新间隔 /秒
#define NHNewsForceUpdateChannel    @"头条"//强制刷新频道

#endif /* NHConstaints_h */

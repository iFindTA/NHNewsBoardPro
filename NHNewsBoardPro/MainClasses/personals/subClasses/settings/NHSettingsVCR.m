//
//  NHSettingsVCR.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/12/20.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHSettingsVCR.h"

@implementation NHSettingsVCR

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.normalBarTintColor = NHNaviBarDarwnTintColor;
    
    weakify(self);
    [self addColorChangedBlock:^{
        strongify(self);
        self.view.nightBackgroundColor = NHNightBgColor;
        self.navigationController.navigationBar.nightBarTintColor = NHNightBgColor;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:false animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

@end

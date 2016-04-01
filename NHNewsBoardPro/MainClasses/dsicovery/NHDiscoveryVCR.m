//
//  NHDiscoveryVCR.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/23.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHDiscoveryVCR.h"
#import "NHPresentVCR.h"

@interface NHDiscoveryVCR ()<UITableViewDelegate, UITableViewDataSource>

@property (nullable, nonatomic, strong) NSMutableArray *dataSource;
@property (nullable, nonatomic, strong) NHTableView *tableView;

@end

@implementation NHDiscoveryVCR

- (id)init {
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = false;
        
        NSString *title = [NSString stringWithFormat:@"%@",@"发现"];
        self.title = title;
        self.tabBarItem.title = title;
//        NSString *icon_info = @"\U0000E603";
//        NSInteger iconSize = 15;
//        UIColor *c_color_n = [UIColor pb_colorWithHexString:@"333333"];
//        UIColor *c_color_s = [UIColor pb_colorWithHexString:@"56abe4"];
//        UIImage *c_img_n = [UIImage pb_iconFont:nil withName:icon_info withSize:iconSize withColor:c_color_n];
//        UIImage *c_img_s = [UIImage pb_iconFont:nil withName:icon_info withSize:iconSize withColor:c_color_s];
        UIImage *c_img_n = [UIImage imageNamed:@"tabbar_icon_found_n"];
        UIImage *c_img_s = [UIImage imageNamed:@"tabbar_icon_found_s"];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:c_img_n selectedImage:c_img_s];
        self.tabBarItem = item;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.view.backgroundColor = NHWhiteColor;
    //self.navigationController.navigationBar.normalBarTintColor = NHNaviBarDarwnTintColor;
    [self changeNavigationBarTitle2:@"发现"];
    
   // weakify(self);
    [self addColorChangedBlock:^{
        //strongify(self);
        
    }];
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

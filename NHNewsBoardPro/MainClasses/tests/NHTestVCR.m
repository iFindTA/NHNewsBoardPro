//
//  NHTestVCR.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/2/15.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHTestVCR.h"
#import "NHRootScroll.h"

@interface NHTestVCR ()

@property (nullable, nonatomic, strong) NHRootScroll *rootScroll;

@end

@implementation NHTestVCR

- (id)init {
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = false;
        
        NSString *title = [NSString stringWithFormat:@"%@",@"测试"];
        self.title = title;
        self.tabBarItem.title = title;
        NSString *icon_info = @"\U0000E627";
        NSInteger iconSize = 15;
        UIColor *c_color_n = [UIColor pb_colorWithHexString:@"333333"];
        UIColor *c_color_s = [UIColor pb_colorWithHexString:@"56abe4"];
        UIImage *c_img_n = [UIImage pb_iconFont:nil withName:icon_info withSize:iconSize withColor:c_color_n];
        UIImage *c_img_s = [UIImage pb_iconFont:nil withName:icon_info withSize:iconSize withColor:c_color_s];
        self.tabBarItem.image = c_img_n;
        self.tabBarItem.selectedImage = c_img_s;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.normalBarTintColor = NHNaviBarDarwnTintColor;
    
    CGRect infoBounds = CGRectMake(0, NHAbove_h, PBSCREEN_WIDTH, PBSCREEN_HEIGHT-NHAbove_h-NHDown_h);
    _rootScroll = [[NHRootScroll alloc] initWithFrame:infoBounds withChannels:[self tempArray]];
    _rootScroll.showsHorizontalScrollIndicator = false;
    _rootScroll.showsVerticalScrollIndicator = false;
    _rootScroll.pagingEnabled = true;
    _rootScroll.contentMode = UIViewContentModeCenter;
    [self.view addSubview:_rootScroll];
    
    weakify(self);
    [self addColorChangedBlock:^{
        strongify(self);
        self.view.nightBackgroundColor = NHNightBgColor;
        self.navigationController.navigationBar.nightBarTintColor = NHNightBgColor;
    }];
}

- (NSArray *)tempArray{
    NSMutableArray *listTop = [[NSMutableArray alloc] initWithArray:@[@"推荐",@"热点",@"杭州财经报社",@"社会",@"娱乐",@"科技",@"汽车",@"体育",@"订阅",@"财经",@"军事",@"国际",@"正能量",@"段子",@"趣图",@"美女",@"健康",@"教育",@"特卖",@"彩票",@"辟谣"]];
    return [listTop copy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if (_rootScroll) {
        [self.rootScroll lowerMemoryCachePolicy];
    }
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

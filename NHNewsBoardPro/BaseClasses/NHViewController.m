//
//  NHViewController.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/24.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHViewController.h"

const NSString *kItemBack = @"navigationBarActionBack";
const NSString *kItemSearch = @"navigationBarActionSearch";
const NSString *kItemBell = @"navigationBarActionBell";
const NSString *kItemClose = @"navigationBarActionClose";

const NSString *kItemComment = @"toolBarActionComment";
const NSString *kItemFont = @"toolBarActionFont";
const NSString *kItemShare = @"toolBarActionShare";

@interface NHViewController ()

@property (nonatomic, strong) UILabel *statusBar, *line;
@property (nonatomic, strong) UILabel *navigationBar;
//@property (nullable, nonatomic, strong) UINavigationBar *navigationBar;

@end

@implementation NHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = NHWhiteColor;
    [self.view addSubview:self.statusBar];
    [self.view addSubview:self.navigationBar];
    [self changeStatusBarDarwnColor2:NHNaviBarDarwnTintColor];
    [self changeStatusBarNightColor2:NHNaviBarNightTintColor];
    
    weakify(self)
    [self.statusBar mas_makeConstraints:^(MASConstraintMaker *make) {
        //strongify(self)
        make.top.left.right.equalTo(@0).offset(0);
        make.height.equalTo(@(NHStatusBarHeight));
    }];
    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.mas_equalTo(self.statusBar.mas_bottom).offset(0);
        make.left.right.equalTo(@0);
        make.height.equalTo(@(NHNavigationBarHeight));
    }];
    //line
    CGFloat line_h = 1.f;
    UILabel *line = [[UILabel alloc] init];
    line.hidden = true;
    line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line];
    self.line = line;
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.left.right.equalTo(self.navigationBar);
        make.top.mas_equalTo(self.navigationBar.mas_bottom).offset(-line_h);
        make.height.equalTo(@(line_h));
    }];
    
    //夜间模式设置
    [self addColorChangedBlock:^{
        strongify(self);
        self.view.nightBackgroundColor = NHNightBgColor;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIStatusBarStyle style = UIStatusBarStyleLightContent;
    if ([NSStringFromClass(self.class) isEqualToString:@"NHNewsDetailsVCR"]) {
        style = UIStatusBarStyleDefault;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:style];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

/**
 *  @brief status bar style
 *
 *  @return style
 *  @discussion: if controller is inside a navigationController, this won't work at all!
 */
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UILabel *)statusBar {
    if (!_statusBar) {
        UILabel *statusBar = [[UILabel alloc] init];
        statusBar.userInteractionEnabled = true;
        _statusBar = statusBar;
    }
    return _statusBar;
}

- (UILabel *)navigationBar {
    if (!_navigationBar) {
        UILabel *statusBar = [[UILabel alloc] init];
        statusBar.font = [UIFont pb_navigationTitle];
        statusBar.textAlignment = NSTextAlignmentCenter;
        statusBar.textColor = NHWhiteColor;
        statusBar.userInteractionEnabled = true;
        _navigationBar = statusBar;
    }
    return _navigationBar;
}

//- (UINavigationBar *)navigationBar {
//    if (!_navigationBar) {
//        UINavigationBar *naviBar = [[UINavigationBar alloc] init];
//        naviBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont pb_navigationTitle],NSFontAttributeName,NHWhiteColor,NSForegroundColorAttributeName, nil];
//        _navigationBar = naviBar;
//    }
//    return _navigationBar;
//}

- (void)changeStatusBarDarwnColor2:(UIColor *)color {
    
    weakify(self)
    [self addColorChangedBlock:^{
        strongify(self)
        self.statusBar.normalBackgroundColor = color;
        self.navigationBar.normalBackgroundColor = color;
    }];
}

- (void)changeStatusBarNightColor2:(UIColor *)color {
    
    weakify(self)
    [self addColorChangedBlock:^{
        strongify(self)
        self.statusBar.nightBackgroundColor = color;
        self.navigationBar.nightBackgroundColor = color;
    }];
}

- (void)changeNavigationBarTitle2:(NSString * _Nonnull)title {
    self.navigationBar.text = title;
}

- (void)makeNavigationBarLineHidden:(BOOL)hidden {
    self.line.hidden = hidden;
}

- (void)customNavigationBarTitleView:(UIView * _Nonnull)view {
    
    [self.view addSubview:view];
    weakify(self)
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.centerX.equalTo(self.navigationBar.mas_centerX);
        make.centerY.equalTo(self.navigationBar.mas_centerY);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    CFIndex idx = CFGetRetainCount((__bridge CFTypeRef)(self));
    NSLog(@"--%@--dealloc--count:%ld",NSStringFromClass(self.class),idx);
}

#pragma mark -- NavigationBar Items Factory --

- (void)registerBarItems:(NSArray *)items forPlace:(NHItemType)type {
    
    NSAssert(items.count > 0, @"register bar items counts must be positive!");
    CGFloat offset = 10;UIButton *last_v;CGRect bounds;
    for (NSString *key in items) {
        UIImage *img = [self imageForItem:key];
        SEL selector = [self selectorForItem:key];
        bounds.origin = CGPointZero;bounds.size = img.size;
        UIButton *tmp = [UIButton buttonWithType:UIButtonTypeCustom];
        tmp.frame = bounds;
        tmp.exclusiveTouch = true;
        [tmp setImage:img forState:UIControlStateNormal];
        [tmp addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:tmp];
        weakify(self)
        [tmp mas_makeConstraints:^(MASConstraintMaker *make) {
            strongify(self)
            make.centerY.equalTo(self.navigationBar).offset(0);
            if (NHItemTypeLeft == type) {
                make.left.mas_equalTo(last_v?last_v.mas_right:self.view).offset(offset);
            }else{
                make.right.mas_equalTo(last_v?last_v.mas_left:self.view).offset(-offset);
            }
        }];
        last_v = tmp;
    }
}

- (UIImage * _Nullable)imageForItem:(NSString * _Nonnull)n {
    UIImage *img ;
    if ([kItemBack isEqualToString:n]) {
        img = [UIImage imageNamed:@"top_navi_back"];
    }else if ([kItemBell isEqualToString:n]){
        img = [UIImage imageNamed:@"top_navi_bell_normal"];
    }else if ([kItemSearch isEqualToString:n]){
        img = [UIImage imageNamed:@"top_navi_search_icon"];
    }else if ([kItemClose isEqualToString:n]){
        img = [UIImage imageNamed:@"top_navi_close"];
    }
    return img;
}

- (SEL)selectorForItem:(NSString * _Nonnull)n {
    SEL selector = NSSelectorFromString(n);
    return selector;
}

- (void)navigationBarActionNone {}
- (void)navigationBarActionBack {}
- (void)navigationBarActionClose {}
- (void)navigationBarActionSearch {}
- (void)navigationBarActionBell {}

#pragma mark -- ToolBar Items Factory --

- (void)registerToolBarItems:(NSArray *)items {
    
    NSAssert(items.count > 0, @"register bar items counts must be positive!");
    
    for (NSString *key in items) {
        
    }
}

- (void)toolBarActionComment {}
- (void)toolBarActionFont {}
- (void)toolBarActionShare {}

#pragma mark -- Generate empty view --

- (UIView *)emptyPlaceHolderView:(NSString *)icon withInfo:(NSString *)info {
    
    return nil;
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

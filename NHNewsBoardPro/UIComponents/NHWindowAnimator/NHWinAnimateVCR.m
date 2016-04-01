//
//  NHWinAnimateVCR.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/23.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHWinAnimateVCR.h"

@interface NHWinAnimateVCR ()

// 一开始的状态栏状态
@property (nonatomic, assign)BOOL statusBarHiddenInited;
@property (nonatomic, strong)UIWindow *actionWindow;

@property (nonatomic, strong) UIView *buildingsView;
@property (nonatomic, strong) UIImageView *b_img1,*b_img2,*b_img3,*light,*skyImg,*starImg;

@end

@implementation NHWinAnimateVCR

#pragma mark - Lifecycle
- (void)loadView {
    _statusBarHiddenInited = [UIApplication sharedApplication].isStatusBarHidden;
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //initsubviews
    weakify(self)
    UIImageView *tmp = [[UIImageView alloc] init];
    tmp.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:tmp];
    self.skyImg = tmp;
    tmp = [[UIImageView alloc] init];
    [self.view addSubview:tmp];
    self.starImg = tmp;
    tmp = [[UIImageView alloc] init];
    [self.view addSubview:tmp];
    self.light = tmp;
    UIView *buildings = [[UIView alloc] init];
    //buildings.backgroundColor = [UIColor redColor];
    [self.view addSubview:buildings];
    self.buildingsView = buildings;
    tmp = [[UIImageView alloc] init];
    [self.buildingsView addSubview:tmp];
    self.b_img3 = tmp;
    tmp = [[UIImageView alloc] init];
    [self.buildingsView addSubview:tmp];
    self.b_img2 = tmp;
    tmp = [[UIImageView alloc] init];
    [self.buildingsView addSubview:tmp];
    self.b_img1 = tmp;
    //布局
    [self.skyImg mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.left.right.equalTo(self.view).offset(0);
    }];
    [self.starImg mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.left.right.equalTo(self.view).offset(0);
        make.bottom.mas_equalTo(self.skyImg.mas_centerY).offset(0);
    }];
    [self.light mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(self.buildingsView.mas_top).offset(0);
    }];
    [buildings mas_makeConstraints:^(MASConstraintMaker *make) {
       strongify(self)
        make.left.right.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
        make.top.mas_equalTo(self.b_img2.mas_top).offset(-20);
    }];
    
    [self.b_img1 mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.left.right.equalTo(self.buildingsView).offset(0);
        make.bottom.mas_equalTo(self.buildingsView.centerY).offset(0);
    }];
    [self.b_img2 mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.left.right.equalTo(self.buildingsView).offset(0);
        make.bottom.mas_equalTo(self.buildingsView.centerY).offset(0);
    }];
    [self.b_img3 mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.left.right.equalTo(self.buildingsView).offset(0);
        make.bottom.mas_equalTo(self.b_img1.centerY).offset(10);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)show:(NHAnimateType)type {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.opaque = true;
    UIWindowLevel level = UIWindowLevelStatusBar+10.0f;
    if (_statusBarHiddenInited) {
        level = UIWindowLevelNormal+10.0f;
    }
    window.windowLevel = level;
    window.rootViewController = self;
    window.backgroundColor = [UIColor clearColor];
    [window makeKeyAndVisible];
    self.actionWindow = window;
    //替换buildings
    UIImage *img1,*img2,*img3,*light,*star,*bgImg;UIColor *color;
    if (NHAnimate2Darwn == type) {
        img1 = [UIImage imageNamed:@"day_building1"];
        img2 = [UIImage imageNamed:@"day_building2"];
        img3 = [UIImage imageNamed:@"day_building3"];
        img3 = [UIImage imageNamed:@"day_light"];
        bgImg = [UIImage imageNamed:@"day_mask"];
        star = nil;
        color = [UIColor colorWithRed:31/255.f green:31/255.f blue:31/255.f alpha:0.6];
    }else if (NHAnimate2Night == type){
        img1 = [UIImage imageNamed:@"building1"];
        img2 = [UIImage imageNamed:@"building2"];
        img3 = [UIImage imageNamed:@"building3"];
        img3 = [UIImage imageNamed:@"light"];
        color = [UIColor colorWithRed:34/255.f green:35/255.f blue:38/255.f alpha:1];
        bgImg = [UIImage pb_imageWithColor:color];
        star = [UIImage imageNamed:@"starsky"];
    }
    self.skyImg.image = bgImg;self.starImg.image = star;
    self.light.image = light;self.view.backgroundColor = color;
    self.b_img1.image = img1;self.b_img2.image = img2;self.b_img3.image = img3;
    //动画淡入
    weakify(self)
    self.actionWindow.layer.opacity = 0.01f;
    [UIView animateWithDuration:PBANIMATE_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        strongify(self)
        self.actionWindow.layer.opacity = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            strongify(self)
            PBMAINDelay(2, ^{
                [self dismiss];
            });
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self dismiss];
}

- (void)dismiss {
    
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHiddenInited withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:PBANIMATE_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.actionWindow.layer.opacity = 0.01f;
    } completion:^(BOOL finished) {
        [self.actionWindow removeFromSuperview];
        [self.actionWindow resignKeyWindow];
        self.actionWindow = nil;
    }];
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

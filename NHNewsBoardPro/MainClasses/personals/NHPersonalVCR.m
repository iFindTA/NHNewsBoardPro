//
//  NHPersonalVCR.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/23.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHPersonalVCR.h"
#import "NHRecordVCR.h"
#import "NHSettingsVCR.h"
#import "NHCollectionVCR.h"
#import "NHInfomationVCR.h"
#import "NHWinAnimateVCR.h"

@interface NHPersonalVCR ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong, nonnull) NHTableView *tableView;
@property (nonatomic, strong, nullable) UIButton *logoBtn,*nickBtn;

@end

@implementation NHPersonalVCR

- (id)init {
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = false;
        
        NSString *title = [NSString stringWithFormat:@"%@",@"我"];
        self.title = title;
        self.tabBarItem.title = title;
//        NSString *icon_info = @"\U0000E627";
//        NSInteger iconSize = 15;
//        UIColor *c_color_n = [UIColor pb_colorWithHexString:@"333333"];
//        UIColor *c_color_s = [UIColor pb_colorWithHexString:@"56abe4"];
//        UIImage *c_img_n = [UIImage pb_iconFont:nil withName:icon_info withSize:iconSize withColor:c_color_n];
//        UIImage *c_img_s = [UIImage pb_iconFont:nil withName:icon_info withSize:iconSize withColor:c_color_s];
        UIImage *c_img_n = [UIImage imageNamed:@"tabbar_icon_me_n"];
        UIImage *c_img_s = [UIImage imageNamed:@"tabbar_icon_me_s"];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:c_img_n selectedImage:c_img_s];
        self.tabBarItem = item;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.normalBarTintColor = NHNaviBarDarwnTintColor;
    
    CGRect infoBounds = CGRectMake(0, 0, PBSCREEN_WIDTH, PBSCREEN_HEIGHT-NHDown_h);
    _tableView = [[NHTableView alloc] initWithFrame:infoBounds style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    weakify(self);
    [self addColorChangedBlock:^{
        strongify(self);
        self.tableView.nightBackgroundColor = NHNightBgColor;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:true animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:false animated:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return NHEstimateHeight(150);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hView;
    CGFloat height = NHEstimateHeight(150);
    CGRect infoBounds ;
    infoBounds.size = CGSizeMake(PBSCREEN_WIDTH, height);
    hView = [[UIView alloc] initWithFrame:infoBounds];
    hView.normalBackgroundColor = NHNaviBarDarwnTintColor;
    
    UIFont *font = [UIFont pb_deviceFontForTitle];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"设置" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:font.pointSize-2];
    [btn sizeToFit];
    [btn addTarget:self action:@selector(settingsTouchEvent) forControlEvents:UIControlEventTouchUpInside];
    [hView addSubview:btn];
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hView.mas_top).offset(3*NHBoundaryOffset);
        make.right.equalTo(hView.mas_right).offset(-2*NHBoundaryOffset);
    }];
    
    //logo
    CGFloat logoWH = height/3;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = logoWH*0.5;
    btn.layer.masksToBounds = true;
    [btn setImage:[UIImage imageNamed:@"luntai.jpg"] forState:UIControlStateNormal];
    [hView addSubview:btn];
    [btn addTarget:self action:@selector(logoTouchEvent) forControlEvents:UIControlEventTouchUpInside];
    _logoBtn = btn;
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hView.top).offset(height/4);
        make.centerX.equalTo(hView.mas_centerX).offset(0);
        make.width.height.lessThanOrEqualTo([NSNumber numberWithInteger:logoWH]);
    }];
    //nick
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = font;
    [btn setTitle:@"点击登录" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn sizeToFit];
    [hView addSubview:btn];
    [btn addTarget:self action:@selector(nickTouchEvent) forControlEvents:UIControlEventTouchUpInside];
    _nickBtn = btn;
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_logoBtn.mas_bottom).offset(NHBoundaryOffset);
        make.centerX.equalTo(hView.mas_centerX).offset(0);
    }];
    
    [self addColorChangedBlock:^{
        hView.nightBackgroundColor = NHNaviBarNightTintColor;
    }];
    
    return hView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *infoString;
    NSInteger row_ = [indexPath row];
    if (row_ == 0) {
        infoString = @"我的收藏";
    }else if (row_ == 1){
        infoString = @"阅读历史";
    }else if (row_ == 2){
        infoString = @"消息中心";
    }else if (row_ == 3){
        infoString = @"夜间模式";
    }
    
    UIFont *font = [UIFont pb_deviceFontForTitle];
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.text = infoString;
    [label sizeToFit];
    [cell.contentView addSubview:label];
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView.mas_left).offset(NHBoundaryOffset);
        make.centerY.equalTo(cell.contentView.mas_centerY);
    }];
    if (row_ == 3) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL nightMode = [[userDefaults objectForKey:NHLaunchModeKey] boolValue];
        UISwitch *m_switch = [[UISwitch alloc] init];
        [m_switch addTarget:self action:@selector(readModeChanged:) forControlEvents:UIControlEventValueChanged];
        [m_switch setOn:nightMode];
        [cell.contentView addSubview:m_switch];
        [m_switch makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView.mas_right).offset(-NHBoundaryOffset);
            make.centerY.equalTo(cell.contentView.mas_centerY);
        }];
    }
    cell.accessoryType = (row_ == 3 ? UITableViewCellAccessoryNone:UITableViewCellAccessoryDisclosureIndicator);
    //@weakify(self);
    [self addColorChangedBlock:^{
        //@strongify(self);
        label.nightTextColor = UIColorFromRGB(NHNightTextColorHex);
        label.normalTextColor = UIColorFromRGB(NHDarwnTextColorHex);
        cell.nightBackgroundColor = NHNightBgColor;
        cell.normalBackgroundColor = NHDarwnBgColor;
    }];
    
    return cell;
}

- (void)readModeChanged:(UISwitch *)aswitch {
    NSNumber *night = [NSNumber numberWithBool:aswitch.isOn];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NHWinAnimateVCR *animateVCR = [[NHWinAnimateVCR alloc] init];
    [animateVCR show:aswitch.isOn?NHAnimate2Night:NHAnimate2Darwn];
    if (!aswitch.isOn) {
        [DKNightVersionManager dawnComing];
    } else {
        [DKNightVersionManager nightFalling];
    }
    [userDefaults setObject:night forKey:NHLaunchModeKey];
    [userDefaults synchronize];
}

- (void)settingsTouchEvent {
    NHSettingsVCR *settingsVCR = [[NHSettingsVCR alloc] init];
    settingsVCR.hidesBottomBarWhenPushed = true;
    [self.rootNaviVCR pushViewController:settingsVCR animated:true];
}

- (void)logoTouchEvent {
    
}

- (void)nickTouchEvent {
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row_ = [indexPath row];
    UIViewController *destVCR;
    if (row_ == 0) {
        NHCollectionVCR *collectionVCR = [[NHCollectionVCR alloc] init];
        destVCR = collectionVCR;
    }else if (row_ == 1) {
        NHRecordVCR *recorderVCR = [[NHRecordVCR alloc] init];
        destVCR = recorderVCR;
    }else if (row_ == 2) {
        NHInfomationVCR *informationVCR = [[NHInfomationVCR alloc] init];
        destVCR = informationVCR;
    }
    destVCR.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:destVCR animated:true];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)updateUserLoginState {
    
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

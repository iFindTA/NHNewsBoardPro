//
//  NHDefaultVCR.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/23.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHDefaultVCR.h"
#import "NHSubscriber.h"
#import "NHPageScroller.h"
#import "NHNewsDetailsVCR.h"
#import "NHEditChannelVCR.h"

@interface NHDefaultVCR ()<NHSubscriberDataSource, NHSubscriberDelegate, NHPageScrollerDataSource, NHPageScrollerDelegate>

@property (nonatomic, strong) NSArray *dataSource,*uriSource;
@property (nonatomic, strong, nullable) NHSubscriber *scriber;
@property (nonatomic, strong, nullable) NHPageScroller *pageScroller;

@end

@implementation NHDefaultVCR

- (id)init {
    self = [super init];
    if (self) {
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
        [self.tabBarItem setImageInsets:UIEdgeInsetsMake(10, 0, -10, 0)];
        NSString *title = [NSString stringWithFormat:@"%@",@"爱财经"];
        self.title = title;
        title = PBFormat(@"%@",@"新闻");
//        NSString *icon_info = @"\U0000E637";
//        NSInteger iconSize = 15;
//        UIColor *c_color_n = [UIColor pb_colorWithHexString:@"333333"];
//        UIColor *c_color_s = [UIColor pb_colorWithHexString:@"56abe4"];
//        UIImage *c_img_n = [UIImage pb_iconFont:nil withName:icon_info withSize:iconSize withColor:c_color_n];
//        UIImage *c_img_s = [UIImage pb_iconFont:nil withName:icon_info withSize:iconSize withColor:c_color_s];
        UIImage *c_img_n = [UIImage imageNamed:@"tabbar_icon_news_n"];
        UIImage *c_img_s = [UIImage imageNamed:@"tabbar_icon_news_s"];
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
    
    //weakify(self)
    //logo
    UIImage *logo = [UIImage imageNamed:@"top_navi_logo"];
    UIImageView *imgLogo = [[UIImageView alloc] initWithImage:logo];
    [self customNavigationBarTitleView:imgLogo];
    [self registerBarItems:@[kItemBell] forPlace:NHItemTypeLeft];
    [self registerBarItems:@[kItemSearch] forPlace:NHItemTypeRight];
    
    //从加载子导航栏目开始
    [self loadSubNaviChannels];
    
//    NSString *userInfo = @"{\"name\":\"BeJson\",\"userid\":10086,\"nick\":\"nanhu\",\"phone\":\"13023622337\",\"content\":\"这个人很懒，什么都木有留下...\",\"address\":{\"street\":\"科技园路.\",\"city\":\"江苏苏州\",\"country\":\"中国\"},\"links\":[{\"name\":\"Google\",\"url\":\"http://www.google.com\"},{\"name\":\"Baidu\",\"url\":\"http://www.baidu.com\"},{\"name\":\"SoSo\",\"url\":\"http://www.SoSo.com\"}]}";
//    NSData *userData = [userInfo dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:userData options:NSJSONReadingAllowFragments error:nil];
//    NHUser *user = [[NHUser alloc] initWithDictionary:dic];
//    NSLog(@"user json :%@",user.links);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:false animated:animated];
    [self shouldAutoRefreshWhenWillAppear];
}

- (void)_applicationDidBecomeActive {
    //    NSLog(@"%s",__func__);
    [self shouldAutoRefreshWhenWillAppear];
}

/**
 *  @brief 当本页可见（后台唤起、返回本页）是否自动刷新至最新
 */
- (void)shouldAutoRefreshWhenWillAppear {
    
    BOOL should = false;
    // bala bala bala
    if (should) {
        //[self.reuser selectReuseIndexAndRefresh:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:true animated:animated];
}

- (void)preloadSomeLaziest2DifficultCreate {
    [super preloadSomeLaziest2DifficultCreate];
    
    [[[NHNewsDetailsVCR alloc] init] description];
}

//当程序唤醒时从此方法开始执行
- (void)loadSubNaviChannels {
    
    //TODO:正常情况应从数据库、缓存plist读取 此处为了演示方便不再处理相关逻辑
    if (!_uriSource) {
        _uriSource = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"NewsURLs.plist" ofType:nil]];
    }
    __block NSMutableArray *tmp = [NSMutableArray array];
    [_uriSource enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *tmpTitle = [obj objectForKey:@"title"];
        [tmp addObject:tmpTitle];
    }];
    if (!_dataSource) {
        _dataSource = [tmp copy];
    }
    //NSLog(@"首页子导航栏:%@",_dataSource);
    
    [self buildSubNaviChannels];
}

//构建子导航栏及sub pages
- (void)buildSubNaviChannels {
    
    CGFloat subNaviHeight = 40;
    CGRect infoRect = CGRectMake(0, NHAbove_h, PBSCREEN_WIDTH, subNaviHeight);
    NHSubscriber *scriber = [[NHSubscriber alloc] initWithFrame:infoRect forStyle:NHNaviStyleBack];
    scriber.dataSource = self;
    scriber.delegate = self;
    [self.view addSubview:scriber];
    _scriber = scriber;
    [_scriber reloadData];
    
    infoRect.origin.y += subNaviHeight;
    CGFloat tmpYAxis = infoRect.origin.y + NHDown_h;
    infoRect.size = CGSizeMake(PBSCREEN_WIDTH, PBSCREEN_HEIGHT - tmpYAxis);
    NHPageScroller *pageScroller = [[NHPageScroller alloc] initWithFrame:infoRect];
    pageScroller.dataSource = self;
    pageScroller.delegate = self;
    [self.view addSubview:pageScroller];
    _pageScroller = pageScroller;
    
    weakify(self);
    [self addColorChangedBlock:^{
        strongify(self);
        self.scriber.normalBackgroundColor = NHDarwnBgColor;
        self.scriber.nightBackgroundColor = NHNightBgColor;
    }];
}

- (NSArray *)tempArray{
    NSMutableArray *listTop = [[NSMutableArray alloc] initWithArray:@[@"头条",@"热点",@"杭州财经报社团",@"社会",@"娱乐",@"科技",@"汽车",@"体育",@"订阅",@"财经",@"军事",@"国际",@"正能量",@"段子",@"趣图",@"美女",@"健康",@"教育",@"特卖",@"彩票",@"辟谣"]];
    return [listTop copy];
}
- (NSArray *)otherArray {
    NSMutableArray *listBottom = [[NSMutableArray alloc] initWithArray:@[@"电影",@"数码",@"时尚",@"奇葩",@"游戏",@"旅游",@"育儿",@"减肥",@"养生",@"美食",@"政务",@"历史",@"探索",@"故事",@"美文",@"情感",@"语录",@"美图",@"房产",@"家居",@"搞笑",@"星座",@"文化",@"毕业生",@"视频"]];
    return [listBottom copy];
}
//
//- (void)testAction {
//    NHContentInfolVCR *infoVCR = [[NHContentInfolVCR alloc] init];
//    infoVCR.hidesBottomBarWhenPushed = true;
//    [self.navigationController pushViewController:infoVCR animated:true];
//}

#pragma mark -- SubScriber

- (NSArray *)sourceDataForSubscriber:(NHSubscriber *)scriber{
    //NSMutableArray *listTop = [[NSMutableArray alloc] initWithArray:@[@"推荐",@"热点",@"杭州财经报社",@"社会",@"娱乐",@"科技",@"汽车",@"体育",@"订阅",@"财经",@"军事",@"国际",@"正能量",@"段子",@"趣图",@"美女",@"健康",@"教育",@"特卖",@"彩票",@"辟谣"]];
    NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.dataSource];
    return [tmp copy];
}

//- (NSArray *)newDataForSubscriber:(NHSubscriber *)scriber{
//    NSMutableArray *listBottom = [[NSMutableArray alloc] initWithArray:@[@"电影",@"数码",@"时尚",@"奇葩",@"游戏",@"旅游",@"育儿",@"减肥",@"养生",@"美食",@"政务",@"历史",@"探索",@"故事",@"美文",@"情感",@"语录",@"美图",@"房产",@"家居",@"搞笑",@"星座",@"文化",@"毕业生",@"视频"]];
//    return [listBottom copy];
//}

- (void)subscriber:(NHSubscriber *)scriber didSelectIndex:(NSInteger)index{
    NSLog(@"did select index:%zd",index);
    //[_reuser setReuseSelectIndex:index];
    [_pageScroller selectedIndex:index animated:false];
}

- (void)didSelectArrowForSubscriber:(NHSubscriber *)scriber {
    //NSLog(@"did select scriber's arrow");
    
    //TODO:实现频道编辑
    //[SVProgressHUD showInfoWithStatus:@"Func{subscriber} To Be Continue!"];
    
    NHEditChannelVCR *editChannels = [[NHEditChannelVCR alloc] init];
    //TODO:需要传当前选中的频道
    editChannels.selectedCnn = NHNewsForceUpdateChannel;
    editChannels.otherSource = [self otherArray];
    editChannels.existSource = [self tempArray];
    [editChannels handleChannelEditorSwitchEvent:^(NSUInteger index, NSString * _Nonnull channel) {
        NSLog(@"切换栏目:%@",channel);
    }];
    [self presentViewController:editChannels animated:true completion:^{
        
    }];
}

#pragma mark -- Navi top event --

- (void)navigationBarActionBell {
    [super navigationBarActionBell];
    //TODO:实现24小时
    [SVProgressHUD showInfoWithStatus:@"Func{24 hours} To Be Continue!"];
}

- (void)navigationBarActionSearch {
    [super navigationBarActionSearch];
    //TODO:实现搜索
    [SVProgressHUD showInfoWithStatus:@"Func{search} To Be Continue!"];
}

#pragma mark -- pageScroller --

- (NSArray *)dataSourceForPageScroller:(NHPageScroller *)scroller {
    //NSMutableArray *listTop = [[NSMutableArray alloc] initWithArray:@[@"推荐",@"热点",@"杭州财经报社",@"社会",@"娱乐",@"科技",@"汽车",@"体育",@"订阅",@"财经",@"军事",@"国际",@"正能量",@"段子",@"趣图",@"美女",@"健康",@"教育",@"特卖",@"彩票",@"辟谣"]];
    NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.dataSource];
    return [tmp copy];
}

- (void)scroller:(NHPageScroller *)scroller didShowIndex:(NSInteger)index {
    [_scriber setSubscriberSelectIndex:index];
}

- (void)scroller:(NHPageScroller *)scroller didSelectNews:(NHNews *)info {
    
    NSLog(@"用户选择了新闻:%@",info.title);
    NHNewsDetailsVCR *newsDetailsVCR = [[NHNewsDetailsVCR alloc] init];
    newsDetailsVCR.news = info;
    newsDetailsVCR.hidesBottomBarWhenPushed = true;
    //[self.navigationController pushViewController:newsDetailsVCR animated:true];
    [self.rootNaviVCR pushViewController:newsDetailsVCR animated:true];
}

- (void)scroller:(NHPageScroller *)scroller didSelectADs:(NSDictionary *)ad {
    
    NSLog(@"用户选择了广告:%@",[ad objectForKey:@"title"]);
    if ([ad pb_stringForKey:@"docid"]) {
        //选择的是新闻
    }
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

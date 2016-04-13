//
//  NHPreventCustomer.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/11.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHPreventCustomer.h"
#import "NHNewsCell.h"
#import <MJRefresh.h>

@interface NHPreventCustomer ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, strong, nullable) NSMutableArray *dataSources;
@property (nonatomic, strong, nullable) UITableView *table;

@property (nonatomic, copy) NHNewsClickEvent aNewsBlock;
@property (nonatomic, copy) NHADsClickEvent adsBlock;

@end

@implementation NHPreventCustomer

+ (instancetype)prevent:(CGRect)bounds withChannel:(NSString *)cnn {
    NHPreventCustomer *tmp = [[NHPreventCustomer alloc] initWithFrame:bounds withCnn:cnn];
    tmp.infos = [[NHSetsEngine share] getInfoForChannel:cnn];
    return tmp;
}

#pragma mark -- Lazy load methods

- (NSMutableArray *)dataSources {
    if (!_dataSources) {
        _dataSources = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSources;
}

- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _table;
}

//将要显示数据前 先检测table状态
- (void)detectTableStateForShow {
    if (!_table) {
        [self addSubview:self.table];
        self.table.scrollsToTop = true;
        self.table.dataSource = self;
        self.table.delegate = self;
        //设置刷新组件
        weakify(self)
        self.table.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            strongify(self)
            _currentPage = 1;
            [self loadNewsDataFromNetAtPage:_currentPage];
        }];
        self.table.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            strongify(self)
            [self loadNewsDataFromNetAtPage:_currentPage+1];
        }];
        self.table.mj_footer.automaticallyHidden = true;
        //设置刷新key
        NSString *updateKey = PBFormat(@"news_update_key_%@",self.cnn);
        self.table.mj_header.lastUpdatedTimeKey = updateKey;
        
        [self addColorChangedBlock:^{
            strongify(self)
            self.table.mj_header.normalBackgroundColor = NHWhiteColor;
            self.table.mj_footer.normalBackgroundColor = NHWhiteColor;
            self.table.mj_header.nightBackgroundColor = NHNightBgColor;
            self.table.mj_footer.nightBackgroundColor = NHNightBgColor;
            [self.table.mj_header setValue:NHWhiteColor forKeyPath:@"self.stateLabel.nightTextColor"];
            [self.table.mj_header setValue:NHWhiteColor forKeyPath:@"self.lastUpdatedTimeLabel.nightTextColor"];
            [self.table.mj_footer setValue:NHWhiteColor forKeyPath:@"self.stateLabel.nightTextColor"];
        }];
    }
    self.table.hidden = false;
    self.table.userInteractionEnabled = true;
}

#pragma mark -- 父类方法
- (void)preventLoad {
    
    [self detectTableStateForShow];
    
    if (self.state == NHPreventStateShowing
        || self.state == NHPreventStatePreLoaded) {
        NSLog(@"栏目:%@....---->已经preload!",self.cnn);
        return;
    }
    NSLog(@"栏目:%@....---->preloading....!",self.cnn);
    if (self.state != NHPreventStateShowing) {
        [self loadNewsDataFromLocalAtOnePage];
    }
    
    [super preventLoad];
}

- (BOOL)isRefreshing {
    return (self.table.mj_header.isRefreshing || self.table.mj_footer.isRefreshing);
}

- (void)endRefreshing {
    
    if (self.table.mj_header.isRefreshing) {
        [self.table.mj_header endRefreshing];
    }
    if (self.table.mj_footer.isRefreshing) {
        [self.table.mj_footer endRefreshing];
    }
}

#pragma mark -- load news datas --
//本地仅缓存一页数据
- (void)loadNewsDataFromLocalAtOnePage {
    weakify(self)
    PBBACK(^{
        strongify(self)
        NSArray *tmpCaches = [[NHDBEngine share] getNewsCachesForChannel:self.cnn];
        NSLog(@"首先获取本地数据===counts:%zd",tmpCaches.count);
        self.dataSources = [NSMutableArray arrayWithArray:tmpCaches];
        [self refreshTableUI];
    });
}
//从网络获取数据
- (void)loadNewsDataFromNetAtPage:(NSUInteger)page {
    //验证无效页码
    if (page <= 0) {
        [self endRefreshing];
        return;
    }
    //NSLog(@"需要加载第%zd页数据",page);
    //TODO:page==1时优先从caches读取
    NSString *tmpPath = [self.infos pb_stringForKey:@"urlString"];
    NSString *url_str ;
    if (page == 1) {
        url_str = PBFormat(@"/nc/article/%@/0-20.html",tmpPath);
    }else {
        url_str = PBFormat(@"/nc/article/%@/%zd-20.html",tmpPath,(self.dataSources.count - self.dataSources.count%10));
    }
    
    //请求数据
    weakify(self);
    PBBACK(^{
        [[NHAFEngine share] GET:url_str parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary  *responseObject) {
            strongify(self)
            NSString *key = [responseObject.keyEnumerator nextObject];
            NSArray *tmpArray = responseObject[key];
            //NSLog(@"get something:%@",tmpArray);
            NSMutableArray *tmpModels = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *tmp in tmpArray) {
                NHNews *news = [[NHNews alloc] initWithDictionary:tmp];
                [tmpModels addObject:news];
            }
            //NSLog(@"models:%@",tmpModels);
            
            //自增pageIdx
            self.currentPage++;
            if (page == 1) {
                [self.dataSources removeAllObjects];
                _dataSources = nil;
                self.dataSources = [NSMutableArray arrayWithArray:[tmpModels copy]];
            }else {
                //剔除ads
                [tmpModels enumerateObjectsUsingBlock:^(NHNews *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.hasAD || !PBIsEmpty(obj.ads)) {
                        [tmpModels removeObject:obj];
                    }
                }];
                [self.dataSources addObjectsFromArray:[tmpModels copy]];
            }
            [self refreshTableUI];
            if (page == 1) {
                //如果是第一页数据则清除所有旧数据
                [[NHDBEngine share] clearNewsForChannel:self.cnn];
                [[NHDBEngine share] saveNews:tmpArray forChannel:self.cnn];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            PBMAIN(^{[self endRefreshing];});
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    });
}

- (void)whenDidAppearShouldRefresh {
    NSDate *lastDate = self.table.mj_header.lastUpdatedTime;
    NSDate *now = [NSDate date];
    NSTimeInterval interval = fabs([now timeIntervalSinceDate:lastDate]);
    if (interval > NHNewsUpdateInterval || PBIsEmpty(self.dataSources)) {
        if (![self isRefreshing]) {
            PBMAIN(^{[self.table.mj_header beginRefreshing];});
            NSLog(@"刷新频道:%@---!",self.cnn);
        }
    }else {
        //NSLog(@"频道:%@---暂时无需刷新!",self.channel);
        [self refreshTableUI];
    }
}

//刷新表格数据
- (void)refreshTableUI {
    weakify(self)
    PBMAINDelay(0.01, ^{
        strongify(self)
        //首先准备表格UI
        [self detectTableStateForShow];
        //刷新表格
        [self.table reloadData];
        //关闭自动刷新UI
        [self endRefreshing];
    });
}

#pragma mark -- 父类方法

- (void)viewWillAppear {
    [super viewWillAppear];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self detectTableStateForShow];
    
    [self whenDidAppearShouldRefresh];
}

- (void)reset2LowwerPowerState {
    
    //如果还没有显示过则忽略
    if (self.state != NHPreventStateShowing) {
        return;
    }
    self.table.userInteractionEnabled = false;
    if (self.dataSources) {
        [self.dataSources removeAllObjects];
        _dataSources = nil;
    }
    [self refreshTableUI];
    NSLog(@"栏目:%@---->置为低内存状态",self.cnn);
    [super reset2LowwerPowerState];
}

#pragma mark == table dataSource && delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSources count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int __row = (int)[indexPath row];
    NHNews *tmp = [self.dataSources objectAtIndex:__row];
    CGFloat __row_height = [NHNewsCell heightForSource:tmp];
    if ((__row%20 == 0) && (__row != 0)) {
        __row_height = 80.f;
    }
    return __row_height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int __row = (int)[indexPath row];
    NHNews *tmp = [self.dataSources objectAtIndex:__row];
    NSString *identifier = [NHNewsCell identifierForSource:tmp];
    NHNewsCell *cell = (NHNewsCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[NHNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell dealWithAds:^(NSDictionary * _Nonnull info) {
        if (_adsBlock) {
            _adsBlock(info);
        }
    }];
    [cell configureForSource:tmp];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int __row = (int)[indexPath row];
    NHNews *tmp = [self.dataSources objectAtIndex:__row];
    //NSLog(@"你点击了:%@",tmp.title);
    if (_aNewsBlock) {
        _aNewsBlock(tmp);
    }
    BOOL read = [[NHDBEngine share] alreadyReadDoc:tmp.docid];
    if (!read) {
        PBBACK(^{[[NHDBEngine share] readNews:tmp];});
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)handleNewsTouchEvent:(NHNewsClickEvent)event {
    _aNewsBlock = [event copy];
}

- (void)handleADsTouchEvent:(NHADsClickEvent)event {
    _adsBlock = [event copy];
}

@end

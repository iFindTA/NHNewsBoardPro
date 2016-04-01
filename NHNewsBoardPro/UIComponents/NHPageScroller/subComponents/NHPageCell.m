//
//  NHPageCell.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/25.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHPageCell.h"
#import "NHBaseKits.h"
#import <MJRefresh.h>
#import "NHNewsTitleCell.h"

@interface NHPageCell ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *channel;
@property (nonatomic, strong) NSDictionary *infos;
//@property (nonatomic, strong) UIButton *maskView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NHTableView *table;

@property (nonatomic, copy) NHNewsTouchEvent newsBlock;
@property (nonatomic, copy) NHADsTouchEvent adsBlock;

@end

@implementation NHPageCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self __initSetup];
    }
    
    return self;
}

//- (id)initWithFrame:(CGRect)frame withChannel:(nonnull NSString *)channel {
//    
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.channel = [channel copy];
//        [self __initSetup];
//    }
//    
//    return self;
//}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.channel = @"none";
        [self __initSetup];
    }
    return self;
}

//初始化UI页面
- (void)__initSetup {
    
    _table = [[NHTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _table.showsHorizontalScrollIndicator = true;
    _table.dataSource = self;
    _table.delegate = self;
    _table.scrollsToTop = true;
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.contentView addSubview:_table];
    //设置刷新组件
    weakify(self)
    self.table.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        strongify(self)
        _currentPage = 1;
        [self loadNewsDataForPage:_currentPage];
    }];
    self.table.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        strongify(self)
        [self loadNewsDataForPage:_currentPage+1];
    }];
    self.table.mj_footer.automaticallyHidden = true;
    
    //[self.table addSubview:self.maskView];
}

//- (void)registerUIComponents {
//    if (!_table) {
//        _table = [[NHTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
//        _table.showsHorizontalScrollIndicator = true;
//        _table.dataSource = self;
//        _table.delegate = self;
//        _table.scrollsToTop = true;
//        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
//        [self.contentView addSubview:_table];
//    }
//    //设置刷新组件
//    weakify(self)
//    PBMAIN(^{
//        self.table.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            strongify(self)
//            _currentPage = 1;
//            [self loadNewsDataForPage:_currentPage];
//        }];
//    });
//    self.table.mj_header.backgroundColor = [UIColor pb_randomColor];
//    self.table.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        strongify(self)
//        [self loadNewsDataForPage:_currentPage+1];
//    }];
//    self.table.mj_footer.automaticallyHidden = true;
//}

//- (UIButton *)maskView {
//    if (!_maskView) {
//        _maskView = [UIButton buttonWithType:UIButtonTypeCustom];
//        _maskView.frame = self.table.bounds;
//        _maskView.backgroundColor = [UIColor lightGrayColor];
//        [_maskView setTitle:@"爱财经" forState:UIControlStateNormal];
//        [_maskView setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        [_maskView addTarget:self action:@selector(maskTouchEvent) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_maskView];
//    }
//    return _maskView;
//}
//加载初始数据
- (void)preLoadNewsDataInitForChannel:(NSString *)channel {
    
    //TODO:判断当前channel是否一致
    //NSString *tmpChannel = [self.infos objectForKey:@"title"];
    if ([self.channel isEqualToString:channel]) {
        return;
    }
    //不一致时删除所有数据 要注意同步UI防止意外
    self.channel = [channel copy];
    NSString *updateKey = PBFormat(@"news_update_key_%@",self.channel);
    self.table.mj_header.lastUpdatedTimeKey = updateKey;
    self.currentPage = 1;
    [self.dataSource removeAllObjects];
    [self.table reloadData];
    //TODO:首先加载本地数据 didEndDisplay时再去判断是否需要更新
    weakify(self)
    PBBACK(^{
        strongify(self)
        NSLog(@"首先获取本地数据===");
        NSArray *tmpCaches = [[NHDBEngine share] getNewsCachesForChannel:self.channel];
        self.dataSource = [NSMutableArray arrayWithArray:tmpCaches];
        //self.maskView.hidden = !PBIsEmpty(self.dataSource);
        weakify(self)
        PBMAIN(^{
            strongify(self)
            [self.table reloadData];
            if ([NHNewsForceUpdateChannel isEqualToString:self.channel]) {
                [self ifNeedUpdateToHeadWhenDidEndDisplay];
            }
        });
    });
}

//didEndDisplay后判断是否需要刷新数据
- (void)ifNeedUpdateToHeadWhenDidEndDisplay {
    
    NSDate *lastDate = self.table.mj_header.lastUpdatedTime;
    NSDate *now = [NSDate date];
    NSTimeInterval interval = fabs([now timeIntervalSinceDate:lastDate]);
    if (interval > NHNewsUpdateInterval || PBIsEmpty(self.dataSource)) {
        if (![self isRefreshing]) {
            PBMAIN(^{[self.table.mj_header beginRefreshing];});
            NSLog(@"刷新频道:%@---!",self.channel);
        }
    }else {
        //NSLog(@"频道:%@---暂时无需刷新!",self.channel);
        [self endRefreshing];
        [self.table reloadData];
    }
}

- (void)maskTouchEvent {
    
    if ([self isRefreshing]) {
        return;
    }
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

#pragma mark -- load data --

- (void)loadNewsDataForPage:(NSInteger)page {
    
    //验证无效页码
    if (page <= 0) {
        [self endRefreshing];
        return;
    }
    NSString *updateKey = PBFormat(@"news_update_key_%@",self.channel);
    self.table.mj_header.lastUpdatedTimeKey = updateKey;
    //NSLog(@"需要加载第%zd页数据",page);
    //TODO:page==1时优先从caches读取
    NSString *tmpPath = [self.infos pb_stringForKey:@"urlString"];
    NSString *url_str ;
    if (page == 1) {
        url_str = PBFormat(@"/nc/article/%@/0-20.html",tmpPath);
    }else {
        url_str = PBFormat(@"/nc/article/%@/%ld-20.html",tmpPath,(self.dataSource.count - self.dataSource.count%10));
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
            
            //切换到主线程刷新UI
            weakify(self)
            PBMAIN( ^{
                strongify(self)
                self.currentPage++;
                self.maskView.hidden = true;
                if (page == 1) {
                    [self.dataSource removeAllObjects];
                    _dataSource = nil;
                    self.dataSource = [NSMutableArray arrayWithArray:[tmpModels copy]];
                }else {
                    //剔除ads
                    [tmpModels enumerateObjectsUsingBlock:^(NHNews *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.hasAD || !PBIsEmpty(obj.ads)) {
                            [tmpModels removeObject:obj];
                        }
                    }];
                    [self.dataSource addObjectsFromArray:[tmpModels copy]];
                }
                [self endRefreshing];
                [self.table reloadData];
            });
            if (page == 1) {
                //如果是第一页数据则清除所有旧数据
                [[NHDBEngine share] clearNewsForChannel:self.channel];
                [[NHDBEngine share] saveNews:tmpArray forChannel:self.channel];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            PBMAIN(^{[self endRefreshing];});
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    });
}

#pragma mark -- outside control --

- (void)willDisplayChannel:(nonnull NSString *)channel {
    //NSLog(@"old:%@----new:%@",self.channel,channel);
    if (PBIsEmpty(channel) || (!PBIsEmpty(channel) && [channel isEqualToString:self.channel])) {
        return;
    }
    //显示Mask
    //self.maskView.hidden = false;
    //[self bringSubviewToFront:self.maskView];
    self.infos = [[NHSetsEngine share] getInfoForChannel:channel];
    [self preLoadNewsDataInitForChannel:channel];
    
    //[self ifNeedUpdateToHeadWhenDidEndDisplay];
}

- (void)viewDidAppearForChannel:(NSString *)channel {
    
    if (![channel isEqualToString:self.channel]) {
        self.channel = [channel copy];
        self.infos = [[NHSetsEngine share] getInfoForChannel:channel];
    }
    
    NSString *updateKey = PBFormat(@"news_update_key_%@",self.channel);
    self.table.mj_header.lastUpdatedTimeKey = updateKey;
    
    [self ifNeedUpdateToHeadWhenDidEndDisplay];
}

- (void)forceRefreshing {
    NSLog(@"强制刷新");
    weakify(self)
    PBMAIN(^{
        strongify(self)
        [self.table.mj_header beginRefreshing];
    });
}

//在endDisplay 后可置为低内存状态
- (void)resetToLowwerMemoryState {
    //TODO:低内存状态设置
}

- (void)didEndDisplayChannel:(nonnull NSString *)channel {
    [self resetToLowwerMemoryState];
}

#pragma mark -- TableView Delegate && DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger counts = self.dataSource.count;
    if (counts == 0) {
        counts = 1;//默认页面
    }
    return counts;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //占位处理
    if (PBIsEmpty(self.dataSource)) {
        return CGRectGetHeight(self.bounds);
    }
    
    int __row = (int)[indexPath row];
    NHNews *tmp = [self.dataSource objectAtIndex:__row];
    CGFloat __row_height = [NHNewsTitleCell heightForSource:tmp];
    if ((__row%20 == 0) && (__row != 0)) {
        __row_height = 80.f;
    }
    return __row_height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (PBIsEmpty(self.dataSource)) {
        static NSString *identifier = @"emptyCell";
        NHNewsTitleCell *cell = [[NHNewsTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell configureEmpty:CGRectGetHeight(self.bounds)];
        return cell;
    }else {
        int __row = (int)[indexPath row];
        NHNews *tmp = [self.dataSource objectAtIndex:__row];
        NSString *identifier = [NHNewsTitleCell identifierForSource:tmp];
        NHNewsTitleCell *cell = (NHNewsTitleCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[NHNewsTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        [cell dealWithAds:^(NSDictionary * _Nonnull info) {
            if (_adsBlock) {
                _adsBlock(info);
            }
        }];
        [cell configureForSource:tmp];
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int __row = (int)[indexPath row];
    NHNews *tmp = [self.dataSource objectAtIndex:__row];
    //NSLog(@"你点击了:%@",tmp.title);
    if (_newsBlock) {
        _newsBlock(tmp);
    }
    BOOL read = [[NHDBEngine share] alreadyReadDoc:tmp.docid];
    if (!read) {
        PBBACK(^{[[NHDBEngine share] readNews:tmp];});
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark -- Touch Event Block --

- (void)handleNewsTouchEvent:(NHNewsTouchEvent _Nonnull)event {
    _newsBlock = [event copy];
}

- (void)handleADsTouchEvent:(NHADsTouchEvent)event {
    _adsBlock = [event copy];
}

@end

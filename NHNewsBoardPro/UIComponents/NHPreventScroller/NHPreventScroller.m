//
//  NHPreventScroller.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/8.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHPreventScroller.h"
#import "NHPreventCustomer.h"
#import "NHConstaints.h"

/**在同一时刻最多显示的page个数**/
static const int NH_MAX_LOAD_PAGE_NUM               = 6;

@interface NHPreventScroller ()<UIScrollViewDelegate>

@property (nonatomic, strong, nonnull) NSMutableArray *cnnSets;
@property (nonatomic, strong, nonnull) NSMutableArray *cnnPageSets;

//@property (nonatomic, assign) NSUInteger selectedIdx;
@property (nonatomic, copy) NSString *selectedCnn;

/**
 *  @brief 上次offset x位置
 */
@property (nonatomic, assign) CGFloat lastXposit;

/**
 *  @brief 最多预加载页面个数
 */
@property (nonatomic, assign) NSUInteger maxLoadPageNums;

@end

@implementation NHPreventScroller

- (id)initWithFrame:(CGRect)frame withCnns:(NSArray * _Nonnull)cnns{
    self = [super initWithFrame:frame];
    if (self) {
        _cnnSets = [NSMutableArray arrayWithArray:cnns];
        [self __initSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (void)__initSetup {
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //锁定滚动方向
    self.pagingEnabled = true;
    self.scrollsToTop = true;
    self.showsHorizontalScrollIndicator = false;
    self.showsVerticalScrollIndicator = false;
    self.directionalLockEnabled = true;
    self.delegate = self;
    [self updatePreloadNums];
    //self.selectedIdx = 0;
    NSUInteger selectedIdx = [self currntPageIdx];
    
    _cnnPageSets = [NSMutableArray array];
    
    weakify(self)
    CGSize size = [self pageSize];
    __block CGRect bounds = (CGRect){.origin=CGPointZero,.size=size};
    @synchronized (self.cnnSets) {
        [self.cnnSets enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //NSLog(@"building...----->%@",obj);
            strongify(self)
            CGPoint _origin = CGPointMake(size.width*idx, 0);
            bounds.origin = _origin;
            NHPreventCustomer *preventPage = [self m_newInstance:bounds cnn:obj pageIdx:idx];
            [self addSubview:preventPage];
            [self.cnnPageSets addObject:preventPage];
            if (idx == selectedIdx) {
                [preventPage preventLoad];
            }
            
            weakify(self)
            [preventPage handleNewsTouchEvent:^(NHNews * _Nonnull news) {
                strongify(self)
                if (_preventDelegate && [_preventDelegate respondsToSelector:@selector(preventScroller:didSelectNews:)]) {
                    [_preventDelegate preventScroller:self didSelectNews:news];
                }
            }];
            [preventPage handleADsTouchEvent:^(NSDictionary * _Nonnull ads) {
                strongify(self)
                if (_preventDelegate && [_preventDelegate respondsToSelector:@selector(preventScroller:didSelectADs:)]) {
                    [_preventDelegate preventScroller:self didSelectADs:ads];
                }
            }];
        }];
    }
    
    NHPreventCustomer *__tmp_page = [self.cnnPageSets firstObject];
    [__tmp_page viewDidAppear];
    
    [self updateContentSize];
    
    [self updatePreloadAroundSelectedIdx];
}

//创建新的page
- (NHPreventCustomer *)m_newInstance:(CGRect)bounds cnn:(NSString *)cnn pageIdx:(NSUInteger)idx {
    NHPreventCustomer *preventPage = [NHPreventCustomer prevent:bounds withChannel:cnn];
    preventPage.pageIdx = idx;
    return preventPage;
}

//更新content size
- (void)updateContentSize {
    CGSize size = [self pageSize];NSUInteger counts = self.cnnSets.count;
    CGSize conn_size = CGSizeMake(size.width*counts, size.height);
    self.contentSize = conn_size;
}

//滚动到第一个栏目
- (void)updatePlace2ShowFirstCnn {
    CGPoint offset = CGPointZero;
    [self setContentOffset:offset animated:false];
}

//滚动到当前选择的栏目
- (void)updateOffset2SelectedCnn {
    CGSize size = [self pageSize];
    NSUInteger idx = [self getPageIdxForCnn:self.selectedCnn];
    CGPoint offset = CGPointMake(size.width*idx, 0);
    [self setContentOffset:offset animated:false];
}

- (CGSize)pageSize {
    CGSize size = [self bounds].size;
    return CGSizeMake(floorf(size.width), floorf(size.height));
}
//更新预加载页数
- (void)updatePreloadNums {
    NSUInteger counts = [self.cnnSets count];
    self.maxLoadPageNums = NH_MAX_LOAD_PAGE_NUM;
    if (counts < NH_MAX_LOAD_PAGE_NUM) {
        self.maxLoadPageNums = counts;
    }
}

//更新附近preload
- (void)updatePreloadAroundSelectedIdx {
    
    NSUInteger selectedIdx = [self currntPageIdx];
    NSUInteger counts = [self.cnnSets count];
    if (selectedIdx >= counts) {
        return;
    }
    
    //预加载左右各一个页面
    NSInteger pre_leading = selectedIdx-1;
    if (pre_leading >= 0) {
        NHPreventCustomer *__tmp_page = [self.cnnPageSets objectAtIndex:pre_leading];
        if (__tmp_page) {
            [__tmp_page preventLoad];
        }
    }
    NSInteger pre_tailing = selectedIdx+1;
    if (pre_tailing < counts) {
        NHPreventCustomer *__tmp_page = [self.cnnPageSets objectAtIndex:pre_tailing];
        if (__tmp_page) {
            [__tmp_page preventLoad];
        }
    }
    
    @synchronized (self.cnnPageSets) {
        NSUInteger displayCounts = [self getDisplayingPageCounts];
        NSLog(@"此刻正在显示的page个数：%zd--->",displayCounts);
        if (displayCounts > self.maxLoadPageNums) {
            NSArray *tmpDisplay = [self sortDisplayedDesc];
            for (int i = self.maxLoadPageNums; i < counts; i++) {
                NHPreventCustomer *__tmp_page = [tmpDisplay objectAtIndex:i];
                if (__tmp_page) {
                    [__tmp_page reset2LowwerPowerState];
                }
            }
            displayCounts = [self getDisplayingPageCounts];
            NSLog(@"修正后－－此刻正在显示的page个数：%zd--->",displayCounts);
        }
    }
}

//获取目前显示的page个数
- (NSUInteger)getDisplayingPageCounts {
    __block NSUInteger __count = 0;
    @synchronized (self.cnnPageSets) {
        [self.cnnPageSets enumerateObjectsUsingBlock:^(NHPreventCustomer *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.state == NHPreventStateShowing) {
                __count++;
            }
        }];
    }
    return __count;
}

//根据显示时间降序排列
- (NSArray *)sortDisplayedDesc {
    NSArray *tmp = [self.cnnPageSets copy];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_showDate" ascending:false];
    NSArray *__tmp = [tmp sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    return __tmp;
}

#pragma mark -- scrollview delegate

- (NSUInteger)currntPageIdx {
    
    float contentOffset_x = self.contentOffset.x;
    CGFloat width = floorf(CGRectGetWidth(self.bounds));
    NSUInteger page = (contentOffset_x + (0.5f * width)) / width;
    return page;
}

- (NHPreventCustomer *)currentPager {
    
    NSUInteger selectedIdx = [self currntPageIdx];
    NHPreventCustomer *__tmp_page = [self.cnnPageSets objectAtIndex:selectedIdx];
    if (__tmp_page != nil) {
        return __tmp_page;
    }
    return nil;
}

- (void)updateSelectedCnn:(NSString *)cnn {
    
    if ([cnn isEqualToString:self.selectedCnn]) {
        return;
    }
    _selectedCnn = [cnn copy];
}

- (NHPreventCustomer *)getPageAtIdx:(NSUInteger)idx {
    
    NHPreventCustomer *__tmp_page = [self.cnnPageSets objectAtIndex:idx];
    if (__tmp_page != nil) {
        return __tmp_page;
    }
    return nil;
}

- (NSUInteger)getPageIdxForCnn:(NSString *)cnn {
    NSUInteger __tmp_idx = 0;
    @synchronized (self.cnnSets) {
        if ([self.cnnSets containsObject:cnn]) {
            __tmp_idx = [self.cnnSets indexOfObject:cnn];
        }
    }
    return __tmp_idx;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    /*TODO:此处滑过边界时没有正确回调
    CGFloat offset_x = scrollView.contentOffset.x;
    CGSize size = [self pageSize];
    if (((int)offset_x)%((int)size.width) == 0) {
        //翻页触发
        if (offset_x <= 0 || offset_x >= (scrollView.contentSize.width-size.width)) {
            return;
        }
        BOOL isRight2Show = offset_x > self.lastXposit;
        NSInteger __dest_idx = self.selectedIdx + (isRight2Show?(1):(-1));
        NSLog(@"tmp dest idx:%zd",__dest_idx);
        if (__dest_idx < 0 || __dest_idx > self.cnnSets.count-1) {
            return;
        }
        NHPreventCustomer *__tmp_page = [self getPageAtIdx:__dest_idx];
        [__tmp_page viewWillAppear];
    }
    self.lastXposit = offset_x;
    //*/
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //NSUInteger selectedIdx = [self currntPageIdx];
    NHPreventCustomer *__tmp_page = [self currentPager];
    //NSUInteger __tmp_page_idx = [self currntPageIdx];
    if ([__tmp_page.cnn isEqualToString:self.selectedCnn]) {
        return;
    }
    
    [self updateSelectedCnn:__tmp_page.cnn];
    
    //self.selectedIdx = __tmp_page_idx;
    //NHPreventCustomer *__tmp_page = [self currentPager];
    [__tmp_page viewDidAppear];
    
    //通知回调
    if (_preventDelegate && [_preventDelegate respondsToSelector:@selector(preventScroller:didShowCnn:)]) {
        [_preventDelegate preventScroller:self didShowCnn:self.selectedCnn];
    }
    //预加载
    [self updatePreloadAroundSelectedIdx];
}

#pragma mark -- 编辑完毕强制刷新
- (void)viewDidAppear {
    NHPreventCustomer *__tmp_page = [self currentPager];
    [__tmp_page viewDidAppear];
}

#pragma mark -- 栏目编辑事件

- (void)endReceivedTouchEvent {
    self.userInteractionEnabled = false;
}

- (void)startReceivedTouchEvent {
    self.userInteractionEnabled = true;
}

- (void)preventScrollChange2Cnn:(NSString * _Nonnull)cnn {
    
    if (![self.cnnSets containsObject:cnn]) {
        NSLog(@"你选择的栏目:%@不存在！",cnn);
        return;
    }
    NSUInteger idx = [self.cnnSets indexOfObject:cnn];
    if ([self.selectedCnn isEqualToString:cnn]) {
        return;
    }
    [self updateSelectedCnn:cnn];
    CGSize size = [self pageSize];
    CGPoint __offset = CGPointMake(size.width*idx, 0);
    [self setContentOffset:__offset animated:false];
    NHPreventCustomer *__tmp_page = [self currentPager];
    [__tmp_page viewDidAppear];
    
    //缓存策略
    [self updatePreloadAroundSelectedIdx];
}

- (void)preventScrollEdit:(BOOL)add idx:(NSUInteger)idx cnn:(NSString *)cnn {
    
    if (add) {
        //增加订阅栏目
        if ([self.cnnSets containsObject:cnn]) {
            NSLog(@"添加订阅栏目 发生错误！");
            return;
        }
        
        CGSize size = [self pageSize];
        NSUInteger counts = [self.cnnSets count];
        CGRect bounds = (CGRect){.origin = CGPointMake(size.width*counts, 0), .size = size};
        NHPreventCustomer *preventPage = [self m_newInstance:bounds cnn:cnn pageIdx:idx];
        [self addSubview:preventPage];
        [self.cnnPageSets addObject:preventPage];
        [self.cnnSets addObject:cnn];
        
        [self updateContentSize];
    }else{
        //取消订阅栏目
        if (![self.cnnSets containsObject:cnn]) {
            NSLog(@"取消订阅栏目 发生错误！");
            return;
        }
        CGSize size = [self pageSize];
        __block CGRect bounds = (CGRect){.origin = CGPointZero, .size = size};
        NSUInteger __tmp_idx = [self getPageIdxForCnn:cnn];
        [self.cnnSets removeObjectAtIndex:__tmp_idx];
        @synchronized (self.cnnPageSets) {
            NSUInteger __tmp_counts = [self.cnnPageSets count];
            for (int i = __tmp_idx+1; i < __tmp_counts; i++) {
                CGPoint __origin = CGPointMake(size.width*(i-1), 0);
                bounds.origin = __origin;
                NHPreventCustomer *__tmp_page = [self.cnnPageSets objectAtIndex:i];
                __tmp_page.pageIdx = i-1;
                PBMAIN(^{__tmp_page.frame = bounds;});
            }
            NHPreventCustomer *__tmp_page = [self.cnnPageSets objectAtIndex:__tmp_idx];
            [__tmp_page removeFromSuperview];
            [self.cnnPageSets removeObjectAtIndex:__tmp_idx];
        }
        [self updateContentSize];
        
        //如果删除当前选中的栏目 则默认滚动到第一个栏目
        if ([cnn isEqualToString:self.selectedCnn]) {
            [self updatePlace2ShowFirstCnn];
            [self updateSelectedCnn:NHNewsForceUpdateChannel];
        }
    }
    
    //NSLog(@"取消、增加订阅后:%@",self.cnnSets);
    //TODO:保存当前列表到数据库
}

- (void)preventScrollSort:(NSUInteger)originIdx destIdx:(NSUInteger)destIdx cnn:(NSString *)cnn {
    if (![self.cnnSets containsObject:cnn]) {
        NSLog(@"排序订阅栏目 发生错误！");
        return;
    }
    NSString *__tmp_cnn = [self.cnnSets objectAtIndex:destIdx];
    BOOL need_move = [cnn isEqualToString:self.selectedCnn]||[__tmp_cnn isEqualToString:self.selectedCnn];
    //NSLog(@"排序栏目:%@",cnn);
    [self.cnnSets removeObjectAtIndex:originIdx];
    [self.cnnSets insertObject:cnn atIndex:destIdx];
    
    CGSize size = [self pageSize];
    __block CGRect bounds = (CGRect){.origin = CGPointMake(size.width*destIdx, 0), .size = size};
    NHPreventCustomer *__tmp_page = [self.cnnPageSets objectAtIndex:originIdx];
    [__tmp_page removeFromSuperview];
    [self.cnnPageSets removeObjectAtIndex:originIdx];
    __tmp_page = [self m_newInstance:bounds cnn:cnn pageIdx:destIdx];
    [self addSubview:__tmp_page];
    [self.cnnPageSets insertObject:__tmp_page atIndex:destIdx];
    [__tmp_page preventLoad];
    
    NSUInteger __start_idx = originIdx;NSUInteger __end_idx = destIdx;
    if (originIdx > destIdx) {
        __start_idx = destIdx;__end_idx = originIdx;
    }
    //移动位置
    //NSUInteger __tmp_idx = [self getPageIdxForCnn:cnn];
    @synchronized (self.cnnPageSets) {
        for (int i = __start_idx; i < __end_idx+1; i++) {
            CGPoint __origin = CGPointMake(size.width*i, 0);
            bounds.origin = __origin;
            //NSLog(@"交换idx:%d--bounds:%@",i,NSStringFromCGRect(bounds));
            NHPreventCustomer *__tmp_page = [self.cnnPageSets objectAtIndex:i];
            //NSLog(@"target:%@",__tmp_page.cnn);
            __tmp_page.pageIdx = i;
            __tmp_page.frame = bounds;
        }
    }
    
    
    if (need_move) {
        //需要滚动到当前显示
        NSLog(@"交换选中栏目 滚动到当前显示");
        [self updateOffset2SelectedCnn];
        [__tmp_page viewDidAppear];
    }
    
    //TODO:保存当前列表到数据库
}

@end

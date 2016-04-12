//
//  NHPreventScroller.m
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/8.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHPreventScroller.h"
#import "NHPreventCustomer.h"

/**在同一时刻最多显示的page个数**/
static const int NH_MAX_LOAD_PAGE_NUM               = 6;

@interface NHPreventScroller ()<UIScrollViewDelegate>

@property (nonatomic, strong, nonnull) NSMutableArray *cnnSets;
@property (nonatomic, strong, nonnull) NSMutableArray *cnnPageSets;

@property (nonatomic, assign) NSUInteger selectedIdx;

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
    self.selectedIdx = 0;
    
    _cnnPageSets = [NSMutableArray array];
    
    weakify(self)
    CGSize size = [self pageSize];NSUInteger counts = self.cnnSets.count;
    __block CGRect bounds = (CGRect){.origin=CGPointZero,.size=size};
    @synchronized (self.cnnSets) {
        [self.cnnSets enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"building...----->%@",obj);
            strongify(self)
            CGPoint _origin = CGPointMake(size.width*idx, 0);
            bounds.origin = _origin;
            NHPreventCustomer *preventPage = [NHPreventCustomer prevent:bounds withChannel:obj];
            preventPage.pageIdx = idx;
            [self addSubview:preventPage];
            [self.cnnPageSets addObject:preventPage];
            if (idx == self.selectedIdx) {
                [preventPage preventLoad];
            }
        }];
    }
    
    NHPreventCustomer *__tmp_page = [self.cnnPageSets firstObject];
    [__tmp_page viewDidAppear];
    
    CGSize conn_size = CGSizeMake(size.width*counts, size.height);
    self.contentSize = conn_size;
    
    [self updatePreloadAroundSelectedIdx];
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
    NSUInteger counts = [self.cnnSets count];
    if (self.selectedIdx >= counts) {
        return;
    }
    
    //预加载左右各一个页面
    NSInteger pre_leading = self.selectedIdx-1;
    if (pre_leading >= 0) {
        NHPreventCustomer *__tmp_page = [self.cnnPageSets objectAtIndex:pre_leading];
        if (__tmp_page) {
            [__tmp_page preventLoad];
        }
    }
    NSInteger pre_tailing = self.selectedIdx+1;
    if (pre_tailing < counts) {
        NHPreventCustomer *__tmp_page = [self.cnnPageSets objectAtIndex:pre_tailing];
        if (__tmp_page) {
            [__tmp_page preventLoad];
        }
    }
    
    @synchronized (self.cnnPageSets) {
        NSUInteger displayCounts = [self getDisplayingPageCounts];
        if (displayCounts > self.maxLoadPageNums) {
            NSArray *tmpDisplay = [self sortDisplayedDesc];
            for (int i = self.maxLoadPageNums; i < counts; i++) {
                NHPreventCustomer *__tmp_page = [tmpDisplay objectAtIndex:pre_tailing];
                if (__tmp_page) {
                    [__tmp_page reset2LowwerPowerState];
                }
            }
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

- (NSUInteger)currntPage {
    float contentOffset_x = self.contentOffset.x;
    CGFloat width = floorf(CGRectGetWidth(self.bounds));
    NSUInteger page = (contentOffset_x + (0.5f * width)) / width;
    return page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSUInteger __tmp_page_idx = [self currntPage];
    self.selectedIdx = __tmp_page_idx;
    NHPreventCustomer *__tmp_page = [self.cnnPageSets objectAtIndex:__tmp_page_idx];
    if (__tmp_page != nil) {
        [__tmp_page viewDidAppear];
    }
    
    [self updatePreloadAroundSelectedIdx];
}

#pragma mark -- 栏目编辑事件

- (void)preventScrollChange2Index:(NSUInteger)idx {
    self.selectedIdx = idx;
    
    [self updatePreloadAroundSelectedIdx];
}

- (void)preventScrollEdit:(BOOL)add idx:(NSUInteger)idx cnn:(NSString *)cnn {
    
}

- (void)preventScrollSort:(NSUInteger)originIdx destIdx:(NSUInteger)destIdx cnn:(NSString *)cnn {
    
}

@end

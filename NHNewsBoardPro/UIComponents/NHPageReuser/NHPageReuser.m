//
//  NHPageReuser.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/24.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

static int NHReuseMaxCount       =     5;
//static int NHReuseInvalidTag     =    -1;

#import "NHPageReuser.h"

@interface NHPageReuser ()<UIScrollViewDelegate>{
    
    NHPage *pageCells[5];
}

@property (nonatomic, assign) BOOL swipeToRight,outTrigger;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSUInteger trackerIdx,pageCount,sizeCount,curPage;
@property (nonatomic, strong) NSMutableDictionary *identifierDict;
@property (nullable, nonatomic, strong) NSMutableArray<NHPage *> *reusePages;

@end

@implementation NHPageReuser

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.identifierDict = [NSMutableDictionary dictionary];
        self.pageCount = 0;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(NHReuseMaxCount*CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = true;
        self.scrollView.showsHorizontalScrollIndicator = false;
        self.scrollView.scrollsToTop = false;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (NSUInteger)pageCount{
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    NSUInteger counts = [_dataSource numberOfCountsInReuseView:self];
    NSAssert(counts > 0, @"review page number must more than one !");
    _sizeCount = MIN(counts, NHReuseMaxCount);
    self.scrollView.contentSize = CGSizeMake(_sizeCount*CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    return counts;
}

- (NHPage *)setupPageCell:(NSUInteger)pageIdx {
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    NHPage *cell = [_dataSource review:self pageViewAtIndex:pageIdx];
    return cell;
}

- (void)setReuseSelectIndex:(NSInteger)index {
    NSInteger currentPage = _trackerIdx + [self scrollViewInnerPage];
    if (index == currentPage) {
        return;
    }
    _outTrigger = true;
    if (index >= _trackerIdx && index < (_trackerIdx+_sizeCount)) {
        ///在窗口内
        NSInteger offset = index-_trackerIdx;
        [_scrollView setContentOffset:CGPointMake(offset*CGRectGetWidth(self.scrollView.bounds), 0) animated:true];
    }else{
        ///窗口外
        if (index > _trackerIdx) {
            ///在右边
            [self clearPointer];
            _trackerIdx = index-_sizeCount+1;
            CGPoint offset = CGPointMake((_sizeCount-1)*CGRectGetWidth(self.scrollView.bounds), 0);
            NHPage *newPage = [self setupPageCell:index];
            [newPage viewWillApear];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.scrollView addSubview:newPage];
            });
            pageCells[_sizeCount-1] = newPage;
            [self updateInuseCellFrame];
            [self.scrollView setContentOffset:offset animated:true];
            //[self.scrollView setContentOffset:offset];
        }else{
            ///在左边
            [self clearPointer];
            _trackerIdx = index;
            CGPoint offset = CGPointZero;
            NHPage *newPage = [self setupPageCell:index];
            [newPage viewWillApear];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.scrollView addSubview:newPage];
            });
            pageCells[0] = newPage;
            [self updateInuseCellFrame];
            [self.scrollView setContentOffset:offset animated:true];
            //[self.scrollView setContentOffset:offset];
        }
    }
}

- (void)setDataSource:(id<NHPageReuserDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)reloadData {
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    if ([_dataSource respondsToSelector:@selector(numberOfCountsInReuseView:)]) {
        NSUInteger counts  = [self pageCount];
        if (counts > 0) {
            _outTrigger = false;
            self.trackerIdx = 0;///window's index
            [_identifierDict removeAllObjects];
            [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            self.scrollView.contentOffset = CGPointZero;
            int count = [self pageSize];
            for (int i = 0; i < count; i++) {
                NHPage *pageCell = [self setupPageCell:self.trackerIdx+i];
                [self.scrollView addSubview:pageCell];
                pageCells[i] = pageCell;
            }
            [self updateInuseCellFrame];
        }
    }
}

- (NSMutableArray *)obtainCacheWithIdentifier:(NSString *)identifier{
    NSMutableArray *pageCacheArr = [_identifierDict objectForKey:identifier];
    if (pageCacheArr == nil || [pageCacheArr count] <= 0) {
        pageCacheArr = [NSMutableArray array];
        [_identifierDict setObject:pageCacheArr forKey:identifier];
    }
    //NSInteger count = [pageCacheArr count];
    //NSLog(@"reuse queue counts:%zd",count);
    return pageCacheArr;
}

- (void)queueReusablePageWithIdentifier:(NHPage *)page {
    if (page == nil) {
        return;
    }
    NSMutableArray *pageCacheArr = [self obtainCacheWithIdentifier:page.identifier];
    [pageCacheArr addObject:page];
    [page removeFromSuperview];
}

- (NHPage *)dequeueReusablePageWithIdentifier:(NSString *)identifier {
    NSMutableArray *pageCacheArr = [self obtainCacheWithIdentifier:identifier];
    NHPage *page = [pageCacheArr lastObject];
    NHPage *dstCell = nil;
    if (page) {
        //NSLog(@"reuse old page");
        //dstCell = [page mutableCopy];
        dstCell = page;
        [pageCacheArr removeLastObject];
    }
    return dstCell;
}

- (void)setTrackerIdx:(NSUInteger)trackerIdx{
    _trackerIdx = trackerIdx;
}

- (int)pageSize{
    int count = sizeof(pageCells)/sizeof(pageCells[0]);
    return count;
}

- (void)clearPointer{
    int count = [self pageSize];
    for (int i = 0; i< count; i++) {
        [self queueReusablePageWithIdentifier:pageCells[i]];
        pageCells[i] = nil;
    }
}

- (void)updatePointerAhead:(BOOL)ahead{
    
    int count = sizeof(pageCells)/sizeof(pageCells[0]);
    if (ahead) {
        [self queueReusablePageWithIdentifier:pageCells[count-1]];
        //NHPage *firstPointer = pageCells[count-1];
        for (int i = count-1; i > 0; i--) {
            pageCells[i] = pageCells[i-1];
        }
        pageCells[0] = nil;
    }else{
        ///将第一页缓存
        [self queueReusablePageWithIdentifier:pageCells[0]];
        //NHPage *firstPointer = pageCells[0];
        for (int i = 0; i< count-1; i++) {
            pageCells[i] = pageCells[i+1];
        }
        pageCells[count-1] = nil;
    }
}

- (void)updateInuseCellFrame {
    
    int count = sizeof(pageCells)/sizeof(pageCells[0]);
    for (int i = 0; i< count; i++) {
        CGRect infoRect = CGRectMake(i*CGRectGetWidth(self.scrollView.bounds), 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
        if (pageCells[i] != nil) {
            pageCells[i].frame = infoRect;
            //NSLog(@"frame:%@--%@",NSStringFromCGRect(infoRect),pageCells[i].channel);
        }
    }
}

- (void)updateReuseCellFrameAhead:(BOOL)ahead {
    @synchronized(_scrollView) {
        CGFloat width = CGRectGetWidth(self.scrollView.bounds);
        NSArray *subviews = [_scrollView subviews];
        for (UIView *tmp in subviews) {
            if ([tmp isKindOfClass:[NHPage class]]) {
                CGRect frame = tmp.frame;
                ahead?(frame.origin.x+=width):(frame.origin.x-=width);
            }
        }
        CGPoint offset = CGPointMake(ahead?1*width:4*width, 0);
        [self.scrollView setContentOffset:offset];
    }
}

- (NSInteger)scrollViewInnerPage{
    float contentOffset_x = self.scrollView.contentOffset.x;
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
    NSInteger page = (contentOffset_x + (0.5f * width)) / width;
    return page;
}

#pragma mark -- ScrollView Delegate --

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //    if (_outTrigger) {
    //        return;
    //    }
    
    float contentOffset_x = scrollView.contentOffset.x;
    //NSLog(@"offset:%f",contentOffset_x);
    NSInteger page = [self scrollViewInnerPage];
    CGFloat width = CGRectGetWidth(scrollView.bounds);
    BOOL swipe2Right = contentOffset_x < page*width;
    BOOL swipe2Left  = contentOffset_x > page*width;
    if (swipe2Right) {
        ///向右滑动 需要显示左边的view
        
        NSInteger page_idx = page - 1;
        //NSLog(@"右滑index:%zd",page_idx);
        if (page_idx>=0&&pageCells[page_idx] == nil) {
            
            [pageCells[page_idx] viewWillDisappear];
            if (_delegate && [_delegate respondsToSelector:@selector(review:willDismissIndex:)]) {
                [_delegate review:self willDismissIndex:page];
            }
            
            //NSLog(@"中间移动 idx:%zd",page_idx);
            NSInteger winIndex = self.trackerIdx+page_idx;
            NHPage *newPage = [self setupPageCell:winIndex];
            [newPage viewWillApear];
            [self.scrollView addSubview:newPage];
            pageCells[page_idx] = newPage;
            [self updateInuseCellFrame];
        }
    }
    
    /// 如果等于则忽略
    
    if (swipe2Left) {
        ///向左滑动 需要显示右边的view
        
        NSInteger page_idx = page + 1;
        //NSLog(@"左滑index:%zd",page_idx);
        if (page_idx<_sizeCount&&pageCells[page_idx] == nil) {
            
            [pageCells[page_idx] viewWillDisappear];
            if (_delegate && [_delegate respondsToSelector:@selector(review:willDismissIndex:)]) {
                [_delegate review:self willDismissIndex:page];
            }
            
            //NSLog(@"中间移动 idx:%zd",page_idx);
            NSInteger winIndex = self.trackerIdx+page_idx;
            NHPage *newPage = [self setupPageCell:winIndex];
            [newPage viewWillApear];
            [self.scrollView addSubview:newPage];
            pageCells[page_idx] = newPage;
            [self updateInuseCellFrame];
        }
    }
    
    //NSLog(@"swipe2Right:%d",swipe2Right);
    
    if (contentOffset_x < 0) {
        //是否向前翻页
        _swipeToRight = false;
        NSInteger winIndex = self.trackerIdx-1;
        if (winIndex >= 0) {
            //NSLog(@"需要向左移动");
            
            [pageCells[0] viewWillDisappear];
            /// dismiss notify
            if (_delegate && [_delegate respondsToSelector:@selector(review:willDismissIndex:)]) {
                [_delegate review:self willDismissIndex:self.trackerIdx];
            }
            [self updatePointerAhead:true];
            ///首先移动tracker index
            self.trackerIdx--;
            
            NHPage *newPage = [self setupPageCell:winIndex];
            [newPage viewWillApear];
            [self.scrollView addSubview:newPage];
            pageCells[0] = newPage;
            [self updateInuseCellFrame];
            [self updateScrollViewContentOffset];
            
        }
    }
    
    if (contentOffset_x > width*(_sizeCount-1) && contentOffset_x <= width*_sizeCount){
        //是否向后翻页
        _swipeToRight = true;
        NSInteger winIndex = self.trackerIdx+_sizeCount;
        if (winIndex < self.pageCount) {
            //NSLog(@"需要向右移动");
            
            [pageCells[_sizeCount-1] viewWillDisappear];
            /// dismiss notify
            if (_delegate && [_delegate respondsToSelector:@selector(review:willDismissIndex:)]) {
                [_delegate review:self willDismissIndex:winIndex-1];
            }
            [self updatePointerAhead:false];
            ///首先移动tracker index
            self.trackerIdx++;
            
            NHPage *newPage = [self setupPageCell:winIndex];
            [newPage viewWillApear];
            int size = [self pageSize];
            [self.scrollView addSubview:newPage];
            pageCells[size-1] = newPage;
            [self updateInuseCellFrame];
            [self updateScrollViewContentOffset];
        }
    }
    
    
    //NSLog(@"page_idx:%d",page_idx);
    
}

- (void)updateScrollViewContentOffset{
    ///change offset
    [self.scrollView setContentOffset:CGPointMake(_swipeToRight?CGRectGetWidth(self.scrollView.bounds)*(_sizeCount-2):CGRectGetWidth(self.scrollView.bounds), 0)];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _curPage = _trackerIdx + [self scrollViewInnerPage];
    //NSLog(@"current page:%zd",_curPage);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSInteger tmpPage = _trackerIdx + [self scrollViewInnerPage];
    if (_curPage != tmpPage) {
        [pageCells[tmpPage-_trackerIdx] viewWillDisappear];
        if (_delegate && [_delegate respondsToSelector:@selector(review:willDismissIndex:)]) {
            [_delegate review:self willDismissIndex:_curPage];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSInteger page = [self scrollViewInnerPage];
    //NSLog(@"dst page:%zd",page);
    
    NSInteger winIndex = _trackerIdx+page;
    if (_delegate && [_delegate respondsToSelector:@selector(review:didChangeToIndex:)]) {
        [_delegate review:self didChangeToIndex:winIndex];
    }
    
    _outTrigger = false;
}

@end

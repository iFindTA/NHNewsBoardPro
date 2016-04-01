//
//  NHReView.m
//  NHReuseCellPro
//
//  Created by hu jiaju on 15/9/21.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHReView.h"
#import "NHScrollView.h"

@interface NHReView ()<UIScrollViewDelegate,NHScrollDelegate>

@property (nonatomic, strong) NHScrollView *scrollView;
@property (nonatomic, strong) NHReCell *prePage,*curPage,*nexPage;
@property (nonatomic, assign) NSUInteger prePageIdx,curPageIdx,nexPageIdx,pageCount;
@property (nonatomic, strong) NSMutableDictionary *identifierDict;

@property (nonatomic, strong) UILabel *flagLabel;

@end

@implementation NHReView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.identifierDict = [NSMutableDictionary dictionary];
        self.pageCount = 0;
        self.curPage = 0;
        self.scrollView = [[NHScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3*CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
        self.scrollView.delegate = self;
        self.scrollView.touchDelegate = self;
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds), 0);
        self.scrollView.pagingEnabled = true;
        self.scrollView.showsHorizontalScrollIndicator = false;
        self.scrollView.scrollsToTop = false;
        [self addSubview:self.scrollView];
        
        CGFloat offset = 20;
        CGRect bounds = CGRectMake(offset, CGRectGetHeight(frame)-offset*1.3, PBSCREEN_WIDTH-offset*2, offset);
        _flagLabel = [[UILabel alloc] initWithFrame:bounds];
        _flagLabel.font = [UIFont systemFontOfSize:12];
        _flagLabel.textColor = [UIColor whiteColor];
        [self addSubview:_flagLabel];
    }
    return self;
}

- (void)setDataSource:(id<NHReViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
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

- (NHReCell *)dequeueReusablePageWithIdentifier:(NSString *)identifier forPageIndex:(NSUInteger)index{
    NSMutableArray *pageCacheArr = [self obtainCacheWithIdentifier:identifier];
    NHReCell *page = [pageCacheArr lastObject];
    NHReCell *dstCell ;
    if (page) {
        NSLog(@"reuse old page");
        dstCell = page;
//        dstCell = [page mutableCopy];
//        [pageCacheArr removeObject:page];
        [pageCacheArr removeLastObject];
    }/*else{
        NSLog(@"create new page");
//        dstCell = [[NHReCell alloc] initWithIdentifier:identifier];
        dstCell = [_dataSource review:self pageViewAtIndex:index];
    }*/
    return dstCell;
}

- (void)queueReusablePageWithIdentifier:(NHReCell *)page {
    if (page == nil) {
        return;
    }
    NSMutableArray *pageCacheArr = [self obtainCacheWithIdentifier:page.identifier];
    [pageCacheArr addObject:page];
    [page removeFromSuperview];
}

- (void)setCurPageIdx:(NSUInteger)curPageIdx{
    _curPageIdx = curPageIdx;
    NSUInteger pageCount = [self pageCount];
    if (pageCount > 0) {
        _prePageIdx = _curPageIdx == 0 ? pageCount-1:_curPageIdx-1;
        _nexPageIdx = _curPageIdx == (pageCount - 1)? 0:_curPageIdx+1;
        if (_delegate && [_delegate respondsToSelector:@selector(review:didChangeToIndex:)]) {
            [_delegate review:self didChangeToIndex:curPageIdx];
        }
    }else{
        _prePageIdx = 0;
        _nexPageIdx = 0;
    }
}

- (NHReCell *)setupPageCell:(NSUInteger)pageIdx {
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    NHReCell *cell = [_dataSource review:self pageViewAtIndex:pageIdx];
    return cell;
}

- (void)reloadData {
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    if ([_dataSource respondsToSelector:@selector(reviewPageCount:)]) {
        NSUInteger counts  = [self pageCount];
        self.scrollView.scrollEnabled = (counts > 1);
        if (counts > 0) {
            NHReCell *pageCell = [self setupPageCell:0];
            self.curPage = pageCell;
            self.curPageIdx = 0;
            self.curPage.frame = CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            [self.scrollView addSubview:self.curPage];
        }
    }
}

- (NSUInteger)pageCount{
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    NSUInteger counts = [_dataSource reviewPageCount:self];
    NSAssert(counts >= 0, @"review page number must more than one !");
    return counts;
}

- (void)prefPage {
    CGSize pageSize = self.scrollView.bounds.size;
    CGPoint offset = self.scrollView.contentOffset;
    offset.x -= pageSize.width;
    [self.scrollView setContentOffset:offset animated:true];
}

- (void)nextPage {
    CGSize pageSize = self.scrollView.bounds.size;
    CGPoint offset = self.scrollView.contentOffset;
    offset.x += pageSize.width;
    [self.scrollView setContentOffset:offset animated:true];
}

- (void)changeTitle:(NSString *)title {
    self.flagLabel.text = title;
}

#pragma mark -- ScrollView Delegate --

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float contentOffset_x = scrollView.contentOffset.x;
    if (contentOffset_x > scrollView.bounds.size.width) {
        /// add the pre page to cache
        [self queueReusablePageWithIdentifier:self.prePage];
        self.prePage = nil;
        ///display the next page
        if (self.nexPage == nil) {
            NHReCell *nexPage = [self setupPageCell:_nexPageIdx];
            CGRect infoRect = CGRectMake(self.curPage.frame.origin.x + self.curPage.frame.size.width, 0, self.curPage.frame.size.width, self.curPage.frame.size.height);
            nexPage.frame = infoRect;
            [self.scrollView addSubview:nexPage];
            self.nexPage = nexPage;
        }
    }else if (contentOffset_x < scrollView.bounds.size.width) {
        /// add the next page to cache
        [self queueReusablePageWithIdentifier:self.nexPage];
        self.nexPage = nil;
        ///display the pre page
        if (self.prePage == nil) {
            NHReCell *prePage = [self setupPageCell:_prePageIdx];
            CGRect infoRect = CGRectMake(self.curPage.frame.origin.x - self.curPage.frame.size.width, 0, self.curPage.frame.size.width, self.curPage.frame.size.height);
            prePage.frame = infoRect;
            [self.scrollView addSubview:prePage];
            self.prePage = prePage;
        }
    }
    
    if (contentOffset_x >= CGRectGetWidth(scrollView.frame)*2) {
        /// add the current page to cache and make the current page to next page
        [self queueReusablePageWithIdentifier:self.curPage];
        self.curPage = self.nexPage;
        self.nexPage = nil;
        if (_delegate && [_delegate respondsToSelector:@selector(review:willDismissIndex:)]) {
            [_delegate review:self willDismissIndex:self.curPageIdx];
        }
        self.curPageIdx = self.nexPageIdx;
        [self scrollViewDidEndDecelerating:scrollView];
    }else if (contentOffset_x <= 0){
        [self queueReusablePageWithIdentifier:self.curPage];
        self.curPage  = self.prePage;
        self.prePage = nil;
        if (_delegate && [_delegate respondsToSelector:@selector(review:willDismissIndex:)]) {
            [_delegate review:self willDismissIndex:self.curPageIdx];
        }
        self.curPageIdx = self.prePageIdx;
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0)];
    CGRect infoRect = CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.curPage.frame = infoRect;
}

- (void)scrollTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch ended!");
    if (_delegate && [_delegate respondsToSelector:@selector(review:didTouchIndex:)]) {
        [_delegate review:self didTouchIndex:self.curPageIdx];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

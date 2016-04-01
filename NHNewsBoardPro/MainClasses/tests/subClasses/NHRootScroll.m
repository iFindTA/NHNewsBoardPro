//
//  NHRootScroll.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/2/15.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHRootScroll.h"
#import "NHPager.h"
#import "NHBaseKits.h"

static NSInteger NHMinCacheCount = 1;
static NSInteger NHMaxCacheCount = 5;

@interface NHRootScroll ()<UIScrollViewDelegate>

@property (nullable, nonatomic, strong) NSMutableArray *channels;
@property (nullable, nonatomic, strong) NSMutableArray *pages;

@property (nonatomic, assign) NSInteger maxShownCount, prePageIndex;

@property (nonatomic, strong, nullable) NHPager *prePage,*dstPage;

@end

@implementation NHRootScroll

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSetup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame withChannels:(NSArray *)channels {
    self = [super initWithFrame:frame];
    if (self) {
        _channels = [NSMutableArray arrayWithArray:channels];
        [self _initSetup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initSetup];
    }
    
    return self;
}

- (void)_initSetup {
    
    __weak typeof(self) weakSelf = self;
    self.delegate = weakSelf;
    
    self.maxShownCount = NHMinCacheCount;
    
    NSInteger cnnCounts = [self.channels count];
    NSAssert(cnnCounts > 0, @"main channel's counts must more than one !");
    
    ///create sub pages
    CGSize mainSize = [self bounds].size;
    CGRect bounds;
    bounds.size = mainSize;
    for (int i = 0; i < cnnCounts; i++) {
        CGPoint origin = CGPointMake(mainSize.width*i, 0);
        bounds.origin = origin;
        NSString *channel = [self.channels objectAtIndex:i];
        NHPager *pager = [[NHPager alloc] initWithFrame:bounds withChannel:channel];
        pager.backgroundColor = [UIColor pb_randomColor];
        [self addSubview:pager];
        [self.pages addObject:pager];
        if (i == 0) {
            [pager loadAndDisplay];
        }else {
            [pager lowMemoryState];
        }
    }
    [self setContentOffset:CGPointZero];
    CGSize contentSize = CGSizeMake(cnnCounts * mainSize.width, mainSize.height);
    [self setContentSize:contentSize];
    
    self.maxShownCount = MIN(NHMaxCacheCount, cnnCounts);
}

- (void)lowerMemoryCachePolicy {
    self.maxShownCount--;
    self.maxShownCount = MAX(NHMinCacheCount, self.maxShownCount);
}

- (NSMutableArray *)pages {
    if (!_pages) {
        _pages = [NSMutableArray arrayWithCapacity:0];
    }
    return _pages;
}

- (NSMutableArray *)channels {
    if (!_channels) {
        _channels = [NSMutableArray arrayWithCapacity:0];
    }
    return _channels;
}

#pragma mark -- ScrollView Delegate --

- (NSInteger)scrollViewInnerPage{
    float contentOffset_x = self.contentOffset.x;
    CGFloat width = CGRectGetWidth(self.bounds);
    NSInteger page = (contentOffset_x + (0.5f * width)) / width;
    return page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float contentOffset_x = scrollView.contentOffset.x;
    NSLog(@"offset:%f",contentOffset_x);
    NSInteger page = [self scrollViewInnerPage];
    int width = (int)CGRectGetWidth(scrollView.bounds);
    BOOL swipe2Right = contentOffset_x < page*width;
    BOOL swipe2Left  = contentOffset_x > page*width;
    
    NSInteger abs_offset = 2;
    if ((abs((int)(contentOffset_x)))%width == 0) {
        NSLog(@"滑倒了边界...");
    }
    
    if (page != _prePageIndex) {
        if (swipe2Right) {
            ///向右滑动 需要显示左边的view
            /// 小于等于0即滑到了最左边无需再滑动
            if (page > 0) {
                _prePage = [self pagerForIndex:_prePageIndex];
                _dstPage = [self pagerForIndex:page];
                [_dstPage viewWillAppear];
            }
            NSLog(@"向右滑动");
        }
        
        if (swipe2Left) {
            NSLog(@"向左滑动");
            NSInteger counts = [self.channels count];
            if (page < counts-1) {
                _prePage = [self pagerForIndex:_prePageIndex];
                _dstPage = [self pagerForIndex:page];
                [_dstPage viewWillAppear];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = [self scrollViewInnerPage];
    if (page != _prePageIndex) {
        [_prePage viewDidDisappear];
        [_dstPage viewDidAppear];
        
        _prePageIndex = page;
        [self updateHiddenOrDisplayPage];
    }else {
        [_dstPage viewDidDisappear];
        [_prePage viewDidAppear];
    }
}

- (NHPager *)pagerForIndex:(NSInteger)index {
    NSInteger counts = [self.pages count];
    if (index < 0 || index > (counts-1)) {
        return nil;
    }
    NHPager *pager = [self.pages objectAtIndex:index];
    return pager;
}

- (void)updateHiddenOrDisplayPage {
    NSLog(@"update hiden or display pages");
    /// 更新显示、隐藏的page
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"_showDate" ascending:false];
    NSArray *sortDescriptor = [NSArray arrayWithObjects:descriptor, nil];
    NSArray *tmpArray = [self.pages copy];
    tmpArray = [tmpArray sortedArrayUsingDescriptors:sortDescriptor];
    NSInteger counts = [tmpArray count];
    @synchronized(self.pages) {
        for (int i = 0; i < counts; i++) {
            NHPager *tmpPager = [tmpArray objectAtIndex:i];
            for (NHPager *page in self.pages) {
                if ([page.channel isEqualToString:tmpPager.channel]) {
                    if (i >= self.maxShownCount) {
                        [page lowMemoryState];
                    }
                }
            }
        }
    }
}
///上部导航控制跳转
- (void)showChannel:(NSString *)channel {
    NHPager *tmpPager = [self pagerForIndex:_prePageIndex];
    if (![channel isEqualToString:tmpPager.channel]) {
        _prePage = tmpPager;
        
        for (NHPager *tmp in self.pages) {
            if ([channel isEqualToString:tmp.channel]) {
                _dstPage = tmp;
                [_dstPage viewWillAppear];
                NSInteger index = [self.pages indexOfObject:tmp];
                CGPoint offset = CGPointMake(self.bounds.size.width * index, 0);
                [self setContentOffset:offset animated:true];
                break;
            }
        }
        
    }
//    NHPager *dstPager ;
}

- (void)removeChannel:(NSString *)channel {
    //TODO::滚动、控制位置
}

- (void)addChannel:(NSString *)channel  toIndex:(NSInteger)index {
    //TODO::滚动、控制位置
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

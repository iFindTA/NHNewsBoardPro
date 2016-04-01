//
//  NHPageScroller.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/25.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHPageScroller.h"
#import "NHPageCell.h"

@interface NHPageScroller ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@property (nullable, nonatomic, strong) NSMutableArray *sourceChannel;
@property (nullable, nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentIndex;

@end

static NSString *cellIdentifier = @"scrollCell";
static NSString *viewIdentifier = @"scrollview";

@implementation NHPageScroller

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
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
    
    CGSize mainSize = self.bounds.size;
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //设置headerView的尺寸大小
    layout.headerReferenceSize = CGSizeZero;
    //该方法也可以设置itemSize
    layout.itemSize =mainSize;
    
    //2.初始化collectionView
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.scrollsToTop = true;
    _collectionView.pagingEnabled = true;
    _collectionView.showsVerticalScrollIndicator = false;
    _collectionView.showsHorizontalScrollIndicator = false;
    [self addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor clearColor];
    
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [_collectionView registerClass:[NHPageCell class] forCellWithReuseIdentifier:cellIdentifier];
    
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:viewIdentifier];
    
    //4.设置代理
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
}

- (void)setDataSource:(id<NHPageScrollerDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)reloadData {
    NSAssert(_dataSource != nil, @"page scroller's dataSource can't be nil!");
    if (_sourceChannel) {
        [_sourceChannel removeAllObjects];
        _sourceChannel = nil;
    }
    NSArray *tmp = [_dataSource dataSourceForPageScroller:self];
    NSAssert(tmp.count > 0, @"dataSource's count must positive!");
    _sourceChannel = [NSMutableArray arrayWithArray:tmp];
    
    self.currentIndex = 0;
    [_collectionView reloadData];
    //主动调用
    //[self scrollViewDidEndDecelerating:_collectionView];
    NHNews *news = [self.sourceChannel firstObject];
    if (self.delegate && [self.delegate respondsToSelector:@selector(scroller:didSelectNews:)]) {
        [self.delegate scroller:self didSelectNews:news];
    }
}

- (void)selectedIndex:(NSInteger)index animated:(BOOL)animate {
    if (index == self.currentIndex) {
        return;
    }
    if (index >= self.sourceChannel.count) {
        return;
    }
    self.currentIndex = index;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:animate];
    weakify(self)
    PBMAINDelay(0.5, ^{
        strongify(self)
        [self channelDidAppeared];
    });
}

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sourceChannel.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NHPageCell *cell = (NHPageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    weakify(self)
    [cell handleNewsTouchEvent:^(NHNews * _Nonnull news) {
        strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(scroller:didSelectNews:)]) {
            [self.delegate scroller:self didSelectNews:news];
        }
    }];
    [cell handleADsTouchEvent:^(NSDictionary * _Nonnull ads) {
        strongify(self)
        if (_delegate && [self.delegate respondsToSelector:@selector(scroller:didSelectADs:)]) {
            [_delegate scroller:self didSelectADs:ads];
        }
    }];
    //NSString *tmpChannel = [self.sourceChannel objectAtIndex:indexPath.row];
    //cell.channel = [tmpChannel copy];
    //cell.botlabel.text = [NSString stringWithFormat:@"{%ld,%ld}",(long)indexPath.section,(long)indexPath.row];
    //NSLog(@"%s---will display chann:%@",__FUNCTION__,tmpChannel);
    //[cell willDisplayChannel:tmpChannel];
    //cell.backgroundColor = [UIColor pb_randomColor];
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size;
}

//footer的size
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    return CGSizeMake(10, 10);
//}

//header的size
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(10, 10);
//}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


//通过设置SupplementaryViewOfKind 来设置头部或者底部的view，其中 ReuseIdentifier 的值必须和 注册是填写的一致，本例都为 “reusableView”
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:viewIdentifier forIndexPath:indexPath];
    headerView.backgroundColor =[UIColor grayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
    label.text = @"这是collectionView的头部";
    label.font = [UIFont systemFontOfSize:20];
    [headerView addSubview:label];
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (cell) {
        NSString *tmpChannel = [self.sourceChannel objectAtIndex:indexPath.row];
        NHPageCell *pager = (NHPageCell *)cell;
        
        [pager willDisplayChannel:tmpChannel];
        //NSLog(@"%s---will display chann:%@",__FUNCTION__,tmpChannel);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (cell) {
        NSString *tmpChannel = [self.sourceChannel objectAtIndex:indexPath.row];
        NHPageCell *pager = (NHPageCell *)cell;
        [pager didEndDisplayChannel:tmpChannel];
        //NSLog(@"%s---did end display chann:%@",__FUNCTION__,tmpChannel);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
   
    NSInteger page = [self channelDidAppeared];
    
    if (_delegate && [_delegate respondsToSelector:@selector(scroller:didShowIndex:)]) {
        [_delegate scroller:self didShowIndex:page];
    }
}

- (NSUInteger)channelDidAppeared {
    float contentOffset_x = self.collectionView.contentOffset.x;
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    NSInteger page = (contentOffset_x + (0.5f * width)) / width;
    
    self.currentIndex = page;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:page inSection:0];
    NSString *tmpChannel = [self.sourceChannel objectAtIndex:page];
    //NHPageCell *pager = (NHPageCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NHPageCell *pager = (NHPageCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    [pager viewDidAppearForChannel:tmpChannel];
    //NSLog(@"%s-------did end decelerating :%@",__FUNCTION__,tmpChannel);
    return page;
}

- (void)refreshing {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
    NHPageCell *pager = (NHPageCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [pager forceRefreshing];
}

////点击item方法
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NHPageCell *cell = (NHPageCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    NSString *msg = cell.botlabel.text;
//    NSLog(@"%@",msg);
//}

@end

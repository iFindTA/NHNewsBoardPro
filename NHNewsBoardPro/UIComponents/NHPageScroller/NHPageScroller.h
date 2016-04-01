//
//  NHPageScroller.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/25.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHView.h"
#import "NHModels.h"

@protocol NHPageScrollerDelegate;
@protocol NHPageScrollerDataSource;
@interface NHPageScroller : NHView

@property (nonatomic, assign) id<NHPageScrollerDelegate> delegate;

@property (nonatomic, assign) id<NHPageScrollerDataSource> dataSource;

- (void)reloadData;

- (void)selectedIndex:(NSInteger)index animated:(BOOL)animate;

//test method
- (void)refreshing;

@end

@protocol NHPageScrollerDataSource <NSObject>
@required
- (NSArray *)dataSourceForPageScroller:(NHPageScroller *)scroller;

@end

@protocol NHPageScrollerDelegate <NSObject>
@optional
- (void)scroller:(NHPageScroller *)scroller didShowIndex:(NSInteger)index;
- (void)scroller:(NHPageScroller *)scroller didSelectNews:(NHNews * _Nonnull)info;
- (void)scroller:(NHPageScroller *)scroller didSelectADs:(NSDictionary * _Nonnull)ad;
@end
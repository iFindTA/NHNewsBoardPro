//
//  NHReView.h
//  NHReuseCellPro
//
//  Created by hu jiaju on 15/9/21.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NHReCell.h"

@protocol NHReViewDelegate;
@protocol NHReViewDataSource;

@interface NHReView : UIView

@property (nonatomic, assign) id<NHReViewDataSource> dataSource;
@property (nonatomic, assign) id<NHReViewDelegate> delegate;

- (NHReCell *)dequeueReusablePageWithIdentifier:(NSString *)identifier forPageIndex:(NSUInteger)index;
- (void)reloadData;

- (void)prefPage;

- (void)nextPage;

- (void)changeTitle:(NSString * _Nonnull)title;

@end

@protocol NHReViewDelegate <NSObject>
@optional
- (void)review:(NHReView *)view willDismissIndex:(NSUInteger)index;
- (void)review:(NHReView *)view didChangeToIndex:(NSUInteger)index;
- (void)review:(NHReView *)view didTouchIndex:(NSUInteger)index;

@end

@protocol NHReViewDataSource <NSObject>
@required
- (NSUInteger)reviewPageCount:(NHReView *)view;
- (NHReCell *)review:(NHReView *)view pageViewAtIndex:(NSUInteger)index;

@end

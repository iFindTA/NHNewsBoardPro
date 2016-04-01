//
//  NHPageCell.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/25.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NHModels.h"

typedef void(^NHNewsTouchEvent)(NHNews * _Nonnull news);

typedef void(^NHADsTouchEvent)(NSDictionary * _Nonnull ads);

@interface NHPageCell : UICollectionViewCell

@property (nonatomic, copy, readonly, nullable) NSString *channel;

/**
 *	@brief	view will appear
 */
- (void)willDisplayChannel:(nonnull NSString *)channel;

/**
 *  @brief 松手后显示的某页
 *
 *  @param channel 频道
 */
- (void)viewDidAppearForChannel:(NSString * _Nonnull)channel;

/**
 *	@brief	view will end display
 */
- (void)didEndDisplayChannel:(nonnull NSString *)channel;

- (void)forceRefreshing;

/**
 *  @brief touch block
 *
 *  @param event touch event
 */
- (void)handleNewsTouchEvent:(NHNewsTouchEvent _Nonnull)event;

- (void)handleADsTouchEvent:(NHADsTouchEvent _Nonnull)event;

@end

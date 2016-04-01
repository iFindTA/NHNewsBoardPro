//
//  NHPageReuser.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/24.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NHPage.h"

@protocol NHPageReuserDelegate;
@protocol NHPageReuserDataSource;
@interface NHPageReuser : UIView

@property (nonatomic, assign) id<NHPageReuserDataSource> dataSource;

@property (nonatomic, assign) id<NHPageReuserDelegate> delegate;

- (NHPage *)dequeueReusablePageWithIdentifier:(NSString *)identifier;

/**
 *	@brief	select index page
 *
 *	@param 	index 	the page's index
 */
- (void)setReuseSelectIndex:(NSInteger)index;

/**
 *  @brief change selected index and refresh this index
 *
 *  @param index the page's index
 */
- (void)selectReuseIndexAndRefresh:(NSInteger)index;

/**
 *	@brief	reload current view
 */
- (void)reloadData;

@end

@protocol NHPageReuserDataSource <NSObject>
@required
/**
 *  @brief <#Description#>
 *
 *  @param view <#view description#>
 *
 *  @return <#return value description#>
 */
- (NSUInteger)numberOfCountsInReuseView:(NHPageReuser *)view;

/**
 *  @brief <#Description#>
 *
 *  @param view  <#view description#>
 *  @param index <#index description#>
 *
 *  @return <#return value description#>
 */
- (NHPage *)review:(NHPageReuser *)view pageViewAtIndex:(NSUInteger)index;

@end

@protocol NHPageReuserDelegate <NSObject>
@optional
- (void)review:(NHPageReuser *)view willDismissIndex:(NSUInteger)index;
- (void)review:(NHPageReuser *)view didChangeToIndex:(NSUInteger)index;

@end
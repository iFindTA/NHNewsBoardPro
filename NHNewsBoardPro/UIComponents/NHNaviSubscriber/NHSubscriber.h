//
//  NHSubscriber.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/24.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NHNaviStyleBack = 1 << 0,
    NHNaviStyleUnderline = 1 << 1
}NHNaviStyle;

@protocol NHSubscriberDelegate;
@protocol NHSubscriberDataSource;
@interface NHSubscriber : UIView

@property (nonatomic, assign) id<NHSubscriberDelegate> delegate;
@property (nonatomic, assign) id<NHSubscriberDataSource> dataSource;

@property (nonatomic, strong, readonly, getter = getSourceData) NSArray *sourceData;

/**
 *	@brief	init method
 *
 *	@param 	frame 	instance's frame
 *	@param 	style 	the navi style
 *
 *	@return	the instance
 */
- (id)initWithFrame:(CGRect)frame forStyle:(NHNaviStyle)style;

/**
 *	@brief	select index
 *
 *	@param 	index 	the dest index
 */
- (void)setSubscriberSelectIndex:(NSInteger)index;

/**
 *	@brief	must call this function after init method and set the datasource
 */
- (void)reloadData;

@end

@protocol NHSubscriberDataSource <NSObject>

@required

- (NSArray *)sourceDataForSubscriber:(NHSubscriber *)scriber;

@end

@protocol NHSubscriberDelegate <NSObject>

- (void)subscriber:(NHSubscriber *)scriber didSelectIndex:(NSInteger)index;
- (void)didSelectArrowForSubscriber:(NHSubscriber *)scriber;

@end
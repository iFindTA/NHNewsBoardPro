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

@property (nonatomic, assign) _Nonnull id<NHSubscriberDelegate> delegate;
@property (nonatomic, assign) _Nonnull id<NHSubscriberDataSource> dataSource;

@property (nonatomic, readonly, copy) NSString * _Nonnull selectedCnn;

/**
 *	@brief	init method
 *
 *	@param 	frame 	instance's frame
 *	@param 	style 	the navi style
 *
 *	@return	the instance
 */
- (_Nonnull id)initWithFrame:(CGRect)frame forStyle:(NHNaviStyle)style;

/**
 *	@brief	select index
 *
 *	@param 	index 	the dest index
 */
//- (void)setSubscriberSelectIndex:(NSInteger)index;

/**
 *	@brief	must call this function after init method and set the datasource
 */
- (void)reloadData;

#pragma mark -- 栏目编辑事件

/**
 *  @brief 选中 栏目
 *
 *  @param cnn 栏目名称
 */
- (void)subscriberSelectCnn:(NSString * _Nonnull)cnn;

/**
 *  @brief 增、删栏目
 *
 *  @param add 是否是增加 否为删除
 *  @param idx 序号
 *  @param cnn 栏目名称
 */
- (void)scriberEdit:(BOOL)add idx:(NSUInteger)idx cnn:(NSString * _Nonnull)cnn;

/**
 *  @brief 排序栏目
 *
 *  @param originIdx 原始序号
 *  @param destIdx   目标序号
 *  @param cnn       栏目名称
 */
- (void)scriberSort:(NSUInteger)originIdx destIdx:(NSUInteger)destIdx cnn:(NSString * _Nonnull)cnn;

@end

@protocol NHSubscriberDataSource <NSObject>

@required

- (NSArray * _Nullable)sourceDataForSubscriber:(NHSubscriber * _Nonnull)scriber;

@end

@protocol NHSubscriberDelegate <NSObject>

- (void)subscriber:(NHSubscriber * _Nonnull)scriber didSelectCnn:(NSString * _Nonnull)cnn;
- (void)didSelectArrowForSubscriber:(NHSubscriber * _Nonnull)scriber;

@end
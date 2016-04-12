//
//  NHPreventCustomer.h
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/11.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHPreventPager.h"
#import "NHModels.h"

typedef void(^NHNewsClickEvent)(NHNews * _Nonnull news);

typedef void(^NHADsClickEvent)(NSDictionary * _Nonnull ads);

@interface NHPreventCustomer : NHPreventPager

//TODO:此字典是暂时存在 保存请求路径的 生产环境时应去除
@property (nonatomic, strong) NSDictionary * _Nonnull infos;

/**
 *  @brief <#Description#>
 *
 *  @param bounds <#bounds description#>
 *  @param cnn    <#cnn description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype _Nonnull)prevent:(CGRect)bounds withChannel:(NSString * _Nonnull)cnn;

/**
 *  @brief touch block
 *
 *  @param event touch event
 */
- (void)handleNewsTouchEvent:(NHNewsClickEvent _Nonnull)event;

/**
 *  @brief <#Description#>
 *
 *  @param event <#event description#>
 */
- (void)handleADsTouchEvent:(NHADsClickEvent _Nonnull)event;

@end

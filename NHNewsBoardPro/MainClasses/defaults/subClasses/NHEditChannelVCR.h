//
//  NHEditChannelVCR.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/29.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHViewController.h"

/**
 *  @brief 栏目切换block
 *
 *  @param index   切换到第几个
 *  @param cnn     切换到栏目名称
 */
typedef void(^NHSwitchChannel)(NSUInteger index, NSString * _Nonnull cnn);

/**
 *  @brief 栏目编辑
 *
 *  @param add 是否是添加动作 false是删除
 *  @param idx 操作的idx
 *  @param cnn 操作的名称
 */
typedef void(^NHEditChannel)(BOOL add, NSUInteger idx, NSString * _Nonnull cnn);

/**
 *  @brief 排序栏目
 *
 *  @param originIdx 起始idx
 *  @param destIdx   目标idx
 *  @param cnn       栏目名称
 */
typedef void(^NHSortChannel)(NSUInteger originIdx, NSUInteger destIdx, NSString * _Nonnull cnn);

@interface NHEditChannelVCR : NHViewController

@property (nonnull, nonatomic, copy) NSString *selectedCnn;
@property (nonnull, nonatomic, strong) NSArray *existSource;
@property (nullable, nonatomic, strong) NSArray *otherSource;

/**
 *  @brief 开始构建页面
 */
- (void)startBuildCnn;

/**
 *  @brief switch channel
 *
 *  @param event callback
 */
- (void)handleChannelEditorSwitchEvent:(NHSwitchChannel _Nonnull)event;

/**
 *  @brief edit channel
 *
 *  @param event callback
 */
- (void)handleChannelEditorEditEvent:(NHEditChannel _Nonnull)event;

/**
 *  @brief sort channel
 *
 *  @param event callback
 */
- (void)handleChannelEditorSortEvent:(NHSortChannel _Nonnull)event;

@end

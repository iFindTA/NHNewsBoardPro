//
//  NHEditCNNScroller.h
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/6.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief 是否处于拖动排序状态 block
 *
 *  @param dragable 是否可以处于拖动状态
 */
typedef void(^NHDragSortAble)(BOOL dragable);

/**
 栏目编辑动作分类
 */
typedef enum {
    NHCnnEditTypeNone      =  1 << 0,
    NHCnnEditTypeAdd       =  1 << 1,
    NHCnnEditTypeDelete    =  1 << 2,
    NHCnnEditTypeSelect    =  1 << 3
}NHCnnEditType;
/**
 *  @brief 编辑（增加、删除、选中）栏目 block
 *
 *  @param type  动作分类：添加、删除、选中
 *  @param index 编辑的位置
 *  @param cnn   编辑的栏目名称
 */
typedef void(^NHCnnEditEvent)(NHCnnEditType type, NSUInteger index, NSString * _Nonnull cnn);

/**
 *  @brief 排序 block
 *
 *  @param originIdx item原来的位置
 *  @param destIdx   item新位置
 *  @param cnn       item栏目名称
 */
typedef void(^NHCnnSortEvent)(NSUInteger originIdx, NSUInteger destIdx, NSString * _Nonnull cnn);

@interface NHEditCNNScroller : UIScrollView

/**
 *  @brief 已经订阅的栏目
 */
@property (nonatomic, nonnull, strong) NSArray *exists;

/**
 *  @brief 等待订阅的栏目
 */
@property (nonatomic, nullable, strong) NSArray *others;

/**
 *  @brief 默认进入时选择title
 *
 *  @param title 当前选中的标题
 */
- (void)resetSelectedCnnTitle:(NSString * _Nonnull)title;

/**
 *  @brief action:sort/delete/done
 */
- (void)subNaviEventForSort:(BOOL)sort;

/**
 *  @brief 长按触发编辑动作
 *
 *  @param event block
 */
- (void)handleLongPressTriggerEvent:(NHDragSortAble _Nonnull)event;

/**
 *  @brief 编辑栏目：增加、删除、选中动作
 *
 *  @param event block
 */
- (void)handleCnnEditEvent:(NHCnnEditEvent _Nonnull)event;

/**
 *  @brief 栏目排序动作
 *
 *  @param event block
 */
- (void)handleCnnSortEvent:(NHCnnSortEvent _Nonnull)event;

@end

//
//  NHEditCNNScroller.h
//  NHNewsBoardPro
//
//  Created by hu jiaju on 16/4/6.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NHEditCNNScroller : UIScrollView

@property (nonatomic, nonnull, strong) NSArray *exists;
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

@end
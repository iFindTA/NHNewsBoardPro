//
//  NHRootScroll.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/2/15.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NHRootScroll : UIScrollView

- (nullable id)initWithFrame:(CGRect)frame withChannels:(nonnull NSArray *)channels;

- (void)removeChannel:(nonnull NSString *)channel;
- (void)addChannel:(nonnull NSString *)channel toIndex:(NSInteger)index;
- (void)showChannel:(nonnull NSString *)channel;

- (void)lowerMemoryCachePolicy;

@end

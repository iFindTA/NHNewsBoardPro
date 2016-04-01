//
//  NHPager.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/2/15.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NHPager : UIView

@property (nonatomic, strong, nullable) NSDate *showDate;
@property (readonly, nonatomic, nullable) NSString *channel;

- (id _Nonnull)initWithFrame:(CGRect)frame withChannel:(nullable NSString *)channel;

- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewDidDisappear;

- (void)loadAndDisplay;
- (void)lowMemoryState;

@end

//
//  NHEditChannelVCR.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/29.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHViewController.h"

typedef void(^NHSwitchChannel)(NSUInteger index, NSString * _Nonnull channel);

@interface NHEditChannelVCR : NHViewController

@property (nonnull, nonatomic, strong) NSArray *existSource;
@property (nullable, nonatomic, strong) NSArray *otherSource;

/**
 *  @brief switch channel
 *
 *  @param event callback
 */
- (void)handleChannelEditorSwitchEvent:(NHSwitchChannel _Nonnull)event;

@end

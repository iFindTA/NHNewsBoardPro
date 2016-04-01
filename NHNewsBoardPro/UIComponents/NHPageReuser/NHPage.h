//
//  NHPage.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/11/24.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NHPage : UIView

- (id)initWithFrame:(CGRect)frame withIdentifier:(NSString *)identifier withChannel:(NSString *)channel;

- (void)viewWillApear NS_REQUIRES_SUPER;
- (void)viewWillDisappear NS_REQUIRES_SUPER;

@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, copy) NSString *channel;

@end

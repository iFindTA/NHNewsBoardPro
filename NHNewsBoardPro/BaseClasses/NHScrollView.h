//
//  NHScrollView.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/28.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NHScrollDelegate;
@interface NHScrollView : UIScrollView

@property (nonatomic, assign) id<NHScrollDelegate> touchDelegate;

@end

@protocol NHScrollDelegate <NSObject>
@optional
- (void)scrollTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)scrollTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)scrollTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end
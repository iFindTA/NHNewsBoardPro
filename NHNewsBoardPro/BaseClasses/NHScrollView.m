//
//  NHScrollView.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/28.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHScrollView.h"

@implementation NHScrollView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_touchDelegate && [_touchDelegate respondsToSelector:@selector(scrollTouchesBegan:withEvent:)]) {
        [_touchDelegate scrollTouchesBegan:touches withEvent:event];
    }
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_touchDelegate && [_touchDelegate respondsToSelector:@selector(scrollTouchesMoved:withEvent:)]) {
        [_touchDelegate scrollTouchesMoved:touches withEvent:event];
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_touchDelegate && [_touchDelegate respondsToSelector:@selector(scrollTouchesEnded:withEvent:)]) {
        [_touchDelegate scrollTouchesEnded:touches withEvent:event];
    }
    [super touchesEnded:touches withEvent:event];
}

@end

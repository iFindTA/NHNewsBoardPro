//
//  NHReCell.m
//  NHReuseCellPro
//
//  Created by hu jiaju on 15/9/21.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHReCell.h"

@interface NHReCell ()

@end

@implementation NHReCell

- (nonnull instancetype)initWithIdentifier:(nonnull NSString *)identifier {
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
    }
    return self;
}

//- (id)copyWithZone:(NSZone *)zone {
//    NHReCell *copy = [[[self class] allocWithZone:zone] init];
//    copy.identifier = [self.identifier copy];
//    return copy;
//}
//- (id)mutableCopyWithZone:(NSZone *)zone {
//    NHReCell *copy = [[[self class] allocWithZone:zone] init];
//    copy.identifier = [self.identifier copy];
//    return copy;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

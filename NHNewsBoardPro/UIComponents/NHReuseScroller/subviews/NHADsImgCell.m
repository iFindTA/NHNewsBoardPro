//
//  NHADsImgCell.m
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 16/3/28.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHADsImgCell.h"

@interface NHADsImgCell ()

@end

@implementation NHADsImgCell

- (nonnull instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.identifier = [identifier copy];
        _image = [[UIImageView alloc] initWithFrame:self.bounds];
        _image.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_image];
    }
    return self;
}

@end

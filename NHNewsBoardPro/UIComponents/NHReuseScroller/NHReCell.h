//
//  NHReCell.h
//  NHReuseCellPro
//
//  Created by hu jiaju on 15/9/21.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NHReCell : UIView//<NSCopying,NSMutableCopying>

- (nonnull instancetype)initWithIdentifier:(nonnull NSString *)identifier;

@property (nonatomic, copy, nonnull) NSString *identifier;

@end

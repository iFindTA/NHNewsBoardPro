//
//  NSArray+PBHelper.m
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NSArray+PBHelper.h"
#import "PBKits.h"

@implementation NSArray (PBHelper)

- (BOOL)pb_isEmpty {
    return (self == nil || self.count <= 0);
}

@end

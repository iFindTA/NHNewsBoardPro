//
//  NSDictionary+PBHelper.m
//  NHUtilSetsPro
//
//  Created by hu jiaju on 16/4/14.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NSDictionary+PBHelper.h"

@implementation NSDictionary (PBHelper)

- (BOOL)pb_isEmpty {
    return (self == nil || self.count <= 0);
}
//////////////// NSDictionary Safe Accessors //////////////
- (BOOL)isKindOfClass:(Class)aClass forKey:(NSString *)key{
    id value = [self objectForKey:key];
    return [value isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass forKey:(NSString *)key{
    id value = [self objectForKey:key];
    return [value isMemberOfClass:aClass];
}

- (BOOL)isArrayForKey:(NSString *)key {
    return [self isKindOfClass:[NSArray class] forKey:key];
}

- (BOOL)isDictionaryForKey:(NSString *)key {
    return [self isKindOfClass:[NSDictionary class] forKey:key];
}

- (BOOL)isStringForKey:(NSString *)key {
    return [self isKindOfClass:[NSString class] forKey:key];
}

- (BOOL)isNumberForKey:(NSString *)key {
    return [self isKindOfClass:[NSNumber class] forKey:key];
}

- (NSArray *)pb_arrayForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return nil;
}

- (NSDictionary *)pb_dictionaryForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return nil;
}

- (NSString *)pb_stringForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value respondsToSelector:@selector(description)]) {
        return [value description];
    }
    return nil;
}

- (NSNumber *)pb_numberForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        return [nf numberFromString:value];
    }
    return nil;
}

- (double)pb_doubleForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value doubleValue];
    }
    return 0;
}

- (float)pb_floatForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value floatValue];
    }
    return 0;
}

- (int)pb_intForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value intValue];
    }
    return 0;
}

- (unsigned int)pb_unsignedIntForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        value = [nf numberFromString:value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedIntValue];
    }
    return 0;
}

- (NSInteger)pb_integerForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value integerValue];
    }
    return 0;
}

- (NSUInteger)pb_unsignedIntegerForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        value = [nf numberFromString:value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedIntegerValue];
    }
    return 0;
}

- (long long)pb_longLongForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value longLongValue];
    }
    return 0;
}

- (unsigned long long)pb_unsignedLongLongForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        value = [nf numberFromString:value];
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value unsignedLongLongValue];
    }
    return 0;
}

- (BOOL)pb_boolForKey:(NSString *)key {
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
    return NO;
}

@end

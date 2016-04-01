//
//  NHDBEngine.h
//  NHFMDBPro
//
//  Created by hu jiaju on 16/2/17.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NHNews;
@interface NHDBEngine : NSObject

+ (nonnull NHDBEngine *)share;

+ (nonnull NSString *)dbPath;

#pragma mark -- 增删改查 示例 --

- (BOOL)saveInfo:(nullable id)info;

- (BOOL)deleteInfo:(nullable id)info;

- (BOOL)updateInfo:(nullable id)info;

- (nullable id)getInfo;
- (NSArray * _Nullable)getInfos;

#pragma mark -- 操作news --
//真对新闻各个频道只保存第一页数据
- (BOOL)clearNewsForChannel:(NSString * _Nonnull)channel;
- (BOOL)saveNews:(nonnull NSArray *)news forChannel:(nonnull NSString *)channel;
- (NSArray * _Nullable)getNewsCachesForChannel:(NSString * _Nonnull)channel;
- (BOOL)readNews:(NHNews * _Nonnull)news;
//是否阅读过此文章
- (BOOL)alreadyReadDoc:(NSString * _Nonnull)docid;

@end

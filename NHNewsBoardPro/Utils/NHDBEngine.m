//
//  NHDBEngine.m
//  NHFMDBPro
//
//  Created by hu jiaju on 16/2/17.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

/*
 *线程安全使用示例
 */

#import "NHDBEngine.h"
#import <FMDB/FMDB.h>
#import "NHSetsEngine.h"
#import "NHModels.h"

static NSString *NHDBCipherKey = @"nanhujiaju";
static NSString *NHDBNAME = @"securityInfo.DB";
static NSString *NHSQLS   = @"NH_SQLS";

@interface NHDBEngine ()

@property (nonatomic, strong, nullable)FMDatabaseQueue *dbQueue;

@end

static NHDBEngine *instance = nil;

@implementation NHDBEngine

+ (NHDBEngine *)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self createFMDB];
    }
    return self;
}

+ (NSString *)dbPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *filePath = [[paths firstObject] stringByAppendingPathComponent:NHDBNAME];
    return filePath;
}

- (NSString *)filePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *filePath = [[paths firstObject] stringByAppendingPathComponent:fileName];
    return filePath;
}

- (FMDatabaseQueue *)dbQueue {
    if (!_dbQueue) {
        NSString *dbpath = [self filePath:NHDBNAME];
        ///创建数据库及线程队列
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbpath];
    }
    return _dbQueue;
}

- (BOOL)createFMDB {
    
    __block BOOL ret = false;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db setKey:NHDBCipherKey];
        NSString *sqlFile = [[NSBundle mainBundle] pathForResource:NHSQLS ofType:@"txt"];
        if (!sqlFile) {
            return ;
        }
        NSString *sqls = [NSString stringWithContentsOfFile:sqlFile encoding:NSUTF8StringEncoding error:nil];
        NSArray *sqlArr = [sqls componentsSeparatedByString:@"|"];
        for (NSString *sql in sqlArr) {
            [db executeUpdate:sql];
        }
        
        ret = true;
    }];
    
    return ret;
}

- (NSDateFormatter *)dateFormatter {
    return [[NHSetsEngine share] dateFormatter];
}

#pragma mark -- Commen Method --

- (BOOL)saveInfo:(id)info {
    __block BOOL ret = false;
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *querySql = @"INSERT OR REPLACE INTO t_info_table (infoid, info, time) VALUES(?, ?, ?)";
        NSNumber *infoid = [info objectForKey:@"infoid"];
        NSString *info_ = [info objectForKey:@"info"];
        NSDate *time = [info objectForKey:@"time"];
        NSMutableArray *params = [NSMutableArray array];
        [params addObject:infoid];
        [params addObject:info_];
        [params addObject:time];
        ///执行SQL语句
        [db setKey:NHDBCipherKey];
        ret = [db executeUpdate:querySql withArgumentsInArray:params];
        NSLog(@"ret:%zd---插入数据",ret);
    }];
    
    return ret;
}

- (BOOL)deleteInfo:(id)info {
    
    __block BOOL ret = false;
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSNumber *infoid = [info objectForKey:@"infoid"];
        ///执行SQL语句
        [db setKey:NHDBCipherKey];
        ret = [db executeUpdate:@"DELETE FROM t_info_table WHERE infoid = ?",infoid,nil];
        NSLog(@"ret:%zd---删除数据",ret);
    }];
    
    return ret;
}

- (BOOL)updateInfo:(id)info {
    
    __block BOOL ret = false;
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSNumber *infoid = [info objectForKey:@"infoid"];
        NSString *info_ = [info objectForKey:@"info"];
        NSDate *time = [info objectForKey:@"time"];
        ///执行SQL语句
        [db setKey:NHDBCipherKey];
        ret = [db executeUpdate:@"UPDATE t_info_table SET info = ? AND time = ? WHERE infoid = ? ", info_, time, infoid, nil];
        NSLog(@"ret:%zd---更新数据",ret);
    }];
    
    return ret;
}

- (id)getInfo{
    
    __block NSMutableDictionary *tmpInfo = nil;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///处理事情
        [db setKey:NHDBCipherKey];
        FMResultSet *retSets = [db executeQuery:@"SELECT * FROM t_info_table LIMIT 1",nil];
        while ([retSets next]) {
            NSString *infoid = [retSets stringForColumn:@"infoid"];
            NSString *info = [retSets stringForColumn:@"info"];
            NSString *time = [retSets stringForColumn:@"time"];
            NSDictionary *tmp = [NSDictionary dictionaryWithObjectsAndKeys:infoid,@"infoid",info,@"info",time,@"time", nil];
            tmpInfo = [NSMutableDictionary dictionaryWithDictionary:tmp];
        }
    }];
    
    return tmpInfo;
}
- (NSArray *)getInfos{
    
    __block NSMutableArray *tmpArray = [NSMutableArray array];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///处理事情
        [db setKey:NHDBCipherKey];
        FMResultSet *retSets = [db executeQuery:@"SELECT * FROM t_info_table",nil];
        while ([retSets next]) {
            NSString *infoid = [retSets stringForColumn:@"infoid"];
            NSString *info = [retSets stringForColumn:@"info"];
            NSString *time = [retSets stringForColumn:@"time"];
            NSDictionary *tmp = [NSDictionary dictionaryWithObjectsAndKeys:infoid,@"infoid",info,@"info",time,@"time", nil];
            [tmpArray addObject:tmp];
        }
    }];
    
    return [tmpArray copy];
}

#pragma mark -- News 操作 --

- (BOOL)clearNewsForChannel:(nonnull NSString *)channel {
    __block BOOL ret = false;
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///解锁数据库
        [db setKey:NHDBCipherKey];
        ret = [db executeUpdate:@"DELETE FROM t_news_titles WHERE navitype = ?",channel,nil];
        NSLog(@"ret:%zd---删除数据",ret);
    }];
    
    return ret;
}

- (BOOL)saveNews:(nonnull NSArray *)news forChannel:(nonnull NSString *)channel {
    
    __block BOOL ret = false;
    
    if ([news pb_isEmpty]) {
        return ret;
    }
    NSDateFormatter *formatter = [self dateFormatter];
    NSDate *now = [NSDate date];
    __block NSMutableArray *tmp = [NSMutableArray array];
    [news enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *boardid = [obj pb_stringForKey:@"boardid"];boardid = PBAvailableString(boardid);
        NSString *digest = [obj pb_stringForKey:@"digest"];digest = PBAvailableString(digest);
        NSString *docid = [obj pb_stringForKey:@"docid"];docid = PBAvailableString(docid);
        NSNumber *imgType = [obj pb_numberForKey:@"imgType"];imgType = PBAvailableNumber(imgType);
        NSString *imgsrc = [obj pb_stringForKey:@"imgsrc"];imgsrc = PBAvailableString(imgsrc);
        NSString *lmodify = [obj pb_stringForKey:@"lmodify"];lmodify = PBAvailableString(lmodify);
        NSString *ltitle = [obj pb_stringForKey:@"ltitle"];ltitle = PBAvailableString(ltitle);
        NSString *postid = [obj pb_stringForKey:@"postid"];postid = PBAvailableString(postid);
        NSNumber *priority = [obj pb_numberForKey:@"priority"];priority = PBAvailableNumber(priority);
        NSString *ptime = [obj pb_stringForKey:@"ptime"];ptime = PBAvailableString(ptime);
        NSNumber *replyCount = [obj pb_numberForKey:@"replyCount"];replyCount = PBAvailableNumber(replyCount);
        NSString *skipID = [obj pb_stringForKey:@"skipID"];skipID = PBAvailableString(skipID);
        NSString *skipType = [obj pb_stringForKey:@"skipType"];skipType = PBAvailableString(skipType);
        NSString *source = [obj pb_stringForKey:@"source"];source = PBAvailableString(source);
        NSString *specialID = [obj pb_stringForKey:@"specialID"];specialID = PBAvailableString(specialID);
        NSString *subtitle = [obj pb_stringForKey:@"subtitle"];subtitle = PBAvailableString(subtitle);
        NSString *title = [obj pb_stringForKey:@"title"];title = PBAvailableString(title);
        NSString *url = [obj pb_stringForKey:@"url"];url = PBAvailableString(url);
        NSNumber *votecount = [obj pb_numberForKey:@"votecount"];votecount = PBAvailableNumber(votecount);
        BOOL hasAD = [obj pb_boolForKey:@"hasAD"];NSString *ads_str = @"";
        if (hasAD) {
            NSArray *ads = [obj pb_arrayForKey:@"ads"];
            BOOL empty = PBIsEmpty(ads);
            if (!empty) {
                NSData *ads_data = [NSJSONSerialization dataWithJSONObject:ads options:NSJSONWritingPrettyPrinted error:nil];
                ads_str = [[NSString alloc] initWithData:ads_data encoding:NSUTF8StringEncoding];
            }
        }
        NSArray *imgextra = [obj pb_arrayForKey:@"imgextra"];NSString *imgextra_str = @"";
        BOOL empty = PBIsEmpty(imgextra);
        if (!empty) {
            NSData *imgextra_data = [NSJSONSerialization dataWithJSONObject:imgextra options:NSJSONWritingPrettyPrinted error:nil];
            imgextra_str = [[NSString alloc] initWithData:imgextra_data encoding:NSUTF8StringEncoding];
        }
        NSString *savetime = [formatter stringFromDate:[now dateByAddingTimeInterval:idx]];
        //NSLog(@"save time :%@",savetime);
        NSArray *tmp_item = [NSArray arrayWithObjects:boardid,digest,docid,imgType.stringValue,imgsrc,lmodify,ltitle,postid,priority.stringValue,ptime,replyCount.stringValue,skipID,skipType,source,specialID,subtitle,title,url,votecount.stringValue,ads_str,hasAD?@"1":@"0",imgextra_str,savetime,channel, nil];
        //NSLog(@"save info count:%zd",tmp_item.count);
        [tmp addObject:tmp_item];
    }];
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *querySql = @"INSERT OR REPLACE INTO t_news_titles (boardid, digest, docid, imgType, imgsrc, lmodify, ltitle, postid, priority, ptime, replyCount, skipID, skipType, source, specialID, subtitle, title, url, votecount, ads, hasAD, imgextra, savetime, navitype) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        ///解锁数据库
        [db setKey:NHDBCipherKey];
        [tmp enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ret &= [db executeUpdate:querySql withArgumentsInArray:obj];
        }];
    }];
    
    return ret;
}

- (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    return formatter;
}

- (NSArray * _Nullable)getNewsCachesForChannel:(NSString * _Nonnull)channel {
    __block NSMutableArray *tmpArray = [NSMutableArray array];
    weakify(self)
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        strongify(self)
        ///处理事情
        [db setKey:NHDBCipherKey];
        FMResultSet *retSets = [db executeQuery:@"SELECT * FROM t_news_titles WHERE navitype = ? ORDER BY datetime(savetime) ASC LIMIT 22",channel,nil];
        NSNumberFormatter *formatter = [self numberFormatter];
        while ([retSets next]) {
            NSString *boardid = [retSets stringForColumn:@"boardid"];
            NSString *digest = [retSets stringForColumn:@"digest"];
            NSString *docid = [retSets stringForColumn:@"docid"];
            NSNumber *imgType = [formatter numberFromString:[retSets stringForColumn:@"imgType"]];
            NSString *imgsrc = [retSets stringForColumn:@"imgsrc"];
            NSString *lmodify = [retSets stringForColumn:@"lmodify"];
            NSString *ltitle = [retSets stringForColumn:@"ltitle"];
            NSString *postid = [retSets stringForColumn:@"postid"];
            NSNumber *priority = [formatter numberFromString:[retSets stringForColumn:@"priority"]];
            NSString *ptime = [retSets stringForColumn:@"ptime"];
            NSNumber *replyCount = [formatter numberFromString:[retSets stringForColumn:@"replyCount"]];
            NSString *skipID = [retSets stringForColumn:@"skipID"];
            NSString *skipType = [retSets stringForColumn:@"skipType"];
            NSString *source = [retSets stringForColumn:@"source"];
            NSString *specialID = [retSets stringForColumn:@"specialID"];
            NSString *subtitle = [retSets stringForColumn:@"subtitle"];
            NSString *title = [retSets stringForColumn:@"title"];
            NSString *url = [retSets stringForColumn:@"url"];
            NSNumber *votecount = [formatter numberFromString:[retSets stringForColumn:@"votecount"]];;
            BOOL hasAD = [retSets boolForColumn:@"hasAD"];NSArray *ads = [NSArray array];
            if (hasAD) {
                NSString *ads_str = [retSets stringForColumn:@"ads"];
                BOOL empty = PBIsEmpty(ads_str);
                if (!empty) {
                    ads = [NSJSONSerialization JSONObjectWithData:[ads_str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                }
            }
            NSString *imgextra_str = [retSets stringForColumn:@"imgextra"];NSArray *imgextra = [NSArray array];
            BOOL empty = PBIsEmpty(imgextra_str);
            if (!empty) {
                imgextra = [NSJSONSerialization JSONObjectWithData:[imgextra_str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            }
            NHNews *tmp = [[NHNews alloc] init];
            tmp.boardid = boardid;
            tmp.digest = digest;
            tmp.docid = docid;
            tmp.digest = digest;
            tmp.imgType = imgType;
            tmp.imgsrc = imgsrc;
            tmp.lmodify = lmodify;
            tmp.ltitle = ltitle;
            tmp.postid = postid;
            tmp.priority = priority;
            tmp.ptime = ptime;
            tmp.replyCount = replyCount;
            tmp.skipID = skipID;
            tmp.skipType = skipType;
            tmp.source = source;
            tmp.specialID = specialID;
            tmp.subtitle = subtitle;
            tmp.title = title;
            tmp.url = url;
            tmp.votecount = votecount;
            tmp.ads = ads;
            tmp.hasAD = hasAD;
            tmp.imgextra = imgextra;
            [tmpArray addObject:tmp];
        }
    }];
    
    return [tmpArray copy];
}

#pragma mark -- 阅读历史

- (BOOL)readNews:(NHNews * _Nonnull)news {
    __block BOOL ret = false;
    
    NSDateFormatter *formatter = [self dateFormatter];
    NSDate *now = [NSDate date];
    NSString *boardid = PBAvailableString(news.boardid);
    NSString *digest = PBAvailableString(news.digest);
    NSString *docid = PBAvailableString(news.docid);
    NSString *ltitle = PBAvailableString(news.ltitle);
    NSString *subtitle = PBAvailableString(news.subtitle);
    NSString *title = PBAvailableString(news.title);
    NSString *rtime = [formatter stringFromDate:now];
    //NSLog(@"save time :%@",savetime);
    NSArray *tmp = [NSArray arrayWithObjects:boardid,digest,docid,ltitle,subtitle,title,rtime, nil];
    //NSLog(@"save info count:%zd",tmp_item.count);
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *querySql = @"INSERT OR REPLACE INTO t_news_read (boardid, digest, docid, ltitle, subtitle, title, rtime) VALUES(?, ?, ?, ?, ?, ?, ?)";
        ///解锁数据库
        [db setKey:NHDBCipherKey];
        ret = [db executeUpdate:querySql withArgumentsInArray:tmp];
        //NSLog(@"read :%d",ret);
    }];
    
    return ret;
}

- (BOOL)alreadyReadDoc:(NSString * _Nonnull)docid {
    __block BOOL ret = false;
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///执行SQL语句
        [db setKey:NHDBCipherKey];
        FMResultSet *sets = [db executeQueryWithFormat:@"SELECT count(docid) AS counts FROM t_news_read WHERE docid = %@",docid];
        if ([sets next]) {
            int counts = [sets intForColumn:@"counts"];
            ret = counts > 0;
        };
        //NSLog(@"ret:%zd---是否阅读？",ret);
    }];
    
    return ret;
}

@end

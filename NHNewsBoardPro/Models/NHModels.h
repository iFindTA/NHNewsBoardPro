//
//  NHModels.h
//  NHNaviSwipeBackPro
//
//  Created by hu jiaju on 15/12/20.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jastor.h"

@interface NHModels : NSObject

@end

/**
 *  @brief 用户model
 */
@interface NHUser : Jastor

@property (nonatomic, strong) NSNumber *userid;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *nick;

@property (nonatomic, copy) NSString *phone;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, strong) NSArray *links;
@property (nonatomic, strong) NSDictionary *address;

@end

/**
 *  @brief news model
 */
@interface NHNews : Jastor
@property (nonatomic, copy) NSString *boardid;
@property (nonatomic, copy) NSString *digest;
@property (nonatomic, copy) NSString *docid;
@property (nonatomic, strong) NSNumber *imgType;
@property (nonatomic, copy) NSString *imgsrc;
@property (nonatomic, copy) NSString *lmodify;
@property (nonatomic, copy) NSString *ltitle;
@property (nonatomic, copy) NSString *postid;
@property (nonatomic, strong) NSNumber *priority;
@property (nonatomic, copy) NSString *ptime;
@property (nonatomic, copy) NSNumber *replyCount;
@property (nonatomic, copy) NSString *skipID;
@property (nonatomic, copy) NSString *skipType;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *specialID;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSNumber *votecount;
@property (nonatomic, strong) NSArray *ads;
@property (nonatomic, assign) BOOL hasAD;
@property (nonatomic, strong) NSArray *imgextra;
@property (nonatomic, copy) NSString *savetime;
@property (nonatomic, copy) NSString *navitype;

@end
//
//  ParamDao.h
//  Yoosee
//
//  Created by wutong on 15-2-2.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

#define DB_NAME @"Yoosee.sqlite"

@interface ParamDao : NSObject
@property (nonatomic) sqlite3 *db;
-(int) getGuardValue;
-(void)setGuardValue:(int)value bInsert:(BOOL)bInsert;
@end

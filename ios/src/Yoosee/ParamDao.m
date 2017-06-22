//
//  ParamDao.m
//  Yoosee
//
//  Created by wutong on 15-2-2.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "ParamDao.h"
#import "sqlite3.h"
#import "UDManager.h"
#import "LoginResult.h"

@implementation ParamDao
-(id)init{
    if([super init]){
        if([self openDB]){
            char *errMsg;
            
            if(sqlite3_exec(self.db, [[self getCreateTableString] UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK){
                NSLog(@"Table Alarm failed to create.");
                sqlite3_free(errMsg);
            }
            [self closeDB];
        }
    }
    return self;
}

-(NSString *)getCreateTableString{
    return @"create table if not exists config(param text not null primary key, activeuser text not null, value text not null)";
}


-(NSString*)dbPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:DB_NAME];
    return path;
}

-(BOOL)openDB{
    BOOL result = NO;
    if(sqlite3_open([[self dbPath] UTF8String], &_db)==SQLITE_OK){
        result = YES;
    }else{
        result = NO;
        NSLog(@"Failed to open database");
    }
    
    return result;
};

-(BOOL)closeDB{
    if(sqlite3_close(self.db)==SQLITE_OK){
        return YES;
    }else{
        return NO;
    }
}

-(int) getGuardValue
{
    int guard = -1;
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    sqlite3_stmt *statement;
    if([self openDB])
    {
        NSString *SQL = [NSString stringWithFormat:@"SELECT value FROM config WHERE activeuser = \"%@\" AND param=\"%@\"",loginResult.contactId, @"QRGurd"];
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            while(sqlite3_step(statement)==SQLITE_ROW)
            {
                guard = sqlite3_column_int(statement, 0);
                break;
            }
        }
        else
        {
            NSLog(@"Failed to find Message:%s",sqlite3_errmsg(self.db));
        }
        
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    if (guard == -1) {
        [self setGuardValue:1 bInsert:YES];
        guard = 1;
    }
    return guard;
}
/*
 config - param, activeuser, value
 QRGurd
 */

- (void)setGuardValue:(int)value bInsert:(BOOL)bInsert
{
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *sValue = [NSString stringWithFormat:@"%d",value];
        NSString *SQL = nil;
        if (!bInsert) {
            SQL = [NSString stringWithFormat:@"UPDATE config SET value = \"%@\" WHERE activeuser = \"%@\" AND param = \"%@\"", sValue, loginResult.contactId, @"QRGurd"];
        }
        else
        {
            SQL = [NSString stringWithFormat:@"INSERT INTO config(param,activeuser,value) VALUES(\"%@\",\"%@\",\"%@\")",@"QRGurd", loginResult.contactId, sValue];
        }
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
}

@end

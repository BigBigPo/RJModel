//
//  RJFMDBHelper.m
//  RJModelHelper
//
//  Created by Po on 2017/8/31.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "RJFMDBHelper.h"
#import "FMDB.h"
#define RJDataHelperName @"RJDataHelperClass"
#define FMDB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0]
static NSString * RJDataFileName = @"RJDataFile.db";

static RJFMDBHelper * rjFMDBHelper = nil;

@interface RJFMDBHelper()
@property (weak, nonatomic) FMDatabase * db;
@property (strong, nonatomic) FMDatabaseQueue * queue;

@end

@implementation RJFMDBHelper

+ (instancetype)shareHelper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rjFMDBHelper = [[RJFMDBHelper alloc] init];
    });
    return rjFMDBHelper;
}

- (instancetype)init {
    if ((self = [super init])) {
        NSString * path = [FMDB_PATH stringByAppendingPathComponent:RJDataFileName];
        NSLog(@"%@", FMDB_PATH);
//        _db = [FMDatabase databaseWithPath:path];
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return self;
}

- (void)runFMDBWithTransaction:(void(^)(id<RJDataHelperDelegate> helper))block {
    if (block) {
        __weak RJFMDBHelper * wself = self;
        [_queue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
            self.db = db;
            block(wself);
        }];
    }
}

- (void)runFMDBWithoutTransaction:(void(^)(id<RJDataHelperDelegate> helper))block {
    if (block) {
        __weak RJFMDBHelper * wself = self;
        [_queue inDatabase:^(FMDatabase *db) {
            //执行事务
            self.db = db;
            block(wself);
        }];
    }
}


- (BOOL)useSQLString:(NSString *)sqlString userData:(id)userData userType:(NSInteger)type  error:(NSError **)error {
    //此处的userData 表示属性表
    if (type) {
        return [self p_executeQueryWithSQLString:sqlString db:_db propertys:userData error:error];
    } else {
        return [self p_executeUpdateWithSqlString:sqlString db:_db error:error];
    }
}

- (BOOL)createTableWithName:(NSString *)tableName
                propertyKey:(NSArray *)propertys
                      error:(NSError **)error {
    NSString * propertyString = [propertys componentsJoinedByString:@"' ,'"];
    
    NSString * sqlString = [NSString stringWithFormat:@"CREATE TABLE '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'%@') ", tableName, propertyString];
    
    return [self p_executeUpdateWithSqlString:sqlString db:_db error:error];
}

- (BOOL)clearTableWithName:(NSString *)tableName error:(NSError **)error {
    NSString *sqlstring = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![self p_executeUpdateWithSqlString:sqlstring db:_db error:error])
    {
        NSLog(@"Clear %@ failed !", tableName);
        return NO;
    }
    
    return YES;
}

- (BOOL)dropTableWithName:(NSString *)tableName error:(NSError **)error {
    NSString * sqlString = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if(![self p_executeUpdateWithSqlString:sqlString db:_db error:error]) {
        NSLog(@"Delete %@ failed !", tableName);
        return NO;
    }
    
    sqlString = [NSString stringWithFormat:@"UPDATE sqlite_sequence set seq=0 where name='%@'", tableName];
    //清楚自增量
    [self p_executeUpdateWithSqlString:sqlString db:_db error:error];
    return YES;
}

- (BOOL)insertDataWithTableName:(NSString *)tableName propertys:(NSArray *)propertys values:(NSArray *)values error:(NSError **)error {
    
    NSString * propertyString = [propertys componentsJoinedByString:@", "];
    NSString * valueString = [values componentsJoinedByString:@", "];
    
    NSString * sqlString = [NSString stringWithFormat:@"insert into %@ (%@) values(%@);", tableName, propertyString, valueString];
    
    return [self p_executeUpdateWithSqlString:sqlString db:_db error:error];
}

- (NSArray *)searchDataWithTableName:(NSString *)tableName whereString:(NSString *)whereString propertys:(NSArray *)propertys error:(NSError **)error {
    return [self searchDataWithTableName:tableName whereString:whereString propertys:propertys order:nil error:error];
}

- (NSArray *)searchDataWithTableName:(NSString *)tableName whereString:(NSString *)whereString propertys:(NSArray *)propertys order:(NSString *)order error:(NSError **)error {
    
    NSString * sqlString = [NSString stringWithFormat:@"select * from %@", tableName];
    if (whereString && ![whereString isEqualToString:@""]) {
        sqlString = [sqlString stringByAppendingFormat:@" where %@", whereString];
    }
    
    if (order && ![order isEqualToString:@""]) {
        sqlString = [sqlString stringByAppendingFormat:@" ORDER BY %@", order];
    }
    
    return [self p_executeQueryWithSQLString:sqlString db:_db propertys:propertys error:error];
}


- (BOOL)updateDataWithTableName:(NSString *)tableName
                      propertys:(NSArray *)propertys
                         values:(NSArray *)values
                          where:(NSString *)whereString
                          error:(NSError **)error {
    NSMutableArray * temp = [NSMutableArray array];
    for (NSInteger i = 0; i < propertys.count; i ++) {
        NSString * property = propertys[i];
        if ([property isEqualToString:@"idNum"]) {
            continue;
        }
        [temp addObject:[NSString stringWithFormat:@"%@='%@'",property, values[i]]];
    }
    
    NSString * dataString = [temp componentsJoinedByString:@","];
    NSString * sqlString = [NSString stringWithFormat:@"update %@ set %@", tableName, dataString];
    if (whereString && ![whereString isEqualToString:@""]) {
        sqlString = [sqlString stringByAppendingFormat:@" where %@", whereString];
    }
    return [self p_executeUpdateWithSqlString:sqlString db:_db error:error];
}

- (BOOL)checkHadTable:(NSString *)tableName
               result:(NSError **)error {
    BOOL result;
    NSString *tableString = [tableName lowercaseString];
    FMResultSet *rs = [_db executeQuery:@"select [sql] from sqlite_master where [type] = 'table' and lower(name) = ?", tableString];
    result = [rs next];
    [rs close];
    
    if (!result && error) {
        *error = [NSError errorWithDomain:RJDataHelperName
                                     code:200
                                 userInfo:@{NSLocalizedDescriptionKey:@"The table is already create"}];
    }
    return result;
}

- (BOOL)deleteDataWithTableName:(NSString *)tableName where:(NSString *)whereString error:(NSError **)error {
    
    NSString * sqlString = [NSString stringWithFormat:@"delete from %@ where %@", tableName, whereString];
    return [self p_executeUpdateWithSqlString:sqlString db:_db error:error];
}

#pragma mark - private functions
- (BOOL)p_executeUpdateWithSqlString:(NSString *)sqlString db:(FMDatabase *)db error:(NSError **)error {
    BOOL result = [db executeUpdate:sqlString];
    if (!result) {
        NSLog(@"%@",[db lastErrorMessage]);
        if (error) {
            *error = [NSError errorWithDomain:RJDataHelperName
                                         code:[db lastErrorCode]
                                     userInfo:@{NSLocalizedDescriptionKey:[db lastErrorMessage]}];
        }
    }
    return result;
}

- (NSArray *)p_executeQueryWithSQLString:(NSString *)sqlString db:(FMDatabase *)db propertys:(NSArray *)propertys error:(NSError **)error {
    NSMutableArray * datas = [NSMutableArray array];
    FMResultSet *rs = [_db executeQuery:sqlString];
    while([rs next]) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        NSInteger idNum = [rs intForColumn:@"id"];
        [dic setObject:@(idNum) forKey:@"idNum"];
        for (NSString * property in propertys) {
            NSString * value = [rs stringForColumn:property];
            if (!value) {
                value = @"";
            }
            [dic setObject:value forKey:property];
        }
        [datas addObject:dic];
    }
    [rs close];
    return datas;
}

- (void)closeDBandShowError {
    NSLog(@"%@",_db.lastErrorMessage);
    [_db close];
}

- (NSInteger)lastInsertRowID {
    return _db.lastInsertRowId;
}
@end

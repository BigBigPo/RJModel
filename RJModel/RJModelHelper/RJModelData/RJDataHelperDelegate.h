//
//  RJDataHelperDelegate.h
//  RJModelHelper
//
//  Created by Po on 2017/8/31.
//  Copyright © 2017年 Po. All rights reserved.
//

#ifndef RJDataHelperDelegate_h
#define RJDataHelperDelegate_h

#import <Foundation/Foundation.h>
@protocol RJDataHelperDelegate


/**
 执行自定义SQL语句

 @param sqlString SQL语句
 @param userData 用户自定义数据(最好在实现时注释下语言)
 @param type 用户自定义类型
 @param error 错误
 */
- (BOOL)useSQLString:(NSString *)sqlString userData:(id)userData userType:(NSInteger)type error:(NSError **)error;

/**
 建表
 @param tableName 表名
 @param propertys 属性列表
 @param error 错误信息
 */
- (BOOL)createTableWithName:(NSString *)tableName propertyKey:(NSArray *)propertys error:(NSError **)error;
- (BOOL)updateTableName:(NSString *)tableName propertys:(NSArray *)propertys;

/**
 清空表
 @param tableName 表名
 */
- (BOOL)clearTableWithName:(NSString *)tableName error:(NSError **)error ;

/**
 删除表
 @param tableName 表名
 @param error 错误信息
 */
- (BOOL)dropTableWithName:(NSString *)tableName error:(NSError **)error;



/**
 插入
 @param tableName 表名
 @param propertys 属性名数组
 @param values 值数组
 @param error 错误信息
 */
- (BOOL)insertDataWithTableName:(NSString *)tableName propertys:(NSArray *)propertys values:(NSArray *)values error:(NSError **)error;


/**
 查询
 @param tableName 表名
 @param whereString 查询语句
 @param propertys 属性表（用于获取数据）
 @param error 错误信息
 @return 查询的结果
 */
- (NSArray *)searchDataWithTableName:(NSString *)tableName whereString:(NSString *)whereString propertys:(NSArray *)propertys error:(NSError **)error;

/**
 查询
 @param tableName 表名
 @param whereString 查询语句
 @param propertys 属性表（用于获取数据）
 @param order 排序
 @param error 错误信息
 @return 查询的结果
 */
- (NSArray *)searchDataWithTableName:(NSString *)tableName whereString:(NSString *)whereString propertys:(NSArray *)propertys order:(NSString *)order error:(NSError **)error;


/**
 更新
 @param tableName 表名
 @param propertys 属性表（用于存储）
 @param values 值
 @param whereString 查询语句
 @param error 错误信息
 @return 更新结果
 */
- (BOOL)updateDataWithTableName:(NSString *)tableName propertys:(NSArray *)propertys values:(NSArray *)values where:(NSString *)whereString error:(NSError **)error;


/**
 删除
 @param tableName 表名
 @param whereString 查询语句
 @param error 错误信息
 @return 结果
 */
- (BOOL)deleteDataWithTableName:(NSString *)tableName where:(NSString *)whereString error:(NSError **)error;

/**
 检测在指定的数据库中是否存在对应的表
 @param tableName 表名
 @param error 错误
 */
- (BOOL)checkHadTable:(NSString *)tableName result:(NSError **)error;


/**
 最后插入数据的列id
 */
- (NSInteger)lastInsertRowID;

@end

#endif /* RJDataHelperDelegate_h */

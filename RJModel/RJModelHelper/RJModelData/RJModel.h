//
//  RJModel.h
//  RJModelHelper
//
//  Created by Po on 2017/8/28.
//  Copyright © 2017年 Po. All rights reserved.
//

/**
 轻量级数据本地化存储方案
 **/

#import <Foundation/Foundation.h>

@interface RJModel : NSObject
@property (assign, nonatomic) NSInteger idNum;                        //ID: primer key, 数据库中为id

@property (strong, nonatomic, readonly) NSString * dataTableName;     //数据库表名
@property (strong, nonatomic, readonly) NSDictionary * propertyTypeDic;


@property (strong, nonatomic, readonly) NSArray * propertysArray;     //属性表缓存
@property (strong, nonatomic, readonly) NSArray * typesArray;         //属性类型缓存


/**
 建立模型的本地数据表
 */
+ (BOOL)createLocationTable;

/**
 清空模型数据表
 */
+ (BOOL)clearLocationTable;

/**
 删除本地数据表
 */
+ (BOOL)drapLocationTable;





/**
 存储、更新数据
 */
- (BOOL)saveModel;

/**
 存储，更新指定条件的数据

 @param whereString 条件语句
 */
- (BOOL)saveModelWithWhere:(NSString *)whereString;

/**
 存储，更新指定条件的数据集

 @param models 指定的模型集（以id为主键）
 */
+ (BOOL)saveModels:(NSArray<RJModel *>*)models;

/**
 存储，更新指定条件以及主键的数据集(一定要小心)
 
 @param models 指定的模型集
 @param whereArray 条件集
 */
+ (BOOL)saveModels:(NSArray<RJModel *>*)models wheres:(NSArray *)whereArray;




/**
 删除
 */
- (BOOL)deleteSelf;

/**
 删除指定条件的数据

 @param whereString 删除规则
 */
+ (BOOL)deleteSelfWithWhere:(NSString *)whereString;

/**
 删除所有符合指定条件集的数据

 @param whereArray 删除规则集
 */
+ (BOOL)deleteWithWheres:(NSArray *)whereArray;



/**
 查询模型所有数据
 */
+ (NSArray *)getModels;

/**
 查询符合筛选条件的模型数据

 @param whereString 查询条件
 */
+ (NSArray *)getModelsWithWhere:(NSString *)whereString;

/**
 查询符合筛选条件的模型数据
 
 @param order 排序规则
 */
+ (NSArray *)getModelsWithOrder:(NSString *)order;

/**
 查询符合筛选条件的模型数据

 @param whereString 查询条件
 @param order 排序规则
 */
+ (NSArray *)getModelsWithWhere:(NSString *)whereString order:(NSString *)order;








- (NSArray *)getValues;
@end






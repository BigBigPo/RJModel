//
//  RJModelCatch.h
//  RJModelHelper
//
//  Created by Po on 2017/9/1.
//  Copyright © 2017年 Po. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJModelData : NSObject
@property (strong, nonatomic) NSArray * propertys;
@property (strong, nonatomic) NSArray * types;
@end

@interface RJModelCatch : NSObject
+ (instancetype)shareHelper;

/**
 清空缓存
 */
- (void)clearCatch;


/**
 保存数据到缓存中

 @param propertys 属性集合
 @param types 属性类型集合
 @param talbeName 表名
 */
- (void)saveCatchWithPropertys:(NSArray *)propertys types:(NSArray *)types talbeName:(NSString *)talbeName;


/**
 从缓存中获取类的属性列表及其类型
 
 @param tableName 表名
 @return 数据
 */
- (RJModelData *)getPropertysAndTypesWithTableName:(NSString *)tableName;
@end




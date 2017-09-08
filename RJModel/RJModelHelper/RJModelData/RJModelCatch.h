//
//  RJModelCatch.h
//  RJModelHelper
//
//  Created by Po on 2017/9/1.
//  Copyright © 2017年 Po. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RJModel;
@interface RJModelData : NSObject
@property (strong, nonatomic) NSArray * propertys;
@property (strong, nonatomic) NSArray * types;

@property (strong, nonatomic) NSDictionary * propertyTypeDic;           //Property : Type
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
 @param name 表名
 */
- (void)saveCatchWithPropertys:(NSArray *)propertys types:(NSArray *)types className:(NSString *)name;


/**
 从缓存中获取类的属性列表及其类型
 
 @param name 表名
 @return 数据
 */
- (RJModelData *)getPropertysAndTypesWithClassName:(NSString *)name;
@end




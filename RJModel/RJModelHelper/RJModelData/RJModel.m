//
//  RJModel.m
//  RJModelHelper
//
//  Created by Po on 2017/8/28.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "RJModel.h"
#import "RJModelCatch.h"
#import "RJDataHelper.h"
#import "NSObject+RJObject.h"
@interface RJModel()

@end

@implementation RJModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataTableName = [[self class] getTableDataName];
        RJModelData * modelData = [[self class] getPropertyAndType];
        if (modelData) {
            _propertysArray = modelData.propertys;
            _typesArray = modelData.types;
        }
    }
    return self;
}

#pragma mark - function
- (BOOL)saveModel{
    NSString * whereString = @"";
    if (_idNum != 0) {
        whereString = [NSString stringWithFormat:@"id = %ld", _idNum];
    }
    return [self saveModelWithWhere:whereString];
}

- (BOOL)saveModelWithWhere:(NSString *)whereString {
    if(![[self class] createLocationTable]) {
        return NO;
    }
    
    __block BOOL result = YES;
    __weak typeof(self) wself = self;
    //查看数据是否存在，若存在则更新，不存在则插入
    [RJDataHelper runDataHelper:^(id<RJDataHelperDelegate> helper) {
        result =[wself saveAndUpdateDataWithHelper:helper whereString:whereString];
        
        NSInteger idNum = [helper lastInsertRowID];
        wself.idNum = idNum;
    }];
    
    return result;
}

+ (BOOL)saveModels:(NSArray<RJModel *>*)models {
    if(![self createLocationTable]) {
        return NO;
    }

    __block BOOL result = YES;
    //查看数据是否存在，若存在则更新，不存在则插入
    [RJDataHelper runDatasHelper:^(id<RJDataHelperDelegate> helper) {
        for (RJModel * model in models) {
            NSString * whereString = @"";
            if (model.idNum != 0) {
                whereString = [NSString stringWithFormat:@"id = %ld", model.idNum];
            }
            
            result = [model saveAndUpdateDataWithHelper:helper whereString:whereString];
            
            NSInteger idNum = [helper lastInsertRowID];
            model.idNum = idNum;
        }
    }];
    return result;
}

+ (BOOL)saveModels:(NSArray<RJModel *>*)models wheres:(NSArray *)whereArray {
    if (models.count != whereArray.count) {
        return NO;
    }
    
    __block BOOL result = YES;
    //查看数据是否存在，若存在则更新，不存在则插入
    [RJDataHelper runDatasHelper:^(id<RJDataHelperDelegate> helper) {
        for (NSInteger count = 0; count < models.count; count ++) {

            RJModel * model = models[count];
            result = [model saveAndUpdateDataWithHelper:helper whereString:whereArray[count]];
            if (!result) {
                return;
            }
            NSInteger idNum = [helper lastInsertRowID];
            model.idNum = idNum;
        }
    }];
    return result;
}

+ (NSArray *)getAllModels {
    return [self getAllModelsWithWhere:nil order:nil];
}

+ (NSArray *)getAllModelsWithWhere:(NSString *)whereString {
    return [self getAllModelsWithWhere:whereString order:nil];
}

+ (NSArray *)getAllModelsWithOrder:(NSString *)order {
    return [self getAllModelsWithWhere:nil order:order];
}

+ (NSArray *)getAllModelsWithWhere:(NSString *)whereString order:(NSString *)order {
    __block NSArray * models = [NSArray array];
    __block BOOL result = YES;
    [RJDataHelper runDataHelper:^(id<RJDataHelperDelegate> helper) {
        NSError * error = nil;
        
        RJModelData * modelData = [self getPropertyAndType];
        
        models = [helper searchDataWithTableName:[self getTableDataName] whereString:whereString propertys:modelData.propertys order:order error:&error];
        if (error) {
            result = NO;
            NSLog(@"%@", error.description);
        }
    }];
    
    if (!result) {
        return nil;
    }
    
    NSMutableArray * temp = [NSMutableArray array];
    for (NSDictionary * dic in models) {
        RJModel * model = [[self alloc] init];
        for (NSString * property in [dic allKeys]) {
            [model setValue:dic[property] forKey:property];
        }
        [temp addObject:model];
    }
    return [temp copy];;
    
}

- (BOOL)deleteSelf {
    NSString * whereString = @"";
    if (_idNum == 0) {
        NSLog(@"%@ 并没有本地数据",[self class]);
        return NO;
    }
    whereString = [NSString stringWithFormat:@"id = %ld", _idNum];
    return [[self class] deleteSelfWithWhere:whereString];
}

+ (BOOL)deleteSelfWithWhere:(NSString *)whereString {
    __block BOOL result = NO;
    __weak typeof(self) wself = self;
    [RJDataHelper runDataHelper:^(id<RJDataHelperDelegate> helper) {
        NSError * error = nil;
        result = [helper deleteDataWithTableName:[wself getTableDataName] where:whereString error:&error];
    }];
    return result;
}

+ (BOOL)deleteWithWheres:(NSArray *)whereArray {
    __block BOOL result = NO;
    __block NSString * tableName = [self getTableDataName];
    [RJDataHelper runDatasHelper:^(id<RJDataHelperDelegate> helper) {
        
        for (NSString * whereString in whereArray) {
            NSError * error = nil;
            result = [helper deleteDataWithTableName:tableName where:whereString error:&error];
        }
    }];
    return result;
}

#pragma mark - tools

/**
 存储、更新数据
 若没有查询语句则直接插入数据，存在查询语句时首先查询出匹配的数据，再更新。若没有查找到则返回NO。

 @param helper 数据库操作对象
 @param whereString 查询语句
 @return 操作结果
 */
- (BOOL)saveAndUpdateDataWithHelper:(id<RJDataHelperDelegate>)helper whereString:(NSString *)whereString {
    NSArray * values = [self getValues];
    NSError * error = nil;
    //若没有查询语句，直接插入
    if (!whereString || [whereString isEqualToString:@""]) {
        if(![helper insertDataWithTableName:_dataTableName propertys:_propertysArray values:values error:&error]) {
            NSLog(@"%@", error.description);
            return NO;
        }
        
    } else {
        //查询数据
        NSArray * datas = [helper searchDataWithTableName:_dataTableName whereString:whereString propertys:_propertysArray error:&error];
        if (error) {
            NSLog(@"%@", error.description);
            return NO;
        }
        
        //若没有查询到数据则返回
        if (datas.count == 0) {
            return NO;
        }
        
        //若查询到数据，则更新数据
        if (![helper updateDataWithTableName:_dataTableName propertys:_propertysArray values:values where:whereString error:&error]) {
            NSLog(@"%@", error.description);
            return NO;
        }
    }
    return YES;
}


/**
 获取当前模型在数据库中的表名
 */
+ (NSString *)getTableDataName {
    return [NSString stringWithFormat:@"%@Table", NSStringFromClass(self)];
}

/**
 获取当前模型所有数据
 */
- (NSArray *)getValues {
    NSMutableArray * temp = [NSMutableArray array];
    for (NSInteger i = 0; i < _propertysArray.count; i ++) {
        NSString * property = _propertysArray[i];
        NSString * value = [NSString stringWithFormat:@"%@",[self valueForKeyPath:property]];
        [temp addObject:value];
    }
    return [temp copy];
}


/**
 获取属性与属性类型的数据，并缓存起来，每一次获取都优先从缓存中查找。
 */
+ (RJModelData *)getPropertyAndType {
    RJModelData * data = [[RJModelCatch shareHelper] getPropertysAndTypesWithTableName:[self getTableDataName]];
    if (data) {
        return data;
    }
    
    NSArray * names = nil;
    NSArray * types = nil;
    [self getSelfPropertyWithName:&names type:&types];
    
    if (names && types) {
        data = [[RJModelData alloc] init];
        data.propertys = names;
        data.types = types;
        return data;
    }
    return nil;
}

/**
 建表
 检测模型表是否存在，否则创建
 */
+ (BOOL)createLocationTable {
    __block BOOL result = NO;
    __block NSString * tableName = [self getTableDataName];
    __block RJModelData * modelData = [self getPropertyAndType];
    [RJDataHelper runDataHelper:^(id<RJDataHelperDelegate> helper) {
        NSError * error = nil;
        if(![helper checkHadTable:tableName result:&error]) {
            if (![helper createTableWithName:tableName propertyKey:modelData.propertys error:&error]) {
                NSLog(@"%@", error.description);
            }
        } else if (error){
            NSLog(@"[%@] %@",tableName, error.description);
        } else {
            result = YES;
        }
    }];
    return result;
}

+ (BOOL)clearLocationTable {
    __block BOOL result = NO;
    __block NSString * tableName = [self getTableDataName];
    [RJDataHelper runDataHelper:^(id<RJDataHelperDelegate> helper) {
        NSError * error = nil;
        result = [helper clearTableWithName:tableName error:&error];
    }];
    return result;
}

+ (BOOL)drapLocationTable {
    __block BOOL result = NO;
    __block NSString * tableName = [self getTableDataName];
    [RJDataHelper runDataHelper:^(id<RJDataHelperDelegate> helper) {
        NSError * error = nil;
        result = [helper dropTableWithName:tableName error:&error];
    }];
    return result;
}
@end


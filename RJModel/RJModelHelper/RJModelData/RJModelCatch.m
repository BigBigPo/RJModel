//
//  RJModelCatch.m
//  RJModelHelper
//
//  Created by Po on 2017/9/1.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "RJModelCatch.h"

@implementation RJModelData
@end



static RJModelCatch * modelCatch = nil;
@interface RJModelCatch ()
@property (strong, nonatomic) NSDictionary * datas;
@end

@implementation RJModelCatch
+ (instancetype)shareHelper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modelCatch = [[RJModelCatch alloc] init];
    });
    return modelCatch;
}

- (void)saveCatchWithPropertys:(NSArray *)propertys types:(NSArray *)types talbeName:(NSString *)talbeName {
    if (propertys.count == types.count && propertys.count != 0) {
        RJModelData * data = [[RJModelData alloc] init];
        data.propertys = [NSArray arrayWithArray:propertys];
        data.types = [NSArray arrayWithArray:types];
        [_datas setValue:data forKey:talbeName];
    }
}

- (RJModelData *)getPropertysAndTypesWithTableName:(NSString *)tableName {
    return _datas[tableName];
}

- (void)clearCatch {
    _datas = nil;
    
}
@end

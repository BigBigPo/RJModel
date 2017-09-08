//
//  RJModelCatch.m
//  RJModelHelper
//
//  Created by Po on 2017/9/1.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "RJModelCatch.h"
#import "NSObject+RJObject.h"
#import "RJModel.h"

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

- (void)saveCatchWithPropertys:(NSArray *)propertys types:(NSArray *)types className:(NSString *)name {
    if (propertys.count == types.count && propertys.count != 0) {
        RJModelData * data = [[RJModelData alloc] init];
        data.propertys = [NSArray arrayWithArray:propertys];
        data.types = [NSArray arrayWithArray:types];
        [_datas setValue:data forKey:name];
    }
}

- (RJModelData *)getPropertysAndTypesWithClassName:(NSString *)name {
    if (!name) {
        return nil;
    }
    
    RJModelData * data = _datas[name];
    if (data) {
        return data;
    }
    
    Class class = NSClassFromString(name);
    if (!class) {
        return nil;
    }
    
    NSArray * names = nil;
    NSArray * types = nil;
    [class getSelfPropertyWithName:&names type:&types];
    
    if (names && types) {
        data = [[RJModelData alloc] init];
        data.propertys = names;
        data.types = types;
        return data;
    }
    return nil;
}

- (void)clearCatch {
    _datas = nil;
    
}
@end

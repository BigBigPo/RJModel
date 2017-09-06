//
//  RJDataHelper.m
//  RJModelHelper
//
//  Created by Po on 2017/8/28.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "RJDataHelper.h"
#import "RJFMDBHelper.h"

static RJDataHelper * rjDataHelper = nil;
@interface RJDataHelper ()

@property (strong, nonatomic) NSDictionary * propertysCatch;
@property (strong, nonatomic) NSDictionary * typesCatch;

@end

@implementation RJDataHelper

+ (instancetype)shareHelper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rjDataHelper = [[RJDataHelper alloc] init];
    });
    return rjDataHelper;
}

#pragma mark - functions

+ (void)runDataHelper:(void(^)(id<RJDataHelperDelegate> helper))block {
    //此处使用了FMDB，也可以使用其他方式进行存储，遵循RJDataHelperDelegate协议即可
    [[RJFMDBHelper shareHelper] runFMDBWithoutTransaction:block];
}

+ (void)runDatasHelper:(void (^)(id<RJDataHelperDelegate> helper))block {
    [[RJFMDBHelper shareHelper] runFMDBWithTransaction:block];
}

@end



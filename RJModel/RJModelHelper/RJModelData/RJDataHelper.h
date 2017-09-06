//
//  RJDataHelper.h
//  RJModelHelper
//
//  Created by Po on 2017/8/28.
//  Copyright © 2017年 Po. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJDataHelperDelegate.h"



@interface RJDataHelper : NSObject

+ (instancetype)shareHelper;

/**
 工具方法

 @param block 数据操作事务
 */
+ (void)runDataHelper:(void(^)(id<RJDataHelperDelegate> helper))block;
+ (void)runDatasHelper:(void (^)(id<RJDataHelperDelegate> helper))block;

@end

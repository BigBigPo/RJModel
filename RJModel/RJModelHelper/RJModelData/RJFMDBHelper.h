//
//  RJFMDBHelper.h
//  RJModelHelper
//
//  Created by Po on 2017/8/31.
//  Copyright © 2017年 Po. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RJDataHelperDelegate.h"
@interface RJFMDBHelper : NSObject <RJDataHelperDelegate>
+ (instancetype)shareHelper;

/**
 工具方法
 内部均采用 FMDatabaseQueue 操作数据库

 @param block 事务处理内容
 */

//处理单个事务
- (void)runFMDBWithTransaction:(void(^)(id<RJDataHelperDelegate> helper))block;

//批量处理事务
- (void)runFMDBWithoutTransaction:(void(^)(id<RJDataHelperDelegate> helper))block;
@end

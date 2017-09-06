//
//  NSObject+RJObject.h
//  FMDBHelper
//
//  Created by Po on 2017/5/18.
//  Copyright © 2017年 Po. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RJObject)

/**
 获取当前类所有的属性，及其类型

 @param names 属性名集合
 @param types 属性类型集合
 @return 操作结果
 */
+ (BOOL)getSelfPropertyWithName:(NSArray **)names type:(NSArray **)types;
@end

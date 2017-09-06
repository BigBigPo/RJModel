//
//  NSObject+RJObject.m
//  FMDBHelper
//
//  Created by Po on 2017/5/18.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "NSObject+RJObject.h"
#import <objc/runtime.h>
@implementation NSObject (RJObject)

+ (BOOL)getSelfPropertyWithName:(NSArray **)names type:(NSArray **)types {
    NSMutableArray * tempNames = [NSMutableArray array];
    NSMutableArray * tempValues = [NSMutableArray array];
    
    unsigned int outCount = 0;
    objc_property_t * properties = class_copyPropertyList(self, &outCount);
    
    for (NSInteger i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        NSString* propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if (propertyName.length == 0) {
            continue;
        }
        
        NSString* propertyType = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        if ([propertyType rangeOfString:@",R,"].length > 0 || [propertyType hasSuffix:@",R"]) {
            NSString* firstWord = [[propertyName substringToIndex:1] uppercaseString];
            NSString* otherWord = [propertyName substringFromIndex:1];
            NSString* setMethodString = [NSString stringWithFormat:@"set%@%@:", firstWord, otherWord];
            SEL setSEL = NSSelectorFromString(setMethodString);
            ///有set方法就不过滤了
            if ([self instancesRespondToSelector:setSEL] == NO) {
                continue;
            }
        }
        
        NSString* propertyClassName = nil;
        if ([propertyType hasPrefix:@"T@"]) {
            NSRange range = [propertyType rangeOfString:@","];
            if (range.location > 4 && range.location <= propertyType.length) {
                range = NSMakeRange(3, range.location - 4);
                propertyClassName = [propertyType substringWithRange:range];
                if ([propertyClassName hasSuffix:@">"]) {
                    NSRange categoryRange = [propertyClassName rangeOfString:@"<"];
                    if (categoryRange.length > 0) {
                        propertyClassName = [propertyClassName substringToIndex:categoryRange.location];
                    }
                }
            }
            //提取关联对象
//            NSLog(@"%@",propertyClassName);
        }
        else if ([propertyType hasPrefix:@"T{"]) {
            NSRange range = [propertyType rangeOfString:@"="];
            if (range.location > 2 && range.location <= propertyType.length) {
                range = NSMakeRange(2, range.location - 2);
                propertyClassName = [propertyType substringWithRange:range];
            }
        }
        else {
            propertyType = [propertyType lowercaseString];
            if ([propertyType hasPrefix:@"ti"] || [propertyType hasPrefix:@"tb"]) {
                propertyClassName = @"int";
            }
            else if ([propertyType hasPrefix:@"tf"]) {
                propertyClassName = @"float";
            }
            else if ([propertyType hasPrefix:@"td"]) {
                propertyClassName = @"double";
            }
            else if ([propertyType hasPrefix:@"tl"] || [propertyType hasPrefix:@"tq"]) {
                propertyClassName = @"long";
            }
            else if ([propertyType hasPrefix:@"tc"]) {
                propertyClassName = @"char";
            }
            else if ([propertyType hasPrefix:@"ts"]) {
                propertyClassName = @"short";
            }
        }
        
        if (!propertyClassName || propertyClassName.length == 0 ) {
            continue;
        }
        if (!propertyClassName || !propertyName) {
            NSLog(@"%@ 获取属性失败", [self class]);
            return false;
        }
        [tempNames addObject:propertyName];
        [tempValues addObject:propertyClassName];
    }
    free(properties);
    
    *names = [NSArray arrayWithArray:tempNames];
    *types = [NSArray arrayWithArray:tempValues];
    
    return true;
}
@end

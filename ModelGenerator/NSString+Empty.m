//
//  NSString+Empty.m
//  ModelGenerator
//
//  Created by mac on 2017/8/25.
//  Copyright © 2017年 zhubch. All rights reserved.
//

#import "NSString+Empty.h"

@implementation NSString (Empty)
/// 是否为空或者是空格
- (BOOL)isEmpty ///< 是否为空或者是空格
{
    
    NSString * newSelf = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(nil == self
       || self.length ==0
       || [self isEqualToString:@""]
       || [self isEqualToString:@"<null>"]
       || [self isEqualToString:@"(null)"]
       || [self isEqualToString:@"null"]
       || newSelf.length ==0
       || [newSelf isEqualToString:@""]
       || [newSelf isEqualToString:@"<null>"]
       || [newSelf isEqualToString:@"(null)"]
       || [newSelf isEqualToString:@"null"]
       || [self isKindOfClass:[NSNull class]] ){
        
        return YES;
        
    }else{
        // <object returned empty description> 会来这里
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [self stringByTrimmingCharactersInSet:set];
        
        return [trimedString isEqualToString: @""];
    }
    
    return NO;
}


@end

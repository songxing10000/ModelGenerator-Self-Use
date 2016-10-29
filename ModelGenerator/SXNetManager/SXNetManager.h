//
//  ViewController.m
//  SXNetManager
//
//  Created by dfpo on 16/10/18.
//  Copyright © 2016年 dfpo. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  网络
 */
@interface SXNetManager : NSObject

+ (_Nonnull instancetype)manager;

/**
 *  根据 hash key 来取消对应的请求
 *
 *  @param key hash key
 */
- (void)cancelTaskWithKey:(NSString * _Nonnull)key;

/**
 *  发起 post 请求
 *
 *  @param api     api
 *  @param params  参数
 *  @param success
 *  @param failure
 *  @return 本次请求的 hash
 */
- (NSString * _Nonnull)postWithAPI:(NSString * _Nonnull)api
                            params:(NSDictionary * _Nullable)params
                         HUDString:(NSString *_Nullable) HUDString
                           success:(void (^ _Nullable)(id _Nullable responseObject))success
                           failure:(void (^ _Nullable)(NSString * _Nullable errorString))failure;

/**
 *  发起 get 请求
 *
 *  @param api     api
 *  @param params  参数
 *  @param success
 *  @param failure
 *  @return 本次请求的 hash
 */
- (NSString * _Nonnull)getWithAPI:(NSString * _Nonnull)api
                            params:(NSDictionary * _Nullable)params
                        HUDString:(NSString *_Nullable) HUDString
                           success:(void (^ _Nullable)(id _Nullable responseObject))success
                           failure:(void (^ _Nullable)(NSString * _Nullable errorString))failure;

@end

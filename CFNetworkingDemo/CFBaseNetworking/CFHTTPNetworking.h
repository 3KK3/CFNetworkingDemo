//
//  CFHTTPNetworking.h
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "CFHTTPRequestConfiguration.h"
#import "CFHTTPResponseConfiguration.h"
@class CFHTTPNetworking;

typedef void(^CFHTTPRequestSuccessBlock)(CFHTTPNetworking * _Nullable networking, id _Nullable responseObject);
typedef void(^CFHTTPRequestFailedBlock)(CFHTTPNetworking * _Nullable networking, NSError * _Nullable error);


@interface CFHTTPNetworking : NSObject

@property (nonatomic, strong, nullable) CFHTTPRequestConfiguration *requestConfiguration;
@property (nonatomic, strong, nullable) CFHTTPResponseConfiguration *responseConfiguration;
@property (nonatomic, strong, nullable) NSURLSessionDataTask *dataTask;

+ (AFHTTPSessionManager *_Nonnull)sessionManager;

// ===========  子类重写👇  ===========

/// 设置header
- (id _Nonnull)parametersWithParameters:(id _Nonnull)parameters;
/// 请求成功解析
- (id _Nonnull)networkingRequestSuccessWithResponseObject:(id _Nonnull)responseObject error:(NSError ** _Nonnull)error;
/// 请求失败解析
- (NSError *_Nonnull)networkingRequestFailureWithError:(NSError *_Nonnull)error responseObj:(id)responseObj;

// ===========  子类重写👆  ===========


+ (instancetype _Nonnull)networkingWithRequestConfiguration: (CFHTTPRequestConfiguration *_Nullable)requestConfiguration
                                      responseConfiguration: (CFHTTPResponseConfiguration *_Nullable)responseConfiguration
                                                    success: (CFHTTPRequestSuccessBlock)success
                                                    failure: (CFHTTPRequestFailedBlock)failure;

+ (instancetype _Nonnull)networkingWithRequestConfiguration: (CFHTTPRequestConfiguration *_Nullable)requestConfiguration
                                      responseConfiguration: (CFHTTPResponseConfiguration *_Nullable)responseConfiguration
                                             uploadProgress: (nullable void (^)(NSProgress * _Nullable uploadProgress)) uploadProgress
                                           downloadProgress: (nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                                                    success: (CFHTTPRequestSuccessBlock)success
                                                    failure: (CFHTTPRequestFailedBlock)failure;

- (void)cancel;

@end


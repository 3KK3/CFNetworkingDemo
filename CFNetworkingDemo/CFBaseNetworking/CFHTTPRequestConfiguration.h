//
//  CFHTTPRequestConfiguration.h
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface CFHTTPRequestConfiguration : NSObject

@property (nonatomic, strong) id parameters;
@property (nonatomic,   copy) NSString *HTTPMethod;
@property (nonatomic,   copy) NSString *URLString;
@property (nonatomic,   copy) void (^multipartFormData)(id <AFMultipartFormData> formData);
@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;

+ (instancetype)configurationWithHTTPMethod: (NSString *)HTTPMethod
                                  URLString: (NSString *)URLString
                                 parameters: (id)parameters;

@end

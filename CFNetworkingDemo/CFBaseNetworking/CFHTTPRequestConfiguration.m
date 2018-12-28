//
//  CFHTTPRequestConfiguration.m
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import "CFHTTPRequestConfiguration.h"

@implementation CFHTTPRequestConfiguration

+ (instancetype)configurationWithHTTPMethod: (NSString *)HTTPMethod
                                  URLString: (NSString *)URLString
                                 parameters: (id)parameters {
    CFHTTPRequestConfiguration *configuration = [CFHTTPRequestConfiguration new];
    configuration.HTTPMethod = HTTPMethod;
    configuration.URLString = URLString;
    configuration.parameters = parameters;
    return configuration;
}

- (AFHTTPRequestSerializer *)requestSerializer {
    if (!_requestSerializer) {
        _requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _requestSerializer;
}

@end

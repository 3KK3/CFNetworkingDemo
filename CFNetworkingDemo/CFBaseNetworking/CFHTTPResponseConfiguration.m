//
//  CFHTTPResponseConfiguration.m
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import "CFHTTPResponseConfiguration.h"
#import <AFNetworking/AFNetworking.h>

@implementation CFHTTPResponseConfiguration

+ (instancetype)configurationWithResponseClass:(Class)responseClass {
    CFHTTPResponseConfiguration *configuration = [CFHTTPResponseConfiguration new];
    configuration.responseClass = responseClass;
    return configuration;
}

- (AFHTTPResponseSerializer *)responseSerializer {
    if (!_responseSerializer) {
        _responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _responseSerializer;
}

@end

//
//  CFHTTPNetworkingImpl.m
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import "CFHTTPNetworkingImpl.h"

@implementation CFHTTPNetworkingImpl

// 重写父类方法 设置请求头 和 处理请求结果

- (id _Nonnull)parametersWithParameters:(id _Nonnull)parameters {
    
    [self.requestConfiguration.requestSerializer setValue: @"ZMJ" forHTTPHeaderField:@"BundleID"];
    [self.requestConfiguration.requestSerializer setValue:@"ios" forHTTPHeaderField:@"User-Agent"];
    [self.requestConfiguration.requestSerializer setValue: @"this is token" forHTTPHeaderField:@"Authorization"];
    
    return parameters;
}

- (id _Nonnull)networkingRequestSuccessWithResponseObject:(id _Nonnull)responseObject error:(NSError ** _Nonnull)error{
    
    if ([self isSucceedByResponseObject:responseObject]) {
        return [self dataByResponseObject:responseObject];
    }
    
    // 请求成功但是数据错误
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.dataTask.response;
    NSInteger statuscode = response.statusCode;
    
    NSString *errorString = [self errorMessageByResponse:responseObject];
    *error = [NSError errorWithDomain:@"com.Cocfish.error"
                                 code:statuscode
                             userInfo:@{NSLocalizedDescriptionKey :errorString}];
    return nil;
}

- (id)dataByResponseObject:(id)responseObject {
    
    id data = [responseObject objectForKey:@"data"];
    if (!data || data == NULL) {
        return responseObject;
    }
    return data;
}


- (NSError *_Nonnull)networkingRequestFailureWithError:(NSError *_Nonnull)error responseObj:(id)responseObj {
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.dataTask.response;
    NSInteger statuscode = response.statusCode;
    
    if (statuscode == 403) { // 重新登录
 
        
        return error;
    }
    
    if (![self isSucceedByResponseObject: responseObj] && [self errorMessageByResponse: responseObj].length) {
        return [NSError errorWithDomain: @"com.Cocfish.error"
                                   code: statuscode
                               userInfo: @{NSLocalizedDescriptionKey :[self errorMessageByResponse: responseObj]}];
    }
    
    return error;
}

- (BOOL)isSucceedByResponseObject:(id)responseObject {
    return [[responseObject objectForKey:@"status"] boolValue];
}

- (NSString *)errorMessageByResponse:(id)responseObject {
    NSDictionary *errorDic = [responseObject objectForKey:@"err"];
    return [errorDic objectForKey:@"msg"];
}

@end

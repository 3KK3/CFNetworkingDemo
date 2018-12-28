//
//  CFHTTPNetworking.m
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import "CFHTTPNetworking.h"
#import <YYModel/YYModel.h>

@implementation CFHTTPNetworking

+ (AFHTTPSessionManager *_Nonnull)sessionManager {
    static AFHTTPSessionManager *sessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [AFHTTPSessionManager manager];
        sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json; charset=UTF-8", @"text/json", @"text/javascript", @"text/html",@"text/plain",@"form/data", nil];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [securityPolicy setAllowInvalidCertificates:YES];
        [sessionManager setSecurityPolicy:securityPolicy];
        [sessionManager.securityPolicy setValidatesDomainName:NO];
    });
    return sessionManager;
}

// ===========  子类重写👇  ===========

- (id _Nonnull)parametersWithParameters:(id _Nonnull)parameters {
    NSAssert(0, @"需要子类实现");
    return parameters;
}

- (id _Nonnull)networkingRequestSuccessWithResponseObject:(id _Nonnull)responseObject error:(NSError ** _Nonnull)error{
    NSAssert(0, @"需要子类实现");
    return responseObject;
}

- (NSError *_Nonnull)networkingRequestFailureWithError:(NSError *)error responseObj:(id)responseObj{
    NSAssert(0, @"需要子类实现");
    return error;
}

// ===========  子类重写👆  ===========


+ (instancetype _Nonnull)networkingWithRequestConfiguration: (CFHTTPRequestConfiguration *)requestConfiguration
                                      responseConfiguration: (CFHTTPResponseConfiguration *)responseConfiguration
                                                    success: (CFHTTPRequestSuccessBlock)success
                                                    failure: (CFHTTPRequestFailedBlock)failure {
    
    CFHTTPNetworking *networking = [[self class] new];
    networking.requestConfiguration = requestConfiguration;
    networking.responseConfiguration = responseConfiguration;
    networking.dataTask = [networking startWithUploadProgress: nil
                                             downloadProgress: nil
                                                      success: success
                                                      failure: failure];
    return networking;
}

+ (instancetype _Nonnull)networkingWithRequestConfiguration: (CFHTTPRequestConfiguration *)requestConfiguration
                                      responseConfiguration: (CFHTTPResponseConfiguration *)responseConfiguration
                                             uploadProgress: (void (^)(NSProgress * _Nullable))uploadProgress
                                           downloadProgress: (void (^)(NSProgress * _Nullable))downloadProgress
                                                    success: (CFHTTPRequestSuccessBlock)success
                                                    failure: (CFHTTPRequestFailedBlock)failure {
    
    CFHTTPNetworking *networking = [[self class] new];
    networking.requestConfiguration = requestConfiguration;
    networking.responseConfiguration = responseConfiguration;
    networking.dataTask = [networking startWithUploadProgress: uploadProgress
                                             downloadProgress: downloadProgress
                                                      success: success
                                                      failure: failure];
    return networking;
}

- (NSURLSessionDataTask *)startWithUploadProgress: (nullable void (^)(NSProgress * _Nullable uploadProgress)) uploadProgress
                                 downloadProgress: (nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                                          success: (CFHTTPRequestSuccessBlock)success
                                          failure: (CFHTTPRequestFailedBlock)failure {
    
    return [self dataTaskWithHTTPMethod: self.requestConfiguration.HTTPMethod
                              URLString: self.requestConfiguration.URLString
                             parameters: [self parametersWithParameters:self.requestConfiguration.parameters]
                         uploadProgress: uploadProgress
                       downloadProgress: downloadProgress
                                success: success
                                failure: failure];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(CFHTTPRequestSuccessBlock)success
                                         failure:(CFHTTPRequestFailedBlock)failure
{
    
    [CFHTTPNetworking sessionManager].responseSerializer = self.responseConfiguration.responseSerializer;
    [CFHTTPNetworking sessionManager].requestSerializer = self.requestConfiguration.requestSerializer;
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request;
    
    if (self.requestConfiguration.multipartFormData) {
        request = [[CFHTTPNetworking sessionManager].requestSerializer multipartFormRequestWithMethod: method
                                                                                            URLString: URLString
                                                                                           parameters: parameters
                                                                            constructingBodyWithBlock: ^(id<AFMultipartFormData>  _Nonnull formData) {
                                                                                self.requestConfiguration.multipartFormData(formData);
                                                                            }
                                                                                                error: &serializationError];
        
    } else {
        request = [[CFHTTPNetworking sessionManager].requestSerializer requestWithMethod: method
                                                                               URLString: URLString
                                                                              parameters: parameters
                                                                                   error: &serializationError];
        
    }
    
    if (serializationError) {
        if (failure) {
            dispatch_async([CFHTTPNetworking sessionManager].completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [[CFHTTPNetworking sessionManager] dataTaskWithRequest: request
                                                       uploadProgress: uploadProgress
                                                     downloadProgress: downloadProgress
                                                    completionHandler: ^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                                                        
                                                        if (error) {
                                                            error = [self networkingRequestFailureWithError: error
                                                                                                responseObj: responseObject];
                                                            if (failure) {
                                                                failure(self, error);
                                                            }
                                                            return ;
                                                        }
                                                        
                                                        NSError *responseError;
                                                        responseObject = [self networkingRequestSuccessWithResponseObject: responseObject
                                                                                                                    error: &responseError];
                                                        
                                                        if (responseError) {
                                                            responseError = [self networkingRequestFailureWithError: responseError
                                                                                                        responseObj: responseObject];
                                                            if (failure) {
                                                                failure(self, responseError);
                                                            }
                                                            return;
                                                        }
                                                        
                                                        if (success) {
                                                            success(self, [self parseDataWithJSONObject:responseObject]);
                                                        }
                                                    }];
    
    [dataTask resume];
    return dataTask;
}

- (id)parseDataWithJSONObject:(id)JSONObject {
    if (self.responseConfiguration.responseClass == nil) {
        return JSONObject;
    }
    
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        return [self.responseConfiguration.responseClass yy_modelWithJSON:JSONObject];
    }
    
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        return [NSArray yy_modelArrayWithClass: self.responseConfiguration.responseClass
                                          json: JSONObject];
    }
    
    return nil;
}

- (void)cancel {
    [self.dataTask cancel];
}


@end

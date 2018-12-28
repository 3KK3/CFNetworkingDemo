//
//  CFNetworkingManager.m
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import "CFNetworkingManager.h"
#import "CFHTTPNetworkingImpl.h"
#import <QiniuSDK.h>
#import <HappyDNS.h>

@implementation CFNetworkingManager

+ (CFHTTPNetworkingImpl *)networkingWithHTTPMethod: (NSString *)HTTPMethod
                                         URLString: (NSString *)URLString
                                        parameters: (id)parameters
                                     responseClass: (Class)responseClass
                                          callBack: (CFRequestCallBack)callBack {
    
    return [CFNetworkingManager networkingWithHTTPMethod: HTTPMethod
                                               URLString: URLString
                                              parameters: parameters
                                           responseClass: responseClass
                                       requestSerializer: nil
                                      responseSerializer: nil
                                       multipartFormData: nil
                                                callBack: callBack];
}

+ (CFHTTPNetworkingImpl *)networkingWithHTTPMethod: (NSString *)HTTPMethod
                                         URLString: (NSString *)URLString
                                        parameters: (id)parameters
                                     responseClass: (Class)responseClass
                                 requestSerializer: (AFHTTPRequestSerializer *)requestSerializer
                                responseSerializer: (AFHTTPResponseSerializer *)responseSerializer
                                 multipartFormData: (void (^)(id <AFMultipartFormData> formData))multipartFormData
                                          callBack: (CFRequestCallBack)callBack {
    
    CFHTTPResponseConfiguration *responseConfiguration = [CFHTTPResponseConfiguration configurationWithResponseClass:responseClass];
    if (responseSerializer) {
        responseConfiguration.responseSerializer = responseSerializer;
    }
    
    CFHTTPRequestConfiguration *requestConfiguration = [CFHTTPRequestConfiguration configurationWithHTTPMethod: HTTPMethod
                                                                                                     URLString: URLString
                                                                                                    parameters: parameters];
    if (requestSerializer) {
        requestConfiguration.requestSerializer = requestSerializer;
    }
    
    if (multipartFormData) {
        requestConfiguration.multipartFormData = multipartFormData;
    }
    
    CFHTTPNetworkingImpl *networking = [CFHTTPNetworkingImpl networkingWithRequestConfiguration: requestConfiguration
                                                                          responseConfiguration: responseConfiguration
                                                                                        success: ^(CFHTTPNetworking * _Nullable networking, id  _Nullable responseObject) {
                                                                                            if (callBack) {
                                                                                                callBack(nil,responseObject);
                                                                                            }
                                                                                        }
                                                                                        failure: ^(CFHTTPNetworking * _Nullable networking, NSError * _Nullable error) {
                                                                                            if (callBack) {
                                                                                                callBack(error,nil);
                                                                                            }
                                                                                        }];
    
    return networking;
}

// ----------                   ----------

+ (CFHTTPNetworkingImpl *)uploadImage: (id)image
                    imgSourceType: (EANetworkingUploadImageSourceType)imgSourceType
                         callBack: (CFRequestCallBack)callBack {
    
    return [self uploadFile: image
                   fileType: EANetworkingUploadFileTypeJPG
                   signType: EANetworkingUploadSignTypeImage
              imgSourceType: EANetworkingUploadImageSourceTypeNone
                   progress: nil
                   callBack: callBack];
}

+ (CFHTTPNetworkingImpl *)uploadFile: (NSData *)file
                        fileType: (EANetworkingUploadFileType)fileType
                        signType: (EANetworkingUploadSignType)signType
                   imgSourceType: (EANetworkingUploadImageSourceType)imgSourceType
                        progress: (void (^)(CGFloat))progress
                        callBack: (CFRequestCallBack)callBack {
    
    /// 2.七牛上传结束后的回调
    QNUpCompletionHandler QNCompletionHandler = ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.ok) {
            NSString *url = [NSString stringWithFormat:@"/%@", resp[@"key"]];
            if (callBack) {
                callBack(nil,url);
            }
            return ;
        }
        
        if (callBack) {
            NSError *error = [NSError errorWithDomain: @"com.Cocfish.www"
                                                 code: 0
                                             userInfo: @{NSLocalizedDescriptionKey : @"上传失败"}];
            callBack(error,nil);
        }
    };
    
    /// 1,请求七牛token结束后的回调
    CFRequestCallBack requestQiNiuTokenCallBack = ^(NSError *error, id responseObj) {
        
        if (error) {
            if (callBack) {
                callBack(error,nil);
            }
            return ;
        }
        
        QNConfiguration *config =[QNConfiguration build:^(QNConfigurationBuilder *builder) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:[QNResolver systemResolver]];
            QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];
            //是否选择  https  上传
            builder.zone = [[QNAutoZone alloc] initWithHttps:YES dns:dns];
        }];
        
        QNUploadManager *manager = [[QNUploadManager alloc] initWithConfiguration:config];
        QNUploadOption *option = [[QNUploadOption alloc] initWithProgressHandler:^(NSString *key, float percent) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progress) {
                    progress(percent);
                }
            });
        }];
        
        NSString *fileName = [CFNetworkingManager fileTotalNameWithFileType: fileType
                                                                    signType: signType
                                                               imgSourceType: imgSourceType];
        /// 调用七牛接口上传文件
        [manager putData: file
                     key: fileName
                   token: responseObj[@"token"]
                complete: QNCompletionHandler
                  option: option];
    };
    
    /// 请求七牛上传token
    return [CFNetworkingManager networkingWithHTTPMethod: @"GET"
                                                URLString: @"qi_niui_token"
                                               parameters: nil
                                            responseClass: nil
                                                 callBack: requestQiNiuTokenCallBack];
    
}

+ (NSString *)fileTotalNameWithFileType: (EANetworkingUploadFileType)fileType
                               signType: (EANetworkingUploadSignType)signType
                          imgSourceType: (EANetworkingUploadImageSourceType)imgSourceType {
    
    //完整文件名称：  upload / signType /  dateStr             _ timeSp        _ random  _ sourceType . fileType
    //例如视频：     upload /   video  / 2017_02_17/04_50_17  _ 1487321417358 _ 422249               . mp4
    //例如图片：     upload /   image  / 2017_02_17/04_50_17  _ 1487321417358 _ 422249 _  photo      . jpg
    
    NSMutableString *fileName = [NSMutableString stringWithString: @"upload"];
    
    switch (signType) {
        case EANetworkingUploadSignTypeNone: {
            NSAssert(0, @"必须设置sign type");
        }
            break;
        case EANetworkingUploadSignTypeImage: {
            [fileName appendString: @"/image/"];
        }
            break;
            
        case EANetworkingUploadSignTypeVideo: {
            [fileName appendString: @"/video/"];
        }
            break;
    }
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy_MM_dd/HH_mm_ss"];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *dateStr = [formatter stringFromDate: date];
    [fileName appendString: dateStr];
    
    [fileName appendString: @"_"];
    
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", [date timeIntervalSince1970] * 1000];
    [fileName appendString: timeSp];
    
    [fileName appendString: @"_"];
    
    NSString *random = [NSString stringWithFormat:@"%u", arc4random()%900000 + 100000];
    [fileName appendString: random];
    
    switch (imgSourceType) {
        case EANetworkingUploadImageSourceTypeNone: {
        }
            break;
            
        case EANetworkingUploadImageSourceTypePhoto: {
            [fileName appendString: @"_photo"];
        }
            break;
            
        case EANetworkingUploadImageSourceTypeCamera: {
            [fileName appendString: @"_camera"];
            
        }
            break;
    }
    
    switch (fileType) {
        case EANetworkingUploadFileTypeNone: {
            NSAssert(0, @"必须设置fileType");
        }
            break;
            
        case EANetworkingUploadFileTypeJPG: {
            [fileName appendString: @".jpg"];;
        }
            break;
            
        case EANetworkingUploadFileTypeMP4: {
            [fileName appendString: @".mp4"];;
        }
            break;
    }
    
    return [fileName copy];
}


@end

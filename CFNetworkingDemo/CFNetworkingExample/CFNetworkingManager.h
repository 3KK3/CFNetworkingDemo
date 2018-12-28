//
//  CFNetworkingManager.h
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

// --------------- 此文件内容直接来源于公司项目  懒得改了😂   ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️


#import <Foundation/Foundation.h>
#import <AFNetworking.h>
@class CFHTTPNetworkingImpl;

typedef NS_ENUM(NSInteger, EANetworkingUploadFileType) {
    EANetworkingUploadFileTypeNone,
    EANetworkingUploadFileTypeJPG,
    EANetworkingUploadFileTypeMP4,
};


typedef NS_ENUM(NSInteger, EANetworkingUploadSignType) {
    EANetworkingUploadSignTypeNone,
    EANetworkingUploadSignTypeImage,
    EANetworkingUploadSignTypeVideo,
};


typedef NS_ENUM(NSInteger, EANetworkingUploadImageSourceType) {
    EANetworkingUploadImageSourceTypeNone,
    EANetworkingUploadImageSourceTypeCamera,
    EANetworkingUploadImageSourceTypePhoto,
    
};

typedef void(^CFRequestCallBack)(NSError *error, id responseObj);

@interface CFNetworkingManager : NSObject

+ (CFHTTPNetworkingImpl *)networkingWithHTTPMethod: (NSString *)HTTPMethod
                                         URLString: (NSString *)URLString
                                        parameters: (id)parameters
                                     responseClass: (Class)responseClass
                                          callBack: (CFRequestCallBack)callBack;

+ (CFHTTPNetworkingImpl *)networkingWithHTTPMethod: (NSString *)HTTPMethod
                                         URLString: (NSString *)URLString
                                        parameters: (id)parameters
                                     responseClass: (Class)responseClass
                                 requestSerializer: (AFHTTPRequestSerializer *)requestSerializer
                                responseSerializer: (AFHTTPResponseSerializer *)responseSerializer
                                 multipartFormData: (void (^)(id <AFMultipartFormData> formData))multipartFormData
                                          callBack: (CFRequestCallBack)callBack;


/**
 使用七牛云上传图片
 
 @param image         二进制文件 或者 UIImage
 @param imgSourceType 图片来源
 @param callBack      回调,responseObj是图片地址
 
 完整文件名称：  upload /  type /  dateStr           _ timeSp        _ random  _ sourceType . fileType
 例如      :   upload / image / 2017_02_17/04_50_17 _ 1487321417358 _ 422249 _  photo      . jpg
 */
+ (CFHTTPNetworkingImpl *)uploadImage: (id)image
                        imgSourceType: (EANetworkingUploadImageSourceType)imgSourceType
                             callBack: (CFRequestCallBack)callBack;

/**
 使用七牛云上传图片
 
 @param file            二进制文件
 @param fileType        文件类型，参与命名文件后缀 如jpg、png、mp4
 @param signType        文件种类标识，参与命名
 @param imgSourceType   照片资源来源，区分是来自相册（photo）还是来自相机（camera），参与命名； 可以传空
 @param progress        上传进度
 @param callBack        回调，responseObj是图片地址
 
 完整文件名称：  upload / signType /  dateStr             _ timeSp        _ random  _ sourceType . fileType
 例如图片：     upload /   image  / 2017_02_17/04_50_17  _ 1487321417358 _ 422249 _  photo      . jpg
 例如视频：     upload /   video  / 2017_02_17/04_50_17  _ 1487321417358 _ 422249               . mp4
 
 */
+ (CFHTTPNetworkingImpl *)uploadFile: (NSData *)file
                            fileType: (EANetworkingUploadFileType)fileType
                            signType: (EANetworkingUploadSignType)signType
                       imgSourceType: (EANetworkingUploadImageSourceType)imgSourceType
                            progress: (void (^)(CGFloat progress))progress
                            callBack: (CFRequestCallBack)callBack;

@end

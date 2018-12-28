//
//  CFDownloadTask.h
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CFDownloadTask : NSObject

@property (nonatomic, strong) NSURL *downloadURL;
@property (nonatomic,   copy) NSString *fileName;
@property (nonatomic,   copy) NSString *filenameExtension;
@property (nonatomic,   copy) NSString *fileStoragePath; // 会自动拼接fileName 存储文件
@property (nonatomic,   copy) void (^downloadProgress)(NSProgress * downloadProgress, CGFloat progress);
@property (nonatomic,   weak) NSURLSessionDownloadTask *task;

@end


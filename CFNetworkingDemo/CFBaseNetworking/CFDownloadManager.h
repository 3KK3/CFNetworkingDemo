//
//  CFDownloadManager.h
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFURLSessionManager;
@class CFDownloadTask;


@interface CFDownloadManager : NSObject

@property (nonatomic, strong, readonly) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableArray *downloadTaskArray;

+ (instancetype)downloadManager;

- (void)addDownloadTask: (CFDownloadTask *)task
        completionBlock: (void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionBlock;

- (void)addDownloadTasks: (NSArray <CFDownloadTask *>*)tasks
     taskCompletionBlock: (void (^)(CFDownloadTask *task, NSURLResponse *response, NSURL *filePath, NSError *error))taskCompletionBlock
                progress: (void (^)(NSInteger success, NSInteger failure, NSInteger total))progress;

- (void)cancelAllDownloadTasks;

@end


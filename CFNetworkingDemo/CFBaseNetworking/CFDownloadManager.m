//
//  CFDownloadManager.m
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import "CFDownloadManager.h"
#import <AFNetworking/AFNetworking.h>
#import "CFDownloadTask.h"

@interface CFDownloadManager ()
@property (nonatomic, strong, readwrite) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@end

@implementation CFDownloadManager

+ (instancetype)downloadManager {
    static CFDownloadManager *obj = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        obj = [CFDownloadManager new];
    });
    return obj;
}

- (void)addDownloadTask: (CFDownloadTask *)task
        completionBlock: (void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionBlock {
    
    if (!task || !task.downloadURL) {
        return;
    }
    
    [self.downloadTaskArray addObject:task];
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:task.downloadURL];
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    __weak  NSBlockOperation *weakOperation = operation;
    [operation addExecutionBlock:^{
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号 信号初始值为0
        task.task = [self.sessionManager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
            // @property int64_t totalUnitCount;     需要下载文件的总大小
            // @property int64_t completedUnitCount; 当前已经下载的大小
            if (task.downloadProgress) {
                task.downloadProgress(downloadProgress, 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
            }
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSString *fileStoragePath;
            if (task.fileName.length > 0 && task.filenameExtension.length > 0) {
                fileStoragePath = [NSString stringWithFormat:@"%@%@.%@",task.fileStoragePath, task.fileName, task.filenameExtension];
            } else {
                fileStoragePath = [NSString stringWithFormat:@"%@%@",task.fileStoragePath, response.suggestedFilename];
            }
            NSURL *destination = [NSURL fileURLWithPath:fileStoragePath];
            [[NSFileManager defaultManager] removeItemAtURL:destination error:nil];
            return destination;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (weakOperation.cancelled) {
                return;
            }
            if (completionBlock) {
                completionBlock(response,filePath,error);
            }
            
            dispatch_semaphore_signal(semaphore);//信号+1
        }];
        [task.task resume];
        long timeout = dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//如果信号为0 则阻塞当前线程，当信号>0时执行后面代码，如果等待超时返回值(timeout)会大于0
        if (timeout > 0) {
            // 信号等待超时 执行错误代码
        }
        
    }];
    [operation setCompletionBlock:^{
        [self.downloadTaskArray removeObject:task];
    }];
    [self.downloadQueue addOperation:operation];
}

- (void)addDownloadTasks: (NSArray <CFDownloadTask *>*)tasks
     taskCompletionBlock: (void (^)(CFDownloadTask *task, NSURLResponse *response, NSURL *filePath, NSError *error))taskCompletionBlock
                progress: (void (^)(NSInteger success, NSInteger failure, NSInteger total))progress {
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:tasks];
    
    __block NSInteger successCount = 0;
    __block NSInteger failureCount = 0;
    __block NSInteger totalCount = array.count;
    
    for (CFDownloadTask *task in tasks) {
        
        [self addDownloadTask:task completionBlock:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            
            [array removeObject: task];
            
            if (taskCompletionBlock) {
                if (error) {
                    failureCount++;
                } else {
                    successCount++;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    taskCompletionBlock(task,response,filePath,error);
                });
            }
            
            if (array.count == 0) {
                if (progress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progress(successCount,failureCount,totalCount);
                    });
                }
            }
            
        }];
    }
}

- (void)cancelAllDownloadTasks {
    [self.downloadQueue cancelAllOperations];
}

- (AFURLSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [[AFURLSessionManager alloc] init];
    }
    return _sessionManager;
}

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadQueue;
}

@end

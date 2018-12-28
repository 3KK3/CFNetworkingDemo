//
//  CFHTTPResponseConfiguration.h
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPResponseSerializer;

@interface CFHTTPResponseConfiguration : NSObject

@property (nonatomic, assign) Class responseClass;
@property (nonatomic, strong) AFHTTPResponseSerializer *responseSerializer;

+ (instancetype)configurationWithResponseClass:(Class)responseClass;

@end


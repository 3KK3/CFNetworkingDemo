//
//  ViewController.m
//  CFNetworkingDemo
//
//  Created by YZY on 2018/12/28.
//  Copyright © 2018 Cocfish. All rights reserved.
//

#import "ViewController.h"
#import "CFNetworkingExample/CFNetworkingManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [CFNetworkingManager networkingWithHTTPMethod: @"GET"
                                        URLString: @"www.badiu.com"
                                       parameters: nil
                                    responseClass: nil
                                         callBack: ^(NSError *error, id responseObj) {
        
    }];
}


@end

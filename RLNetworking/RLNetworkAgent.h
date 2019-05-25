//
//  RLNetworkAgent.h
//  RLNetwokingDemo
//
//  Created by linzuhan on 2018/8/2.
//  Copyright © 2018年 lzh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLBaseRequest;
@protocol RLBaseRequestCommonResponseCodeProtocol;

@interface RLNetworkAgent : NSObject

+ (RLNetworkAgent *)shareAgent;

- (void)registerCommonResponse:(id<RLBaseRequestCommonResponseCodeProtocol>)commonResponse;
- (void)resetCommonResponse;

- (void)addRequest:(RLBaseRequest *)request;
- (void)cancelRequest:(RLBaseRequest *)request;

@end

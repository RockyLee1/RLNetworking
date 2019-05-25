//
//  RLBaseRequestCommonResponseCodeProtocol.h
//  RL
//
//  Created by linzuhan on 2018/9/18.
//  Copyright © 2018年 lzh. All rights reserved.
//

/* 通用参数处理协议 */

#import <Foundation/Foundation.h>

@class RLBaseRequest;

@protocol RLBaseRequestCommonResponseCodeProtocol <NSObject>

// 通用参数列表
- (NSArray *)commonResponseCodeList;

// 是否阻断响应
- (BOOL)isBlockResponse:(NSInteger)code;

// 是否只响应一次
- (BOOL)isResponseOnce:(NSInteger)code;

// 响应回调
- (void)responseCommonCodeWithCode:(NSInteger)code request:(RLBaseRequest *)request;

@end

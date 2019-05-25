//
//  RLBaseRequestUserInfoProtocol.h
//  RL
//
//  Created by linzuhan on 2018/8/21.
//  Copyright © 2018年 lzh. All rights reserved.
//

/* 获取用户信息协议 */

#import <Foundation/Foundation.h>

@protocol RLBaseRequestUserInfoProtocol <NSObject>

- (NSString *)userId;
- (NSString *)accessToken;

@end

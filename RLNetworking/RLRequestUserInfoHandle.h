//
//  RLRequestUserInfoHandle.h
//  RL
//
//  Created by linzuhan on 2018/8/21.
//  Copyright © 2018年 lzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLBaseRequestUserInfoProtocol.h"

@interface RLRequestUserInfoHandle : NSObject

+ (id <RLBaseRequestUserInfoProtocol>)userInfo;

+ (void)registeUserInfo:(id <RLBaseRequestUserInfoProtocol>)userInfo;

@end

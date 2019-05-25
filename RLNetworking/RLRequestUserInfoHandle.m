//
//  RLRequestUserInfoHandle.m
//  RL
//
//  Created by linzuhan on 2018/8/21.
//  Copyright © 2018年 lzh. All rights reserved.
//

#import "RLRequestUserInfoHandle.h"

@interface RLRequestUserInfoHandle ()

@property (nonatomic, weak) id <RLBaseRequestUserInfoProtocol>userInfoModel;

@end

@implementation RLRequestUserInfoHandle

+ (RLRequestUserInfoHandle *)shareHandle
{
    static RLRequestUserInfoHandle *handle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handle = [[self alloc] init];
    });
    
    return handle;
}

+ (id <RLBaseRequestUserInfoProtocol>)userInfo
{
    return [[self shareHandle] userInfoModel];
}

+ (void)registeUserInfo:(id <RLBaseRequestUserInfoProtocol>)userInfo
{
    [self shareHandle].userInfoModel = userInfo;
}

@end

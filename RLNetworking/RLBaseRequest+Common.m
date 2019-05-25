//
//  RLBaseRequest+Common.m
//  RLNetwokingDemo
//
//  Created by linzuhan on 2018/8/2.
//  Copyright © 2018年 lzh. All rights reserved.
//

#import "RLBaseRequest+Common.h"
#include <CommonCrypto/CommonCrypto.h>
#import "RLNetworkingConstant.h"

#import <YYCategories/UIDevice+YYAdd.h>
#import <YYCategories/UIApplication+YYAdd.h>
#import <FCUUID/FCUUID.h>
#import <FCUUID/UIDevice+FCUUID.h>

#import "RLRequestUserInfoHandle.h"

@implementation RLBaseRequest (Common)

- (NSString *)baseURLString
{
    return HOST_URL;
}

- (NSDictionary *)requestCommonParameters
{
    return nil;
}

- (NSDictionary <NSString *, NSString *>*)requestCommonHeaderFieldValueDictionary
{
    NSString *loginType = @"1";                                                                 // 登录端类型:0-安卓，1-IOS,2-web
    NSString *mobileModel = [[UIDevice currentDevice] machineModelName];                        // 手机型号
    NSString *os = [NSString stringWithFormat:@"%.1f",[UIDevice systemVersion]];                  // 操作系统
    NSString *imei = [[UIDevice currentDevice] uuid];                                           // 设备号
    NSString *timestamp = [self requestTimeString];                                             // 时间戳
    NSString *version = [[UIApplication sharedApplication] appVersion];                         // app版本号
    NSString *requestId = @"";                                                                  // 当前请求id
    NSString *accessToken = [self accessToken];
    
    NSMutableString *temp = [NSMutableString string];
    {
        // 拼接请求id逻辑
        [temp appendString:os];
        [temp appendString:imei];
        [temp appendString:[self userId]];
        [temp appendString:timestamp];
        [temp appendString:SECRET_KEY];
    }
    
    requestId = [RLBaseRequest MD5StringWithString:[temp copy]];

    
    NSDictionary *dic = @{
                          @"loginType":loginType,
                          @"mobileModel":mobileModel,
                          @"os":os,
                          @"imei":imei,
                          @"timestamp":timestamp,
                          @"version":version,
                          @"requestId":requestId,
                          @"accessToken":accessToken
                         };

    return dic;
}


#pragma mark - Dynamic Params

- (NSString *)userId
{
    if ([self isIgnoreUserInfoHeaderField]) {
        return @"";
    }
    
    NSString *temp = [[RLRequestUserInfoHandle userInfo] userId];
    if (temp.length <= 0 ) {
        temp = @"";
    }
    
    return temp;
}

- (NSString *)accessToken
{
    if ([self isIgnoreUserInfoHeaderField]) {
        return @"";
    }
    
    NSString *temp = [[RLRequestUserInfoHandle userInfo] accessToken];
    if (temp.length <= 0) {
        temp = @"";
    }
    
    return temp;
}

- (NSTimeInterval)requestTime
{
    NSDate *date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    
    return timeInterval;
}

- (NSString *)requestTimeString
{
    return [NSString stringWithFormat:@"%.6f",[self requestTime]];
}

#pragma mark - Helper

+ (NSString *)MD5StringWithString:(NSString *)string
{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(stringData.bytes, (CC_LONG)stringData.length, result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end

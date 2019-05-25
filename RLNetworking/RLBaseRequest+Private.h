//
//  RLBaseRequest+Private.h
//  RLNetwokingDemo
//
//  Created by linzuhan on 2018/8/2.
//  Copyright © 2018年 lzh. All rights reserved.
//

#import "RLBaseRequest.h"

@interface RLBaseRequest (Private)

@property (nonatomic, strong, readwrite) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readwrite) id responseObject;
@property (nonatomic, strong, readwrite) RLResponseModel *responseModel;
@property (nonatomic, strong, readwrite) NSError *error;

- (NSURL *)requestURL;
- (NSDictionary *)requestParameters;
- (NSDictionary <NSString *, NSString *>*)requestHeaderFieldValueDictionary;

@end

//
//  RLBaseRequest+Common.h
//  RLNetwokingDemo
//
//  Created by linzuhan on 2018/8/2.
//  Copyright © 2018年 lzh. All rights reserved.
//

/* 根据业务模块需要覆盖的方法 */

#import "RLBaseRequest.h"

@interface RLBaseRequest (Common)

- (NSString *)baseURLString;
- (NSDictionary *)requestCommonParameters;
- (NSDictionary <NSString *, NSString *>*)requestCommonHeaderFieldValueDictionary;

@end

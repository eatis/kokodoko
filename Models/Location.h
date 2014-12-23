//
//  Location.h
//  kokodoko
//
//  Created by EATis on 2013/10/29.
//  Copyright (c) 2013年 EATis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (readonly, nonatomic, copy) NSString *locationName;
@property (readonly, nonatomic, copy) NSString *address;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;
@end

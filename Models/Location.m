//
//  Location.m
//  kokodoko
//
//  Created by EATis on 2013/10/29.
//  Copyright (c) 2013年 EATis. All rights reserved.
//

#import "Location.h"
#import "HTTPCliant.h"

@interface Location ()
@property (readwrite, nonatomic, copy) NSString *locationName;
@property (readwrite, nonatomic, copy) NSString *address;

@property (readwrite, nonatomic, strong) HTTPCliant *httpCliant;
@end

@implementation Location

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.locationName = [attributes valueForKeyPath:@"Name"];
    NSLog(@"JSON:%@",self.locationName);
    
    return self;
}

@end

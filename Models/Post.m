//
//  Post.m
//  kokodoko
//
//  Created by EATis on 2013/10/29.
//  Copyright (c) 2013年 EATis. All rights reserved.
//

#import "Post.h"
#import "Location.h"

#import "AFHTTPRequestOperation.h"
#import "HTTPCliant.h"

#import <MRProgressOverlayView.h>


@implementation Post

- (instancetype)initWithAttributesLocation:(NSArray *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    //都道府県, 市区町村, 町大字, 町丁目（存在すれば）の配列です。
    self.location = [attributes valueForKey:@"Address"];
    
    NSArray *myAttributes = [attributes valueForKeyPath:@"Result"];
    NSMutableArray *myLocationData = [NSMutableArray arrayWithCapacity:[myAttributes count]];
    NSLog(@"count:%d",[myAttributes count]);
    self.locationdata = myLocationData;
    for (NSDictionary *location in myAttributes) {
        
        Location *myLocation = [[Location alloc] initWithAttributes:location];
        [self.locationdata addObject:myLocation];
    }
    
    return self;
}

- (instancetype)initWithAttributesAddress:(NSArray *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    //都道府県, 市区町村, 町大字, 町丁目（存在すれば）の配列です。
    self.address = [attributes valueForKey:@"Address"];
    //NSLog(@"address:%@",[_address observationInfo]);
    
    return self;
}


#pragma mark -

+ (NSURLSessionDataTask *)locationCode:(CLLocation *)locationCode withProgressView:(MRProgressOverlayView *)myProgressView globalTimelinePostsWithBlock:(void (^)(NSArray *posts, NSError *error))block {
    //NSString *lat = @"35.004942482369955";
    NSString *lat = [NSString stringWithFormat:@"%f",[locationCode coordinate].latitude];
    //NSString *lon = @"135.94014150103175";
    NSString *lon = [NSString stringWithFormat:@"%f",[locationCode coordinate].longitude];
    NSString *appid = [HTTPCliant sharedClient].APIKey;
    NSString *json = @"json";
    
    NSLog(@"test %@ %@",lat, lon);
    
    //IDとPASSを直接書いているので後で書き直す必要がある
    NSDictionary *params = @{
                           @"lat" : lat,
                           @"lon" : lon,
                           @"appid" : appid,
                           @"output" : json
                           };
    
    return [[HTTPCliant sharedClient] GET:@"/OpenLocalPlatform/V1/reverseGeoCoder" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        //NSArray *postsFromResponse = [[[JSON valueForKeyPath:@"Feature"] valueForKey:@"Property"] valueForKey:@"Address"];
        NSArray *postsFromResponse = [[JSON valueForKeyPath:@"Feature"] valueForKey:@"Property"];
        //NSArray *postsFromResponse = [JSON valueForKeyPath:@"ResultSet"];
        
        
        //NSLog(@"JSON:%@",postsFromResponse);
        
        
        Post *post = [[Post alloc] initWithAttributesAddress:postsFromResponse];
        
        
        
        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
        [mutablePosts addObject:post];
        
        /*
        for (NSDictionary *attributes in postsFromResponse) {
            
            NSLog(@"JSON:%@",attributes);
            
            Post *post = [[Post alloc] initWithAttributes:attributes];
            [mutablePosts addObject:post];
        }
         */
        
        if (block) {
            block([NSArray arrayWithArray:mutablePosts], nil);
        }
        
        
        
        [myProgressView dismiss:YES];
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
        
        [myProgressView dismiss:YES];
        
        NSLog(@"erroe:%@",task);
    }];
}

#pragma mark - MRProgressView ...
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@end

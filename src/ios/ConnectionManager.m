//
//  EventListViewController.m
//  DropIn
//
//  Created by Bhushan Mahajan on 01/02/16.
//  Copyright © 2016 Biz4Solutions. All rights reserved.
//

#import "ConnectionManager.h"

@implementation ConnectionManager 

#pragma mark - Post Method

+(void)callPostMethod:(NSString *)path data:(NSDictionary*)dict localData:(NSMutableDictionary*)localData  completionBlock:(void (^)(BOOL succeeded, id  responseData ,NSString* errorMsg))completionBlock{
    
    NSError *error;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    NSString *headerValue;
    NSMutableDictionary *temp = [localData objectForKey:@"header"];
    for (NSString *key in temp) {
        headerValue = [temp objectForKey:key];
        [request addValue:headerValue forHTTPHeaderField:key];
    }
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(!error)
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completionBlock (YES, result, nil);
        }
        else{
            NSLog(@"Error occured:::%@",error);
            completionBlock (NO, error, nil);
        }
    }];
    
    [postDataTask resume];
}

@end

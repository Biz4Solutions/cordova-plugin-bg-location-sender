//
//  ConnectionManager.h
//  BeachCaddy
//
//  Created by Puneet Mahajan on 20 April 2017
//  Copyright © 2017 Biz4Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ConnectionManager : NSObject<NSURLConnectionDelegate,NSURLSessionDataDelegate>

+(void)callPostMethod:(NSString *)path data:(NSDictionary*)dict localData:(NSMutableDictionary*)localData  completionBlock:(void (^)(BOOL succeeded, id responseData ,NSString* errorMsg))completionBlock;

@end

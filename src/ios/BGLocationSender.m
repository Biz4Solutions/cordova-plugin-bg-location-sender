/********* BGLocationSender.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <CoreLocation/CoreLocation.h>
#import "ConnectionManager.h"
#import "BGLocationSender.h"
#import <UIKit/UIKit.h>
#import "BGLocationSender.h"

@implementation BGLocationSender

+ (instancetype)sharedInstance
{
    static BGLocationSender *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if(self != nil)
    {
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        locationManager.distanceFilter = 50.0;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.activityType = CLActivityTypeOtherNavigation;
        [locationManager requestAlwaysAuthorization];
        // Request always allowed location service authorization.
        // This is done here, so we can display an alert if the user has denied location services previously
        [self checkLocationServiceAutorization];
        
    }
    return self;
}

// Check whether user has accepted the authorization for location
- (void)checkLocationServiceAutorization {
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        // If status is not determined, then we should ask for authorization.
        [locationManager requestAlwaysAuthorization];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        // If authorization has been denied previously, inform the user.
    }
    [locationManager startUpdatingLocation];
}


- (void)start:(CDVInvokedUrlCommand *)command
{
    requestDict = [[NSMutableDictionary alloc] init];
    argumentsData = [[NSMutableDictionary alloc] init];
    callBackID = command.callbackId;
    @try {
        argumentsData = [[command.arguments objectAtIndex:0] mutableCopy];
        if (![argumentsData objectForKey:@"locationSendIntervalTime"])
        {
            [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing locationSendIntervalTime"];
        }
        //-------Send data to Firebase-----------
        else if ([[argumentsData objectForKey:@"storeType"] isEqualToString:@"FIREBASE"]) {
            if (!([argumentsData objectForKey:@"firebaseEmail"]) || (([argumentsData objectForKey:@"firebaseEmail"]) && ([[argumentsData objectForKey:@"firebaseEmail"] isKindOfClass:[NSNull class]] ||
                                                                                                                         [[argumentsData objectForKey:@"firebaseEmail"] isEqual:nil] || [[argumentsData valueForKey:@"firebaseEmail"] isEqualToString:@""])))
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing Firebase Email"];
            }
            else if (!([argumentsData objectForKey:@"firebasePassword"]) || (([argumentsData objectForKey:@"firebasePassword"]) && ([[argumentsData objectForKey:@"firebasePassword"] isKindOfClass:[NSNull class]] ||
                                                                                                                                    [[argumentsData objectForKey:@"firebasePassword"] isEqual:nil] || [[argumentsData valueForKey:@"firebasePassword"] isEqualToString:@""])))
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing Firebase Password"];
            }
            else if (!([argumentsData objectForKey:@"firebaseDBName"]) || (([argumentsData objectForKey:@"firebaseDBName"]) && ([[argumentsData objectForKey:@"firebaseDBName"] isKindOfClass:[NSNull class]] ||
                                                                                                                                [[argumentsData objectForKey:@"firebaseDBName"] isEqual:nil] || [[argumentsData valueForKey:@"firebaseDBName"] isEqualToString:@""])))
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing Firebase DB Refrance Name"];
            }
            else if (!([argumentsData objectForKey:@"firebaseDBKey"]) || (([argumentsData objectForKey:@"firebaseDBKey"]) && ([[argumentsData objectForKey:@"firebaseDBKey"] isKindOfClass:[NSNull class]] ||
                                                                                                                              [[argumentsData objectForKey:@"firebaseDBKey"] isEqual:nil] || [[argumentsData valueForKey:@"firebaseDBKey"] isEqualToString:@""])))
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing Firebase DB Refrance Key"];
            } else {
                //SignIn to firebase by provided email and password.
                
                [[FIRAuth auth] signInWithEmail:[argumentsData objectForKey:@"firebaseEmail"]
                                       password:[argumentsData objectForKey:@"firebasePassword"]
                                     completion:^(FIRUser * _Nullable __strong authResult, NSError * _Nullable __strong error) {
                                         if ( error == nil) {
                                             FIRUser *user = [FIRAuth auth].currentUser;
                                             if (user) {
                                                 NSMutableDictionary *requestSuccessDict = [[NSMutableDictionary alloc]init];
                                                 [requestSuccessDict setObject:@"BGLocationSender started successfully" forKey:@"message"];
                                                 CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:requestSuccessDict];
                                                 [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
                                                 [self.commandDelegate sendPluginResult:pluginResult callbackId:callBackID];
                                                 ref = [[FIRDatabase database] reference];
                                                 [self initLocationManager];
                                             }
                                         } else {
                                             //SignUp to firebase by provided email and password.
                                             [[FIRAuth auth] createUserWithEmail:[argumentsData objectForKey:@"firebaseEmail"]
                                                                        password:[argumentsData objectForKey:@"firebasePassword"]
                                                                      completion:^(FIRUser * _Nullable __strong authResult, NSError * _Nullable __strong error) {
                                                                          if ( error == nil) {
                                                                              FIRUser *user = [FIRAuth auth].currentUser;
                                                                              if (user) {
                                                                                  NSMutableDictionary *requestSuccessDict = [[NSMutableDictionary alloc]init];
                                                                                  [requestSuccessDict setObject:@"BGLocationSender started successfully" forKey:@"message"];
                                                                                  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:requestSuccessDict];
                                                                                  [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
                                                                                  [self.commandDelegate sendPluginResult:pluginResult callbackId:callBackID];                                                                             ref = [[FIRDatabase database] reference];
                                                                                  [self initLocationManager];
                                                                              }
                                                                          } else {
                                                                              [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Firebase authentication failed."];
                                                                          }
                                                                      }];
                                         }
                                     }];
            }
            //-------Send data to backend server-----------
            
        } else if ([[argumentsData objectForKey:@"storeType"] isEqualToString:@"BACKEND"]) {
            if ( ([[argumentsData objectForKey:@"url"] isKindOfClass:[NSNull class]] ||
                  [[argumentsData objectForKey:@"url"] isEqual:nil] ||
                  [[argumentsData objectForKey:@"url"] isEqualToString:@""]))
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing URL"];
            }
            else if ( [[argumentsData objectForKey:@"methodType"] isKindOfClass:[NSNull class]] ||
                     [[argumentsData objectForKey:@"methodType"] isEqual:nil] ||
                     [[argumentsData objectForKey:@"methodType"] isEqualToString:@""])
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing methodType"];
            }
            else
            {
                NSMutableDictionary *requestSuccessDict = [[NSMutableDictionary alloc]init];
                [requestSuccessDict setObject:@"BGLocationSender started successfully" forKey:@"message"];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:requestSuccessDict];
                [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callBackID];
                [self initLocationManager];
            }
            //-------Send data to frontend server-----------
        } else {
            NSMutableDictionary *requestSuccessDict = [[NSMutableDictionary alloc]init];
            [requestSuccessDict setObject:@"BGLocationSender started successfully" forKey:@"message"];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:requestSuccessDict];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callBackID];
            [self initLocationManager];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@",exception.reason);
    }
}
-(void) sendResponse : (CDVCommandStatus) statusMsg messageString: (NSString*)messageString {
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:statusMsg messageAsString:messageString];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callBackID];
}
- (void) initLocationManager {
    
    @try {
        // Create the location manager if this object does not
        // already have one.
        
        if (nil == locationManager)
            locationManager = [[CLLocationManager alloc] init];
        
        locationManager.delegate = self;
        locationManager.distanceFilter = 50.0;
        [locationManager setAllowsBackgroundLocationUpdates:YES];
        [locationManager requestAlwaysAuthorization];
        [locationManager startUpdatingLocation];
    }
    @catch (NSException *exception) {
        NSLog(@"Could not create location manager object");
    }
}

- (void)restartMonitoringLocation{
    [locationManager stopMonitoringSignificantLocationChanges];
    [locationManager requestAlwaysAuthorization];
    [locationManager startMonitoringSignificantLocationChanges];
}

// Start updating location
- (void)startMonitoringLocation {
    
    if (locationManager)
        [locationManager stopMonitoringSignificantLocationChanges];
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 50.0;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.activityType = CLActivityTypeOtherNavigation;
    [locationManager requestAlwaysAuthorization];
    
    // if app in background then use significant changes.
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground)
    {
        //Do checking here.
        [locationManager startMonitoringSignificantLocationChanges];
    }
    else if (state == UIApplicationStateActive){
        // if app in foreground then use significant changes.
        [locationManager startUpdatingLocation];
    }
}


// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    
    // Get the current location from locationManager object
    latitute = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    if([[argumentsData allKeys] count] > 0)
    {
        // Set 'lat', 'long' to the Dictionary object in which you want to pass
        [requestDict setObject:latitute forKey:@"latitude"];
        [requestDict setObject:longitude forKey:@"longitude"];
        if ([argumentsData count]) {
            //-------Send data to firebase server-----------
            if ([[argumentsData objectForKey:@"storeType"] isEqualToString:@"FIREBASE"]) {
                if ((![[requestDict objectForKey:@"latitude"] isKindOfClass:[NSNull class]] || ![[requestDict objectForKey:@"latitude"] isEqual:nil])) {
                    if ([argumentsData objectForKey:@"params"]) {
                        NSMutableDictionary *requestFirebaseDict = [[NSMutableDictionary alloc]init];
                        [requestFirebaseDict addEntriesFromDictionary:[argumentsData objectForKey:@"params"]];
                        [requestFirebaseDict setObject:latitute forKey:@"latitude"];
                        [requestFirebaseDict setObject:longitude forKey:@"longitude"];
                        [[[ref child:[argumentsData objectForKey:@"firebaseDBName"]] child:[argumentsData objectForKey:@"firebaseDBKey"]]
                         setValue:requestFirebaseDict];
                    } else {
                        NSMutableDictionary *requestFirebaseDict = [[NSMutableDictionary alloc]init];
                        [requestFirebaseDict setObject:latitute forKey:@"latitude"];
                        [requestFirebaseDict setObject:longitude forKey:@"longitude"];
                        [[[ref child:[argumentsData objectForKey:@"firebaseDBName"]] child:[argumentsData objectForKey:@"firebaseDBKey"]]
                         setValue:requestFirebaseDict];
                    }
                } else {
                    [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Location not found"];
                }
                //-------Send data to BACKEND server-----------
            } else if([[argumentsData objectForKey:@"storeType"] isEqualToString:@"BACKEND"]){
                if ((![[argumentsData objectForKey:@"params"] isKindOfClass:[NSNull class]] || ![[argumentsData objectForKey:@"params"] isEqual:nil])) {
                    [requestDict addEntriesFromDictionary:[argumentsData objectForKey:@"params"]];
                }
                if ([[argumentsData objectForKey:@"methodType"] caseInsensitiveCompare:@"post"] == NSOrderedSame) {
                    //You can pass data through post method
                    if ( (![[argumentsData objectForKey:@"url"] isKindOfClass:[NSNull class]] ||
                          ![[argumentsData objectForKey:@"url"] isEqual:nil] ||
                          ![[argumentsData objectForKey:@"url"] isEqualToString:@""])){
                        [self postMethod:requestDict];
                    }
                }
                else if ([[argumentsData objectForKey:@"methodType"] caseInsensitiveCompare:@"get"] == NSOrderedSame) {
                    //You can pass data through get method
                }
                else if ([[argumentsData objectForKey:@"methodType"] caseInsensitiveCompare:@"put"] == NSOrderedSame) {
                    //You can pass data through put method
                }
            }
            //-------Save data to frontend server-----------
            else {
                if ((![[requestDict objectForKey:@"latitude"] isKindOfClass:[NSNull class]] || ![[requestDict objectForKey:@"latitude"] isEqual:nil])) {
                    CDVPluginResult* pluginResult;
                    requestLocationDict = [[NSMutableDictionary alloc]init];
                    [requestLocationDict setObject:latitute forKey:@"latitude"];
                    [requestLocationDict setObject:longitude forKey:@"longitude"];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:requestLocationDict];
                    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:callBackID];
                } else {
                    [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Location not found"];
                }
            }
        }
    }
}

// If you don't get current location, then this delegate method will call
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Couldn't not get location: %@",error);
    [locationManager startUpdatingLocation];
    
}

#pragma mark -
#pragma mark Send or get data to server.
#pragma mark -

-(void)postMethod:(NSMutableDictionary*)data {
    NSLog(@"URL:::: %@",[NSString stringWithFormat:@"%@",[argumentsData objectForKey:@"url"]]);
    [ConnectionManager callPostMethod:[NSString stringWithFormat:@"%@",[argumentsData objectForKey:@"url"]] data:data localData:argumentsData completionBlock:^(BOOL succeeded, id responseData, NSString *errorMsg)
     {
         if(succeeded)
         {
         }
         else{
             NSLog(@"Error: %@",errorMsg);
         }
     }];
}

// Method to stop updating location
- (void)stop:(CDVInvokedUrlCommand*)command{
    @try {
        [locationManager stopMonitoringSignificantLocationChanges];
        [locationManager stopUpdatingLocation];
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@",exception.reason);
    }
    
}

// Method to update parameter's for caddy's location
- (void)updateParams:(CDVInvokedUrlCommand*)command{
    NSMutableDictionary *getArgumentsData = [[NSMutableDictionary alloc] init];
    @try {
        getArgumentsData = [[command.arguments objectAtIndex:0] mutableCopy];
        if (![getArgumentsData objectForKey:@"locationSendIntervalTime"])
        {
            [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing locationSendIntervalTime"];
        }
        //-------Send data to Firebase-----------
        else if ([[getArgumentsData objectForKey:@"storeType"] isEqualToString:@"FIREBASE"]) {
            if (!([getArgumentsData objectForKey:@"firebaseEmail"]) || (([getArgumentsData objectForKey:@"firebaseEmail"]) && ([[getArgumentsData objectForKey:@"firebaseEmail"] isKindOfClass:[NSNull class]] ||
                                                                                                                               [[getArgumentsData objectForKey:@"firebaseEmail"] isEqual:nil] || [[getArgumentsData valueForKey:@"firebaseEmail"] isEqualToString:@""])))
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing Firebase Email"];
            }
            else if (!([getArgumentsData objectForKey:@"firebasePassword"]) || (([getArgumentsData objectForKey:@"firebasePassword"]) && ([[getArgumentsData objectForKey:@"firebasePassword"] isKindOfClass:[NSNull class]] ||
                                                                                                                                          [[getArgumentsData objectForKey:@"firebasePassword"] isEqual:nil] || [[getArgumentsData valueForKey:@"firebasePassword"] isEqualToString:@""])))
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing Firebase Password"];
            }
            else if (!([getArgumentsData objectForKey:@"firebaseDBName"]) || (([getArgumentsData objectForKey:@"firebaseDBName"]) && ([[getArgumentsData objectForKey:@"firebaseDBName"] isKindOfClass:[NSNull class]] ||
                                                                                                                                      [[getArgumentsData objectForKey:@"firebaseDBName"] isEqual:nil] || [[getArgumentsData valueForKey:@"firebaseDBName"] isEqualToString:@""])))
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing Firebase DB Refrance Name"];
            }
            else if (!([getArgumentsData objectForKey:@"firebaseDBKey"]) || (([getArgumentsData objectForKey:@"firebaseDBKey"]) && ([[getArgumentsData objectForKey:@"firebaseDBKey"] isKindOfClass:[NSNull class]] ||
                                                                                                                                    [[getArgumentsData objectForKey:@"firebaseDBKey"] isEqual:nil] || [[getArgumentsData valueForKey:@"firebaseDBKey"] isEqualToString:@""])))
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing Firebase DB Refrance Key"];
            } else {
                argumentsData = [[command.arguments objectAtIndex:0] mutableCopy];
                NSMutableDictionary *requestSuccessDict = [[NSMutableDictionary alloc]init];
                [requestSuccessDict setObject:@"BGLocationSender updated successfully" forKey:@"message"];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:requestSuccessDict];
                [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callBackID];
            }
            //-------Send data to backend server-----------
            
        } else if ([[getArgumentsData objectForKey:@"storeType"] isEqualToString:@"BACKEND"]) {
            if ( ([[getArgumentsData objectForKey:@"url"] isKindOfClass:[NSNull class]] ||
                  [[getArgumentsData objectForKey:@"url"] isEqual:nil] ||
                  [[getArgumentsData objectForKey:@"url"] isEqualToString:@""]))
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing URL"];
            }
            else if ( [[getArgumentsData objectForKey:@"methodType"] isKindOfClass:[NSNull class]] ||
                     [[getArgumentsData objectForKey:@"methodType"] isEqual:nil] ||
                     [[getArgumentsData objectForKey:@"methodType"] isEqualToString:@""])
            {
                [self sendResponse : CDVCommandStatus_ERROR  messageString: @"Missing methodType"];
            }
            else
            {
                argumentsData = [[command.arguments objectAtIndex:0] mutableCopy];
                NSMutableDictionary *requestSuccessDict = [[NSMutableDictionary alloc]init];
                [requestSuccessDict setObject:@"BGLocationSender updated successfully" forKey:@"message"];
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:requestSuccessDict];
                [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:callBackID];
            }
            //-------Send data to frontend server-----------
        } else {
            argumentsData = [[command.arguments objectAtIndex:0] mutableCopy];
            NSMutableDictionary *requestSuccessDict = [[NSMutableDictionary alloc]init];
            [requestSuccessDict setObject:@"BGLocationSender updated successfully" forKey:@"message"];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:requestSuccessDict];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callBackID];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@",exception.reason);
    }
}


// Method to get user's current location, called by hybrid only.
- (void) getLocation:(CDVInvokedUrlCommand*)command{
    getLocation = YES;
    requestDict = [[NSMutableDictionary alloc] init];
    callBackID = command.callbackId;
    if(locationManager == nil)
    {
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.activityType = CLActivityTypeOtherNavigation;
        [locationManager requestAlwaysAuthorization];
    }
    
    // if app is in background then use significant changes.
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    //Do checking here.
    if (state == UIApplicationStateBackground)
    {
        [locationManager startMonitoringSignificantLocationChanges];
    }
    else if (state == UIApplicationStateActive){
        [locationManager startUpdatingLocation];
    }
    
}

@end





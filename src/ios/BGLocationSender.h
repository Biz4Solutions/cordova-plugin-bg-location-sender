/********* BGLocationSender.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <CoreLocation/CoreLocation.h>
#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegateImpl.h>
#import <Cordova/CDVCommandQueue.h>
#import "ConnectionManager.h"
#import "Firebase.h"
@import FirebaseAuth;
@import FirebaseDatabase;

@interface BGLocationSender : CDVPlugin <CLLocationManagerDelegate>{
    CLLocationManager *locationManager; // Create variable for LocationManager to get the latitude and longitude
    NSString *latitute, *longitude; // Capture the latitude and logitude
    NSMutableDictionary *argumentsData; //  Capture the data from hybrid to this 'argumentsData'
    NSMutableDictionary *requestDict; //  Data that we need to pass to the server
    NSString* callBackID; //  Call back ID from which the call comes, and we need to give call back to the same ID
    BOOL getLocation; //  Flag just to know whether getLocation method called or not from hybrid.
    NSMutableDictionary *paramDict;
    NSString *getUserId;
    int trip_request_status;
    FIRDatabaseReference *ref;
    NSMutableDictionary *requestLocationDict; //  Data that we need to pass to the server
}

+ (instancetype)sharedInstance; // Create instance for class
- (void)restartMonitoringLocation; // If app goes in background then restart the service for updating location
- (void)startMonitoringLocation; // Start updating location

- (void)start:(CDVInvokedUrlCommand*)command; // Called from hybrid when caddy is in working state
- (void)stop:(CDVInvokedUrlCommand*)command; // just to stop the running user's updating location
- (void)updateParams:(CDVInvokedUrlCommand*)command; // update caddy's location
- (void)getLocation:(CDVInvokedUrlCommand*)command; // used to get the user's current location and send it to the

@end

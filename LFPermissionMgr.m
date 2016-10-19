//
//  LFPermissionMgr.m
//  Permissions
//
//  Created by la0fu on 16/10/19.
//  Copyright © 2016年 la0fu. All rights reserved.
//

#import "LFPermissionMgr.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <EventKit/EventKit.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_OS_9_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IS_OS_10_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)

@interface LFPermissionMgr ()  <CLLocationManagerDelegate>

@property (copy, nonatomic) LocationHandler locationBlock;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) CNContactStore *contactStore;

@end

@implementation LFPermissionMgr

+ (LFPermissionMgr *)sharedInstance
{
    static LFPermissionMgr *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LFPermissionMgr alloc] init];
    });
    return sharedInstance;
}

- (void)accessCamera:(void (^)(BOOL granted))handler
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusNotDetermined){ 
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            handler(granted);
        }];
    } else if (authStatus == AVAuthorizationStatusAuthorized) {
        handler(YES);
    } else {
        handler(NO);
    }
}

- (void)accessMic:(void (^)(BOOL granted))handler
{
    AVAudioSessionRecordPermission micPermisson = [[AVAudioSession sharedInstance] recordPermission];
    
    if (micPermisson == AVAudioSessionRecordPermissionUndetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            handler(granted);
        }];
    } else if (micPermisson == AVAudioSessionRecordPermissionGranted) {
        handler(YES);
    } else {
        handler(NO);
    }
}

- (void)accessPhoto:(void (^)(BOOL granted))handler
{
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
    
    if (photoStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                handler(YES);
            } else {
                handler(NO);
            }
        }];
    } else if (photoStatus == PHAuthorizationStatusAuthorized) {
        handler(YES);
    } else {
        handler(NO);
    }
}

/**
 
 NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription should be provided in Info.plist since iOS 8
 
 */

- (void)accessLocation:(LocationAuthorizedType)authorizedType handler:(LocationHandler)handlr
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
        }
        
        self.locationBlock = handlr;
        
        if (authorizedType == LocationAuthorizedAlways) {
            [self.locationManager requestAlwaysAuthorization];
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
    } else if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse){
        handlr(YES, nil);
    } else {
        handlr(NO, nil);
    }
}

/**
 An iOS app linked on or after iOS 10.0 must include in its Info.plist file the usage description keys for the types of data it needs to access or it will crash. To access Reminders and Calendar data specifically, it must include NSRemindersUsageDescription and NSCalendarsUsageDescription, respectively.
 */

- (void)accessEvent:(EventAuthorizedType)eventType handler:(void (^)(BOOL granted))handler
{
    EKEntityType type = eventType == EventAuthorizedCalendar ? EKEntityTypeEvent : EKEntityTypeReminder;
    
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:type];
    if (status == EKAuthorizationStatusNotDetermined) {
        if (!self.eventStore) {
            self.eventStore = [[EKEventStore alloc] init];
        }
        [self.eventStore requestAccessToEntityType:type completion:^(BOOL granted, NSError * _Nullable error) {
            handler(granted);
        }];
    } else if (status == EKAuthorizationStatusAuthorized) {
        handler(YES);
    } else {
        handler(NO);
    }
}

- (void)accessContacts:(void (^)(BOOL granted))handler
{
    if (IS_OS_9_OR_LATER) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];

        if (status == CNAuthorizationStatusNotDetermined) {
            self.contactStore = [[CNContactStore alloc] init];
            [_contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                handler(granted);
            }];
        } else if (status == CNAuthorizationStatusAuthorized) {
            handler(YES);
        } else {
            handler(NO);
        }
    } else {  //iOS 8 and below
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
            
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
                 handler(granted);
                 CFRelease(addressBook);
             });
        } else if (status == kABAuthorizationStatusAuthorized) {
            handler(YES);
        } else {
            handler(NO);
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    _locationBlock(YES, nil);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{    
    _locationBlock(YES, newLocation);
    
    [self stopLocationService];
}

- (void)stopLocationService
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate=nil;
    self.locationManager = nil;
}

@end

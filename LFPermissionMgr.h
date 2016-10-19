//
//  LFPermissionMgr.h
//  Permissions
//
//  Created by la0fu on 16/10/19.
//  Copyright © 2016年 la0fu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, LocationAuthorizedType) {
    LocationAuthorizedAlways,
    LocationAuthorizedWhenInUse
};

typedef NS_ENUM(NSInteger, EventAuthorizedType) {
    EventAuthorizedCalendar,
    EventAuthorizedReminder
};


typedef void (^LocationHandler) (BOOL granted, CLLocation *location);

@interface LFPermissionMgr : NSObject

+ (LFPermissionMgr *)sharedInstance;
- (void)accessCamera:(void (^)(BOOL granted))handler;
- (void)accessMic:(void (^)(BOOL granted))handler;
- (void)accessPhoto:(void (^)(BOOL granted))handler;
- (void)accessLocation:(LocationAuthorizedType)authorizedType handler:(LocationHandler)handlr;
- (void)accessEvent:(EventAuthorizedType)eventType handler:(void (^)(BOOL granted))handler;
- (void)accessContacts:(void (^)(BOOL granted))handler;

@end

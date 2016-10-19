# LFPermissionMgr

##统一管理iOS权限获取##

支持相机、麦克风、相册、地理位置、日历、提醒事项(Reminder)以及联系人权限获取。

使用方法(支持**iOS8+**)：

获取麦克风:

````
[[LFPermissionMgr sharedInstance] accessMic:^(BOOL granted) {
        if (granted) {
            NSLog(@"mic access granted");
        } else {
            NSLog(@"mic access not granted");
        }
}];
````
获取相机

````
[[LFPermissionMgr sharedInstance] accessCamera:^(BOOL granted) {
        if (granted) {
            NSLog(@"camera access granted");
        } else {
            NSLog(@"camera access not granted");
        }
}];
````

获取相册

````
[[LFPermissionMgr sharedInstance] accessPhoto:^(BOOL granted) {
        if (granted) {
            NSLog(@"photo access granted");
        } else {
            NSLog(@"photo access not granted");
        }
}];
````

获取地理位置

````
[[LFPermissionMgr sharedInstance] accessLocation:LocationAuthorizedAlways handler:^(BOOL granted, CLLocation *location) {
        if (granted) {
            NSLog(@"location access granted:[%f,%f]", location.coordinate.latitude, location.coordinate.longitude);
        }
}];
````

获取日历

````
[[LFPermissionMgr sharedInstance] accessEvent:EventAuthorizedCalendar handler:^(BOOL granted) {
        if (granted) {
            NSLog(@"calendar access granted");
        } else {
            NSLog(@"calendar access not granted");
        }
}];
````
获取Reminder

````
[[LFPermissionMgr sharedInstance] accessEvent:EventAuthorizedReminder handler:^(BOOL granted) {
        if (granted) {
            NSLog(@"reminder access granted");
        } else {
            NSLog(@"reminder access not granted");
        }
}];

````

获取联系人

````
[[LFPermissionMgr sharedInstance] accessContacts:^(BOOL granted) {
        if (granted) {
            NSLog(@"contacts access granted");
        } else {
            NSLog(@"contacts access not granted");
        }
}];

````

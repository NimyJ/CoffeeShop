//
//  DownloadManager.h
//  NimyJ_CoffeeApp
//
//  Created by Nimy on 13/04/2016.
//  Copyright © 2016 Nimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DownloadManager : NSObject <CLLocationManagerDelegate>

extern NSString *const dataDownloadSuccessPostNotificationName;
@property NSArray *venueArray;

//Returns a singleton/shared object 
+ (DownloadManager*)getSharedObject;

/*This will do the following
 1. Configure the RestKit
 2. Start locationUpdate (get location info every 10 seconds)
    2.A. With every such location update, start venue data (JSON) download from Foursquare server
    2.B. Map the JSON data to objects using RestKit and store them in the property "venueArray"
    2.C. Send a notification when there is a successfull data download, ViewControllers registered with notification center will receive this notification and can update their UI when they recieve a new notification (It can use the data stored in the property "venueArray"). Currently only ShopListViewController uses this approach to refresh UI
 */
- (void)configureRestKitAndStartUpdatingLocation;
@end


//
//  AppDelegate.m
//  NimyJ_CoffeeApp
//
//  Created by Nimy on 13/04/2016.
//  Copyright © 2016 Nimy. All rights reserved.
//

#import "AppDelegate.h"
#import <RestKit/RestKit.h>
#import "DownloadManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor brownColor ], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue" size:17], NSFontAttributeName, nil]];

    //Get the download manager
    DownloadManager *downloadManager = [DownloadManager getSharedObject];
    
    /*This will do the following
    1. Configure the RestKit
    2. Start locationUpdate (get location info every 10 seconds)
        2.A. With every such location update, start venue data (JSON) download from Foursquare server
        2.B. Map the JSON data to objects using RestKit and store them in the property "venueArray"
        2.C. Send a notification when there is a successfull data download, ViewControllers registered with notification center will receive this notification and can update their UI when they recieve a new notification (It can use the data stored in the property "venueArray"). Currently only ShopListViewController uses this approach to refresh UI
    */
    [downloadManager configureRestKitAndStartUpdatingLocation];
    
    return YES;

}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    //Nothing to handle here, the location update will start automatically when app is active
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


@end

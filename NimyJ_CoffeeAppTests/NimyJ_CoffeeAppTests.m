//
//  NimyJ_CoffeeAppTests.m
//  NimyJ_CoffeeAppTests
//
//  Created by Nimy on 13/04/2016.
//  Copyright © 2016 Nimy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DownloadManager.h"

@interface NimyJ_CoffeeAppTests : XCTestCase

@end

@implementation NimyJ_CoffeeAppTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}


/* Get the venueArray without configuring the Manager 
    That is without configuring the RestKit, starting locationUpdate and the data download from REST server
 */
- (void)testDataBeforeConfiguration {
    
    //Get the download manager
    DownloadManager * downloadManager = [DownloadManager getSharedObject];
    NSArray * array =  downloadManager.venueArray;
    
    //Array must be nil
    XCTAssertNil(array);
}


/* Get the venueArray after configuring the Manager, This will do the following
    1. Configure the RestKit
    2. Start locationUpdate (get location info every 10 seconds)
    3. Start venue data (JSON) download from Foursquare server with the updated location
    4. Send a notification when there is a successfull data download
 
 We will check whether there is a notification (proof that all other steps were successful) and then test the data array and count of venues
 */
- (void)testRestKitConfigurationPlusLocationUpdateAndDataDownload {

    //To observe notification
    [self expectationForNotification:dataDownloadSuccessPostNotificationName object:nil handler:nil];
 
    //Get the downloadManager & call configure function
    DownloadManager * downloadManager = [DownloadManager getSharedObject];
    [downloadManager configureRestKitAndStartUpdatingLocation];
  
    //Wait for 30 seconds for all 4 steps (mentioned above) to complete, and to receive the notification
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error after waiting for dataDownloadSuccess notification: %@", error);
        }
    }];
    
    //Get the data array
    NSArray * array =  downloadManager.venueArray;
    NSLog(@"Downloaded venue count = %lu",(unsigned long)array.count);

    //Check the array & count
    XCTAssertNotNil(array);
    XCTAssertTrue(array.count > 0);
}


// testing the call to get the singleton/shared download manager object

-(void)testDownloadManagerGetSharedObjectCall{
    
    DownloadManager *downloadManager;
    
    XCTAssertNil(downloadManager);
    
    downloadManager = [DownloadManager getSharedObject];
    
    XCTAssertNotNil(downloadManager);
    
}



@end

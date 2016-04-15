//
//  DownloadManager.m
//  NimyJ_CoffeeApp
//
//  Created by Nimy on 13/04/2016.
//  Copyright © 2016 Nimy. All rights reserved.
//

#import "DownloadManager.h"
#import <RestKit/RestKit.h>
#import "Venue.h"
#import "VenueLocation.h"
#import "VenueContact.h"


#define fourSquareClientId @"ACAO2JPKM1MXHQJCK45IIFKRFR2ZVL0QASMCBCG5NPJQWF2G"
#define fourSquareClientSecret @"YZCKUYJ1WHUV2QICBXUBEILZI1DMPUIDP5SHV043O04FKBHL"


@implementation DownloadManager

NSDate *lastDownloadDateStamp;
NSString *const dataDownloadSuccessPostNotificationName = @"dataDownloadSuccessPostNotificationName";

CLLocationManager *locationManager;


//Returns a singleton/shared object
+ (DownloadManager*)getSharedObject {

    static DownloadManager *sharedObject = nil;
    @synchronized(self) {
        if (sharedObject == nil){
            sharedObject = [[self alloc] init];
        }
    }
    return sharedObject;
}


/*This will do the following
 1. Configure the RestKit
 2. Start locationUpdate (get location info every 10 seconds)
    2.A. With every such location update, start venue data (JSON) download from Foursquare server
    2.B. Map the JSON data to objects using RestKit and store them in the property "venueArray"
    2.C. Send a notification when there is a successfull data download, ViewControllers registered with notification center will receive this notification and can update their UI when they recieve a new notification (It can use the data stored in the property "venueArray"). Currently only ShopListViewController uses this approach to refresh UI
 */
-(void) configureRestKitAndStartUpdatingLocation{
    [self configureRestKit];
    [self startUpdatingLocation];
}


//Setup CLLocationManager
- (void)startUpdatingLocation
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager){
        locationManager = [[CLLocationManager alloc] init];
    }
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 50;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation* location = [locations lastObject];
    NSDate* timestamp = location.timestamp;
    
    NSTimeInterval locationTimeIntervalSinceNow = [timestamp timeIntervalSinceNow];
    NSLog(@"DownloadManager > Time Interval Since Last Download = %f ", (-[lastDownloadDateStamp timeIntervalSinceNow]));
    
    //Procede only if it is a recent location data, that is less than 20 seconds
    //AND
    //Also added another check to ignore calls that happens with in 9 seconds of the last download (it will be nil for the first time)
    if ((fabs(locationTimeIntervalSinceNow) < 20.0) && ((-[lastDownloadDateStamp timeIntervalSinceNow]) > 9 || lastDownloadDateStamp == nil )) {
        
        //Stop updating for saving power
        [locationManager stopUpdatingLocation];
        
        //Timer to re-start the update after 10 seconds
        [NSTimer scheduledTimerWithTimeInterval:10
                                         target:locationManager
                                       selector:@selector(startUpdatingLocation)
                                       userInfo:nil
                                        repeats:NO];
        
        NSString * latitude = [[NSString alloc] initWithFormat:@"%g", location.coordinate.latitude];
        NSString * longitude = [[NSString alloc] initWithFormat:@"%g", location.coordinate.longitude];
        NSLog(@"DownloadManager > 📡 got new location %@, %@",latitude,longitude );
        
        lastDownloadDateStamp = [[NSDate alloc]init];
        
        //Now try downloading the venues for this new location
        [self downloadVenuesWithLatitude:latitude andLongitude:longitude];
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"DownloadManager > locationManager - didFailWithError: %@", error);
}

//Handle location access changes or when access denied
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"This app requires location access, To use this app you must turn this ON in the Location Services Settings"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
            [alert show];
        }
            break;
        default:{
            [locationManager startUpdatingLocation];
        }
            break;
    }
}

//To open the Settings for this app when user clicks on the "Settings" button in the UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {

        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}


#pragma mark - RESTKIT related

/*
 Configure RestKit
 */
- (void)configureRestKit
{
    
    NSURL *foursquareBaseURL = [NSURL URLWithString:@"https://api.foursquare.com"];
    
    // Create HTTPClient with foursquareBaseURL
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:foursquareBaseURL];
    
    // Create RKObjectManager with the HTTPClient
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // JSON to object - attribute mapping for Venue Class
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]];
    NSDictionary * venuMappingDict = @{@"name" : @"venueName",
                                       @"id" : @"venueId",
                                       @"url" : @"venueUrl"};
    [venueMapping addAttributeMappingsFromDictionary:venuMappingDict];
    
    // Create response descriptor
    RKResponseDescriptor *responseDescriptor =[RKResponseDescriptor responseDescriptorWithMapping:venueMapping
                                                                                           method:RKRequestMethodGET
                                                                                      pathPattern:@"/v2/venues/search"
                                                                                          keyPath:@"response.venues"
                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    
    //  JSON to object - attribute mapping for VenueLocation Class
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[VenueLocation class]];
    NSDictionary * venulocationMappingDict = @{@"address" : @"address",
                                               @"lat" : @"latitude",
                                               @"lng" : @"longitude",
                                               @"distance" : @"distance",
                                               @"postalCode" : @"postalCode",
                                               @"city" : @"city",
                                               @"state" : @"state",
                                               @"country" : @"country"
                                               };
    [locationMapping addAttributeMappingsFromDictionary:venulocationMappingDict];
 
    // Relationship
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"venueLocation" withMapping:locationMapping]];
    
    
    // JSON to object - attribute mapping for VenueContact Class
    RKObjectMapping *contactMapping = [RKObjectMapping mappingForClass:[VenueContact class]];
    NSDictionary * contactMappingDict = @{@"phone" : @"phone",
                                          @"formattedPhone" : @"formattedPhone"
                                          };
    [contactMapping addAttributeMappingsFromDictionary:contactMappingDict];
    
    // Relationship
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"contact" toKeyPath:@"venueContact" withMapping:contactMapping]];
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelCritical);
}

/*
 This function will be called whan there is a location update, this will try to download the venues around the location
 If the download is successful, it stores the venue objects in the property "venueArray" (RestKit will map JSON data to objects )
 Also, this will send a notification when there is a successfull data download, ViewControllers registered with notification center will receive this notification and can update their UI when they recieve a new notification (using the data stored in the property "venueArray"). Currently only ShopListViewController uses this approach to refresh UI

 */
- (void)downloadVenuesWithLatitude : (NSString*)latitude andLongitude: (NSString*)longitude
{
    NSString *latitudeAndLongitudeString = [NSString stringWithFormat:@"%@,%@",latitude, longitude ];
    
    
    NSDictionary *queryParams = @{@"ll" : latitudeAndLongitudeString,
                                  @"client_id" : fourSquareClientId,
                                  @"client_secret" : fourSquareClientSecret,
                                  @"query" : @"Coffee",
                                  @"v" : @"20160412"};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/search"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  self.venueArray = mappingResult.array;
                                                  
                                                  //Sort with distance 
                                                  NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"venueLocation.distance" ascending:YES];
                                                  self.venueArray=[self.venueArray sortedArrayUsingDescriptors:@[sort]];
                                                  
                                                  NSLog(@"DownloadManager > Successful download, Broadcasting notification.  Count = %lu",self.venueArray.count);

                                                  // Post notification to inform the observing viewcontroller(s) so that they can update the UI if required, Currently only used by ShopListViewController
                                                  [[NSNotificationCenter defaultCenter] postNotificationName: dataDownloadSuccessPostNotificationName
                                                                                                      object:nil
                                                                                                    userInfo:nil];
                                                  
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"DownloadManager > Error Fetching JSON %@", error);
                                              }];
}


@end


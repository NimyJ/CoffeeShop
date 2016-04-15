//
//  ShopDetailsViewController.m
//  NimyJ_CoffeeApp
//
//  Created by Nimy on 13/04/2016.
//  Copyright © 2016 Nimy. All rights reserved.
//

#import "ShopDetailsViewController.h"
#import <MapKit/MapKit.h>

@interface ShopDetailsViewController ()

@end

@implementation ShopDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self.navigationItem.title = self.selectedVenue.venueName;
    [self populateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) populateUI{
    
    self.name.text = self.selectedVenue.venueName;
    self.distance.text = [NSString stringWithFormat:@"%@ meters from here",self.selectedVenue.venueLocation.distance ];
    
    //Append strings (and replace nil/null with @"")
    self.address.text = [NSString stringWithFormat:@"%@, %@, %@, %@",self.selectedVenue.venueLocation.address ?: @"",self.selectedVenue.venueLocation.city ?: @"", self.selectedVenue.venueLocation.state ?: @"", self.selectedVenue.venueLocation.country ?: @"" ] ;
    self.phone.text = self.selectedVenue.venueContact.formattedPhone;
    
    if (self.selectedVenue.venueUrl) {
        [self.openWebsiteButton setTitle:self.selectedVenue.venueUrl forState:UIControlStateNormal];
    }else{
        self.openWebsiteButton.hidden = true;
    }
    
    //Show the map
    CLLocation *location = [[CLLocation alloc] initWithLatitude: [self.selectedVenue.venueLocation.latitude doubleValue] longitude:[self.selectedVenue.venueLocation.longitude doubleValue]];
    CLLocationCoordinate2D locationCoordinate = location.coordinate;
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(locationCoordinate, 1500, 1000);
    [self.mapView setRegion:coordinateRegion animated:NO];
    
    //Add the point on map
    MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
    point.coordinate = location.coordinate;
    point.title = self.selectedVenue.venueName;
    [self.mapView addAnnotation:point];
}

#pragma mark - Action Handlers

- (IBAction)openWebSite:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.selectedVenue.venueUrl]];
}

- (IBAction)dialPhone:(id)sender {
     NSString *number = [NSString stringWithFormat:@"tel://%@", self.selectedVenue.venueContact.phone];
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]];
}

- (IBAction)openInMaps:(id)sender {

    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([self.selectedVenue.venueLocation.latitude doubleValue], [self.selectedVenue.venueLocation.longitude doubleValue]) addressDictionary:nil] ;
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.selectedVenue.venueName];
    [mapItem openInMapsWithLaunchOptions:nil];
}


@end

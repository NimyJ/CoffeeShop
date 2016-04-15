//
//  ShopDetailsViewController.h
//  NimyJ_CoffeeApp
//
//  Created by Nimy on 13/04/2016.
//  Copyright © 2016 Nimy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Venue.h"
#import <MapKit/MapKit.h>


@interface ShopDetailsViewController : UIViewController

/*
  selectedVenue will be set by ShopListViewController before it opens this ViewController
 */

@property Venue * selectedVenue;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UIButton *dialPhoneButton;
@property (weak, nonatomic) IBOutlet UIButton *viewMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *openWebsiteButton;

@end

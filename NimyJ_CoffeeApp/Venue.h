//
//  Venue.h
//  NimyJ_CoffeeApp
//
//  Created by Nimy on 13/04/2016.
//  Copyright © 2016 Nimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VenueLocation.h"
#import "VenueContact.h"
@interface Venue : NSObject

@property (nonatomic, strong) NSString *venueName;
@property (nonatomic, strong) NSString *venueId;
@property (nonatomic, strong) NSString *venueUrl;
@property VenueLocation *venueLocation;
@property VenueContact *venueContact;

@end

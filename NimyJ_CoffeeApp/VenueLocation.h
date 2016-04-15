//
//  VenueLocation.h
//  NimyJ_CoffeeApp
//
//  Created by Nimy on 13/04/2016.
//  Copyright © 2016 Nimy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VenueLocation : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;

@end









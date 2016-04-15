//
//  ShopListTableViewCell.h
//  NimyJ_CoffeeApp
//
//  Created by Nimy on 13/04/2016.
//  Copyright © 2016 Nimy. All rights reserved.
//

/*
    Custom UITableViewCell used in ShopListViewController
*/

#import <UIKit/UIKit.h>

@interface ShopListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceToShopLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;


@end

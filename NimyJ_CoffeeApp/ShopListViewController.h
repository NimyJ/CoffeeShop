//
//  ShopListViewController.h
//  NimyJ_CoffeeApp
//
//  Created by Nimy on 13/04/2016.
//  Copyright © 2016 Nimy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

extern NSString *const dataDownloadSuccessPostNotificationName;

@property (weak, nonatomic) IBOutlet UITableView *shopListTable;

@end


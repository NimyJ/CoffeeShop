//
//  ShopListViewController.m
//  NimyJ_CoffeeApp
//
//  Created by Nimy on 13/04/2016.
//  Copyright © 2016 Nimy. All rights reserved.
//


/*
 This ViewController depends on notification from DownloadManager to update the UI.
    Note: Observer added in "viewWillAppear"
 */

#import "ShopListViewController.h"
#import "ShopListTableViewCell.h"
#import "Venue.h"
#import "VenueLocation.h"
#import "DownloadManager.h"
#import "ShopDetailsViewController.h"


@interface ShopListViewController ()

@property NSArray *venueArray;

@end

@implementation ShopListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.shopListTable.dataSource = self;
    self.shopListTable.delegate = self;
    
    self.navigationItem.title = @"Coffee shops near you";
    
    //remove extra table row-seperators
    self.shopListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //Add observer to the new Data available notification from DownloadManager
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataAvailable) name:dataDownloadSuccessPostNotificationName object:nil];
    
    //Deselect the selected row when returning from shop details view controller
    NSIndexPath *selectedIndexPath = [self.shopListTable indexPathForSelectedRow];
    if (selectedIndexPath) {
        [self.shopListTable deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
     [super viewWillDisappear:animated];
    
    //Remove observer when its not needed
    [[NSNotificationCenter defaultCenter] removeObserver:self name:dataDownloadSuccessPostNotificationName  object:nil];
      
}



#pragma mark - Notification Observer

-(void)newDataAvailable{
    
    DownloadManager *downloadManager = [DownloadManager getSharedObject];
    self.venueArray = downloadManager.venueArray;
    NSLog(@"ShopListViewController >  😀 New Data Available, Count = %lu, Reloading table now",self.venueArray.count);
    NSLog(@"---------------------------------------------------------------------");
    [self.shopListTable reloadData];
}





#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.venueArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shopListCell" forIndexPath:indexPath];
    
    Venue *myVenue = self.venueArray[indexPath.row];
    cell.shopNameLabel.text = myVenue.venueName;
    cell.distanceToShopLabel.text = [NSString stringWithFormat:@"%@ m", myVenue.venueLocation.distance];
    //Append both strings (and replace nil/null with @"")
    cell.addressLabel.text = [NSString stringWithFormat:@"%@ , %@",myVenue.venueLocation.address ?: @"",myVenue.venueLocation.city  ?: @""] ;
    
    return cell;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70;
}



/*
    Row selected, Navigate to ShopDetailsViewController to show the details
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShopDetailsViewController *shopDetailsViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ShopDetailsViewControllerID"];
   
    //Get the selected Venue object and pass it to the next view controller (ShopDetailsViewController)
    shopDetailsViewController.selectedVenue = self.venueArray[indexPath.row];
  
    [self.navigationController pushViewController:shopDetailsViewController animated:YES];
    
}

@end

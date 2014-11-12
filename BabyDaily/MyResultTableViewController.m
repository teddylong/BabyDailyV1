//
//  MyResultTableViewController.m
//  BabyDaily
//
//  Created by 龙 轶群 on 14-11-11.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "MyResultTableViewController.h"
#import <Realm/Realm.h>
#import "DailyOne.h"
#import "UIImageView+WebCache.h"
#import "DailyDetailViewController.h"

@interface MyResultTableViewController ()

@property (nonatomic, strong) RLMArray *searchArray;
@property (nonatomic, strong) RLMArray *array;
@property (assign, nonatomic) NSInteger selectedRow;
@property (nonatomic, strong) RLMNotificationToken *notification;
@property (nonatomic,strong) NSIndexPath *localPath;

@end

@implementation MyResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.array = [[DailyOne allObjects] arraySortedByProperty:@"CreateDate" ascending:NO];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    //__weak typeof(self) weakSelf = self;
    
//    self.notification = [RLMRealm.defaultRealm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
//        [weakSelf reloadData];
//    }];
    //[self.tableView reloadData];
    
    NSLog(@"%lu",(unsigned long)_array.count);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _searchArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"SearchCell"];
    }
    
    DailyOne *object = [_searchArray objectAtIndex:indexPath.row];
    
    
    NSDate *now2 = object.CreateDate;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    
    comps = [calendar components:unitFlags fromDate:now2];
    NSInteger dailyDate = [comps day];
    NSString *dailyDateString = [NSString stringWithFormat:@"%d",(int)dailyDate];
    
    UILabel* timeLabel = (UILabel *)[cell.contentView viewWithTag:2];
    timeLabel.text = dailyDateString;

    
    UILabel* bodyLabel = (UILabel *)[cell.contentView viewWithTag:3];

    bodyLabel.text = object.Body;
    
    
    UIImageView *viewImage = (UIImageView *)[cell.contentView viewWithTag:1];
    NSString *tempString = [object.Image stringByAppendingString:@"?imageView2/1/w/200/h/200"];
    
    CALayer *layer = [viewImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:5.0f];
    
    [viewImage sd_setImageWithURL:[[NSURL alloc] initWithString: tempString]];
    
    //cell.textLabel.text = object.Body;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _localPath = indexPath;
    return indexPath;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger row = _localPath.row;
    
    DailyDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DailyDetailViewController"];
    detailViewController.daily = [_searchArray objectAtIndex:row];
    
    //NSLog(detailViewController.daily.Body);
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    // note: should not be necessary but current iOS 8.0 bug (seed 4) requires it
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"Body contains %@",searchController.searchBar.text];
    _searchArray = [_array objectsWithPredicate:pred];
    
    [self.tableView reloadData];
}

@end

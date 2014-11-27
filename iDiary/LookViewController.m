//
//  LookViewController.m
//  BabyDaily
//
//  Created by Ctrip on 14/10/28.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "LookViewController.h"
#import "AFNetworking.h"
#import "DailyOne.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "DailyDetailViewController.h"
#import "ProgressHUD.h"

@interface LookViewController ()

@property (nonatomic, strong) NSMutableArray *array;


@property (assign, nonatomic) NSInteger selectedRow;

@end

@implementation LookViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _array = [[NSMutableArray alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [ProgressHUD show:@"Loading..."];
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    [self LoadDailys];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = [indexPath row];
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DailyOne *selectedDaily = [_array objectAtIndex:indexPath.row];
    
    DailyDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DailyDetailViewController"];
    
    detailViewController.daily = selectedDaily;
    
    detailViewController.navigationItem.rightBarButtonItem = nil;
    
    [detailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LookCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"LookCell"];
    }
    
    if(_array.count ==0)
    {}
    else
    {
    
        DailyOne *daily = [_array objectAtIndex:indexPath.row];
    
        
        UILabel* bodyLabel = (UILabel *)[cell.contentView viewWithTag:1];
        bodyLabel.text = daily.Body;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *now2 = daily.CreateDate;
        NSString *tempTime = (NSString *)now2;
        NSDate *now3 = [dateFormatter dateFromString:tempTime];
        
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate: now3];
        NSDate *localeDate = [now3 dateByAddingTimeInterval: interval];
        
        
        NSString *realLocalDate = [dateFormatter stringFromDate:localeDate];

        
        UILabel* dailyDateLabel = (UILabel *)[cell.contentView viewWithTag:2];

        dailyDateLabel.text = realLocalDate;
        //dailyDateLabel.text = dailyDateString;
        
        UILabel *dailyUserLabel =(UILabel *)[cell.contentView viewWithTag:7];
        dailyUserLabel.text = daily.User;

        
        
        UIImageView *viewImage = (UIImageView *)[cell.contentView viewWithTag:100];
        NSString *tempString = [daily.Image stringByAppendingString:@"?imageView2/1/w/200/h/200"];
        CALayer *layer = [viewImage layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:5.0f];
        
        [viewImage sd_setImageWithURL:[[NSURL alloc] initWithString: tempString]];
    }
    
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return _array.count;
    
}

- (void)LoadDailys
{
    
    NSURL *url = [NSURL URLWithString:@"http://teddylong.net/BabyDaily/PostEntity.php"];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        NSLog(@"Success: %@", operation.responseString);
        
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        
        for(int i=0;i<resultDic.count;i++)
        {
            NSDictionary *dailyDetail = [resultDic objectAtIndex:i];
            //NSLog([dailyDetail valueForKey:[NSString stringWithFormat:@"ID"]]);
            DailyOne *daily = [[DailyOne alloc]init];
            daily.Body = [dailyDetail valueForKey:[NSString stringWithFormat:@"Body"]];
            daily.CreateDate = [dailyDetail valueForKey:[NSString stringWithFormat:@"CreateTime"]];
            daily.UpdateDate = [dailyDetail valueForKey:[NSString stringWithFormat:@"UpdateTime"]];
            daily.Image = [dailyDetail valueForKey:[NSString stringWithFormat:@"ImageAddress"]];
            daily.Tag = [dailyDetail valueForKey:[NSString stringWithFormat:@"Tag"]];
            daily.ID = [dailyDetail valueForKey:[NSString stringWithFormat:@"ID"]];
            daily.UDID = [dailyDetail valueForKey:[NSString stringWithFormat:@"UDID"]];
            daily.User = [dailyDetail valueForKey:[NSString stringWithFormat:@"User"]];
            daily.Weather = [dailyDetail valueForKey:[NSString stringWithFormat:@"Weather"]];
            daily.Location = [dailyDetail valueForKey:[NSString stringWithFormat:@"Location"]];
            
            [_array addObject:daily];
            
        }
        [ProgressHUD dismiss];
        [self.tableView reloadData];
     
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Failure: %@", error);
         [ProgressHUD showError:@"Failed"];
         
     }];
    [operation start];
}


- (void)headerRereshing
{
    _array = [[NSMutableArray alloc]init];
    [ProgressHUD show:@"Loading..."];
    [self LoadDailys];
    [self.tableView headerEndRefreshing];
    
}

@end

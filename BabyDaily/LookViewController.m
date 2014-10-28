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

        
        NSDate *now2 = daily.CreateDate;
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        
        UILabel* dailyDateLabel = (UILabel *)[cell.contentView viewWithTag:2];
        dailyDateLabel.text = [format stringFromDate:now2];
        
        
        
        UIImageView *viewImage = (UIImageView *)[cell.contentView viewWithTag:100];
        NSString *tempString = [daily.Image stringByAppendingString:@"?imageView2/1/w/200/h/200"];
        
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:@"http://teddylong.net/BabyDaily/PostEntity.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);

        NSArray * data = responseObject;
        
        for(int i=0;i<data.count;i++)
        {
            NSDictionary *dailyDetail = [data objectAtIndex:i];
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
        [self.tableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];

}

- (void)headerRereshing
{
    _array = [[NSMutableArray alloc]init];
    [self LoadDailys];
    [self.tableView headerEndRefreshing];
    
}

@end

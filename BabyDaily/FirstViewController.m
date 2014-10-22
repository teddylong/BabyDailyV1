//
//  FirstViewController.m
//  BabyDaily
//
//  Created by Ctrip on 14-10-13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "FirstViewController.h"
#import "WriteDailyViewController.h"
#import "DailyOne.h"
#import <Realm/Realm.h>
#import "DailyDetailViewController.h"
#import "AsyncImageView.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"

static NSString * const kCellID    = @"cell";
static NSString * const kTableName = @"table";

@interface FirstViewController ()

@property (nonatomic, strong) RLMArray *array;
@property (assign, nonatomic) NSInteger selectedRow;
@property (nonatomic, strong) RLMNotificationToken *notification;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    
    //self.tableView.separatorColor = [UIColor colorWithRed:52.0f/255.0f green:53.0f/255.0f blue:61.0f/255.0f alpha:1];
    
    // Set realm notification block
    __weak typeof(self) weakSelf = self;
    
    self.notification = [RLMRealm.defaultRealm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf reloadData];
    }];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)headerRereshing
{
    [self reloadData];
    [self.tableView headerEndRefreshing];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goNext"])
    {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:@"这里是要传递的值" forKey:@"strTtile"];
    }
    if([segue.identifier isEqualToString:@"goDetail"])
    {
        DailyDetailViewController *dailyDetail = segue.destinationViewController;
        dailyDetail.daily = self.array[_selectedRow];
        
    }
    self.hidesBottomBarWhenPushed = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    self.hidesBottomBarWhenPushed = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = [indexPath row];
    return indexPath;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell"];
    }
    //选取cell不变色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    DailyOne *object = self.array[indexPath.row];
    
    UILabel* bodyLabel = (UILabel *)[cell.contentView viewWithTag:1];
    bodyLabel.text = object.Body;
    
    NSString *dailyDate = [object.CreateDate componentsSeparatedByString:@" "][0];
    NSString *dailyTime = [object.CreateDate componentsSeparatedByString:@" "][1];
    
    UILabel* dailyDateLabel = (UILabel *)[cell.contentView viewWithTag:2];
    dailyDateLabel.text = dailyDate;
    
    UILabel* dailyTimeLabel = (UILabel *)[cell.contentView viewWithTag:4];
    dailyTimeLabel.text = dailyTime;
    
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    if(![object.Location  isEqual:@""])
    {
        
        UILabel* locationInfo = (UILabel *)[cell.contentView viewWithTag:14];
        locationInfo.text = object.Location;
        
    }
    else
    {
        UIImageView *locationImage =(UIImageView *)[cell.contentView viewWithTag:12];
        //locationImage = nil;
        [locationImage setHidden:YES];
        
        UILabel* locationInfo = (UILabel *)[cell.contentView viewWithTag:14];
        locationInfo.text = @"";

    }
    
    if(![object.Weather isEqual:@""])
    {
        NSString *weatherInfo = [object.Weather componentsSeparatedByString:@","][0];
        NSString *tempInfo = [object.Weather componentsSeparatedByString:@","][1];
        
        UILabel* weatherInfoLable = (UILabel *)[cell.contentView viewWithTag:8];
        weatherInfoLable.text = weatherInfo;
        
        UILabel* tempInfoLabel = (UILabel *)[cell.contentView viewWithTag:6];
        tempInfoLabel.text = tempInfo;
        
        UIImageView *weatherImage =(UIImageView *)[cell.contentView viewWithTag:10];

        
        if([weatherInfo containsString:@"mist"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Fog"];
        }
        else if ([weatherInfo containsString:@"sun"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Sun"];
        }
        else if ([weatherInfo containsString:@"rain"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Rain"];
        }
        else if ([weatherInfo containsString:@"clouds"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Clouds"];
        }
        else if ([weatherInfo containsString:@"hail"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Hail"];
        }
        else if ([weatherInfo containsString:@"storm"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Storm"];
        }
        else if ([weatherInfo containsString:@"snow"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Snow"];
        }

    }
    else
    {
        UILabel* weatherInfoLable = (UILabel *)[cell.contentView viewWithTag:8];
        weatherInfoLable.text = @"";
        
        UILabel* tempInfoLabel = (UILabel *)[cell.contentView viewWithTag:6];
        tempInfoLabel.text = @"";
        
        UIImageView *weatherImage =(UIImageView *)[cell.contentView viewWithTag:10];
        [weatherImage setHidden:YES];
    }
    


    UIImageView *viewImage = (UIImageView *)[cell.contentView viewWithTag:100];
    NSString *tempString = [object.Image stringByAppendingString:@"?imageView2/1/w/200/h/200"];
        
    [viewImage sd_setImageWithURL:[[NSURL alloc] initWithString: tempString]];
        
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RLMRealm *realm = RLMRealm.defaultRealm;
        [realm beginWriteTransaction];
        [realm deleteObject:self.array[indexPath.row]];
        [realm commitWriteTransaction];
    }
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 110;
//}

#pragma mark - Actions

- (void)reloadData
{
    self.array = [[DailyOne allObjects] arraySortedByProperty:@"CreateDate" ascending:NO];
    [self.tableView reloadData];
}
@end

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
@property (nonatomic, strong) NSMutableDictionary *sectionDaily;
@property (nonatomic,strong) NSMutableArray *dailys;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _sectionDaily = [[NSMutableDictionary alloc]init];
    
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
    //self.hidesBottomBarWhenPushed = YES;
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    self.hidesBottomBarWhenPushed = NO;
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
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    //DailyOne *object = self.array[indexPath.row];
    DailyOne *object = [_sectionDaily valueForKey:[NSString stringWithFormat: @"%d", (int)section]][row];
    
    UILabel* bodyLabel = (UILabel *)[cell.contentView viewWithTag:1];
    bodyLabel.text = object.Body;
    
    //NSString *dailyDate = [object.CreateDate componentsSeparatedByString:@" "][0];
    //NSString *dailyTime = [object.CreateDate componentsSeparatedByString:@" "][1];
    
    NSDate *now2 = object.CreateDate;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    
    comps = [calendar components:unitFlags fromDate:now2];
    NSInteger dailyDate = [comps day];
    NSString *dailyDateString = [NSString stringWithFormat:@"%d",(int)dailyDate];
    NSInteger dailyHour = [comps hour];
    NSInteger dailyMin = [comps minute];
    
    
    
    //NSString *dailyDateOnlyDay = [dailyDate componentsSeparatedByString:@"-"][2];
    NSString *dailyTimeNoS = @"";
    if(dailyMin < 10)
    {
        dailyTimeNoS = [[[[NSString stringWithFormat:@"%d",(int)dailyHour] stringByAppendingString:@":"] stringByAppendingString:@"0"] stringByAppendingString:[NSString stringWithFormat:@"%d",(int)dailyMin]];
    }
    else
    {
        dailyTimeNoS = [[[NSString stringWithFormat:@"%d",(int)dailyHour] stringByAppendingString:@":"]stringByAppendingString:[NSString stringWithFormat:@"%d",(int)dailyMin]];
    }
    
    
    UILabel* dailyDateLabel = (UILabel *)[cell.contentView viewWithTag:2];
    dailyDateLabel.text = dailyDateString;
    
    UILabel* dailyTimeLabel = (UILabel *)[cell.contentView viewWithTag:4];
    dailyTimeLabel.text = dailyTimeNoS;
    
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    if(![object.Location  isEqual:@""])
    {
        
        UILabel* locationInfo = (UILabel *)[cell.contentView viewWithTag:14];
        locationInfo.text = object.Location;
        UIImageView *locationImage =(UIImageView *)[cell.contentView viewWithTag:12];
        //locationImage = nil;

        [locationImage setHidden:NO];
        
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
        
//        UILabel* weatherInfoLable = (UILabel *)[cell.contentView viewWithTag:8];
//        weatherInfoLable.text = weatherInfo;
        
        UILabel* tempInfoLabel = (UILabel *)[cell.contentView viewWithTag:6];
        tempInfoLabel.text = tempInfo;
        
        UIImageView *weatherImage =(UIImageView *)[cell.contentView viewWithTag:10];

        
        if([weatherInfo containsString:@"mist"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Fog"];
        }
        else if ([weatherInfo containsString:@"Clear"])
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
        else if ([weatherInfo containsString:@"thunderstorm"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Storm"];
        }
        else if ([weatherInfo containsString:@"snow"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Snow"];
        }
        
        [weatherImage setHidden:NO];

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

// // // //
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
    {
        return @"本月";
    }
    else if (section ==1)
    {
        return @"三个月";
    }
    else if (section == 2)
    {
        return @"半年";
    }
    else
    {
        return @"半年之前";
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * headerView = [[UILabel alloc] initWithFrame:[tableView headerViewForSection:section].bounds];
    NSString *headerViweTitle = @"";
    if(section == 0)
    {
        headerViweTitle = @"本月";
    }
    else if (section ==1)
    {
        headerViweTitle =  @"三个月";
    }
    else if (section == 2)
    {
        headerViweTitle =  @"半年";
    }
    else
    {
        headerViweTitle =  @"半年之前";
    }
    headerView.text = headerViweTitle;
    headerView.textAlignment = NSTextAlignmentCenter;
    headerView.font = [UIFont boldSystemFontOfSize:18.0f];
    headerView.textColor = [UIColor whiteColor];
    headerView.backgroundColor = [self colorWithHexString:@"75A5FF"];
    
    return headerView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    
    comps = [calendar components:unitFlags fromDate:now];
    
    
    [comps setDay:([comps day] - ([comps day] -1))];
    NSDate *thisMonth = [calendar dateFromComponents:comps];
    
    [comps setMonth:([comps month] - 3)];
    NSDate *lastThreeMonth = [calendar dateFromComponents:comps];
    
    [comps setMonth:([comps month] - 3)];
    NSDate *lastSixMonth = [calendar dateFromComponents:comps];
    
    
    //    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:@"yyyy-MM-dd"];
    //    NSDate *dayOneOfMonth = [formatter dateFromString:currentMonthString];
    
    
    if(section == 0)
    {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"CreateDate > %@",thisMonth];
        
        RLMArray *sectionCurrect = [[DailyOne objectsWithPredicate:pred] arraySortedByProperty:@"CreateDate" ascending:NO];
        
        [_sectionDaily setValue:sectionCurrect forKey:@"0"];
        return sectionCurrect.count;
    }
    if (section ==1)
    {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"CreateDate < %@ and CreateDate > %@",thisMonth,lastThreeMonth];
        
        RLMArray *sectionCurrect = [[DailyOne objectsWithPredicate:pred] arraySortedByProperty:@"CreateDate" ascending:NO];
        
        [_sectionDaily setValue:sectionCurrect forKey:@"1"];
        return sectionCurrect.count;
    }
    if (section ==2)
    {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"CreateDate < %@ and CreateDate > %@",lastThreeMonth,lastSixMonth];
        
        RLMArray *sectionCurrect = [[DailyOne objectsWithPredicate:pred] arraySortedByProperty:@"CreateDate" ascending:NO];
        
        [_sectionDaily setValue:sectionCurrect forKey:@"2"];
        
        return sectionCurrect.count;
    }
    else
    {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"CreateDate < %@",lastSixMonth];
        
        RLMArray *sectionCurrect = [[DailyOne objectsWithPredicate:pred] arraySortedByProperty:@"CreateDate" ascending:NO];
        
        [_sectionDaily setValue:sectionCurrect forKey:@"3"];
        
        return sectionCurrect.count;
    }
    
}
@end

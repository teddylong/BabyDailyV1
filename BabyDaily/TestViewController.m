//
//  TestViewController.m
//  BabyDaily
//
//  Created by 龙 轶群 on 14-10-25.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "TestViewController.h"
#import <Realm/Realm.h>
#import "DailyOne.h"


@interface TestViewController ()

@property (nonatomic, strong) RLMArray *array;
@property (assign, nonatomic) NSInteger selectedRow;
@property (nonatomic, strong) RLMNotificationToken *notification;
@property (nonatomic, strong) NSMutableDictionary *sectionDaily;
@property (nonatomic,strong) NSMutableArray *dailys;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _sectionDaily = [[NSMutableDictionary alloc]init];
    
    __weak typeof(self) weakSelf = self;
    
    self.notification = [RLMRealm.defaultRealm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf reloadData];
    }];
    
    [self reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = [indexPath row];
    return indexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell"];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"TestCell"];
    }
    
    //DailyOne *object = self.array[indexPath.row];
    
    DailyOne *object = [_sectionDaily valueForKey:[NSString stringWithFormat: @"%d", (int)section]][row];
    cell.textLabel.text = object.Body;
    
    
    return cell;
}

- (void)reloadData
{
    self.array = [[DailyOne allObjects] arraySortedByProperty:@"CreateDate" ascending:NO];
    [self.tableView reloadData];
}


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

@end

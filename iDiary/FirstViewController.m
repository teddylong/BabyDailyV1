//
//  FirstViewController.m
//  iDiary
//
//  Created by 龙 轶群 on 14-10-13.
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
#import "SearchResultController.h"
#import "RegUserViewController.h"
#import "User.h"

static NSString * const kCellID    = @"cell";
static NSString * const kTableName = @"table";

@interface FirstViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) RLMArray *array;
@property (nonatomic, strong) RLMArray *searchArray;
@property (assign, nonatomic) NSInteger selectedRow;
@property (nonatomic, strong) RLMNotificationToken *notification;
@property (nonatomic, strong) NSMutableDictionary *sectionDaily;
@property (nonatomic,strong) NSMutableArray *dailys;
@property (nonatomic,strong) NSIndexPath *localPath;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) SearchResultController *resultsTableController;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置Nav为白色以适应深色背景
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    //检查用户
    RLMArray *user = [User allObjects];
    if(user.count >0)
    {
        //调试信息,打印用户名
        NSLog(@"%@",[[user objectAtIndex:0] UserName]);
    }
    else
    {
        //进入注册用户页面
        RegUserViewController *regUser = [self.storyboard instantiateViewControllerWithIdentifier:@"RegUserViewController"];
        [self presentViewController:regUser animated:YES
                         completion:nil];
    }
    
    //搜索面板初始化
    _resultsTableController = [[SearchResultController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    
    //主页面列表初始化
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //日记字典初始化
    _sectionDaily = [[NSMutableDictionary alloc]init];
    
    //日记路径初始化
    _localPath = [[NSIndexPath alloc] init];
    
    //自定义导航栏中间图片
    //UIImage *logoImage = [UIImage imageNamed:@"Logo"];
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    
    //UIView *navView = [[UIView alloc] init];
    //navView.backgroundColor = [UIColor blackColor];
    //self.navigationItem.titleView = navView;
    //self.navigationController.navigationBar.tintColor = [UIColor blackColor];

    //日记数据库发生变更，刷新数据
    __weak typeof(self) weakSelf = self;
    self.notification = [RLMRealm.defaultRealm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        
        [weakSelf reloadData];
    }];
    
    //主页面列表下移44像素，由导航栏占位
    [self.tableView setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
    
    //获取列表
    [self reloadData];
}

//点击搜索栏的Search按钮，使之失去焦点
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

//更新搜索结果
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    //定义搜索谓词
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"Body contains %@",searchController.searchBar.text];
    
    //获取搜索结果
    _searchArray = [_array objectsWithPredicate:pred];
    
    //在搜索列表中显示搜索结果
    SearchResultController *tableController = (SearchResultController *)self.searchController.searchResultsController;
    tableController.dailys = _searchArray;
    [tableController.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

////定义跳转以及传值 （已弃用）
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    //跳转到详细页面
//    if([segue.identifier isEqualToString:@"goDetail"])
//    {
//        //详细页面初始化
//        DailyDetailViewController *dailyDetail = segue.destinationViewController;
//        
//        //获取日记路径
//        NSInteger section = _localPath.section;
//        NSInteger row = _localPath.row;
//        
//        //把获得的日记传给详细页面
//        dailyDetail.daily = [_sectionDaily valueForKey:[NSString stringWithFormat: @"%d", (int)section]][row];
//    }
//    
//    //跳转后隐藏底部状态栏
//    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
//}

- (void)viewWillDisappear:(BOOL)animated {
    self.hidesBottomBarWhenPushed = NO;
}

//点击列表中日记，取得日记路径
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _localPath = indexPath;
    return indexPath;
}

//点击日记进入详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //获取日记路径
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    //判断点击的日记是主页列表中的，还是搜索结果中的
    DailyOne *selectedDaily = (tableView == self.tableView) ?
    [_sectionDaily valueForKey:[NSString stringWithFormat: @"%d", (int)section]][row] : self.resultsTableController.dailys[indexPath.row];
    
    //详细页面初始化
    DailyDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DailyDetailViewController"];
    
    //把点击的日记传给详细页面
    detailViewController.daily = selectedDaily;

    //跳转后隐藏底部状态栏
    [detailViewController setHidesBottomBarWhenPushed:YES];
    
    //进入到详细页面
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    //待删
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//显示主页面列表日记信息
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //构建Cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell"];
    }
    
    //选取Cell不变色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //根据日记路径取得日记
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    DailyOne *object = [_sectionDaily valueForKey:[NSString stringWithFormat: @"%d", (int)section]][row];
    
    //把日记信息显示在Cell中
    //1. 显示Body
    UILabel* bodyLabel = (UILabel *)[cell.contentView viewWithTag:1];
    bodyLabel.text = object.Body;
    
    //2. 显示日期（没有年份及月份）以及时间
    NSDate *now2 = object.CreateDate;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    comps = [calendar components:unitFlags fromDate:now2];
    NSInteger dailyDate = [comps day];
    NSString *dailyDateString = [NSString stringWithFormat:@"%d",(int)dailyDate];
    NSInteger dailyHour = [comps hour];
    NSInteger dailyMin = [comps minute];
    
    //如果日期到不10，则变成0X格式
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
    
    //3. 显示地理信息
    if(![object.Location  isEqual:@""])
    {
        UILabel* locationInfo = (UILabel *)[cell.contentView viewWithTag:14];
        locationInfo.text = object.Location;
        UIImageView *locationImage =(UIImageView *)[cell.contentView viewWithTag:12];
        [locationImage setHidden:NO];
    }
    else
    {
        UIImageView *locationImage =(UIImageView *)[cell.contentView viewWithTag:12];
        [locationImage setHidden:YES];
        UILabel* locationInfo = (UILabel *)[cell.contentView viewWithTag:14];
        locationInfo.text = @"";

    }
    
    //4. 显示天气信息
    if(![object.Weather isEqual:@""])
    {
        //温度
        NSString *tempInfo = [object.Weather componentsSeparatedByString:@","][1];
        UILabel* tempInfoLabel = (UILabel *)[cell.contentView viewWithTag:6];
        tempInfoLabel.text = tempInfo;
        
        //天气状况
        NSString *weatherInfo = [object.Weather componentsSeparatedByString:@","][0];
        
        //天气图标
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
        else if ([weatherInfo containsString:@"haze"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Fog"];
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
    

    //5. 显示缩略图
    UIImageView *viewImage = (UIImageView *)[cell.contentView viewWithTag:100];
    NSString *tempString = [object.Image stringByAppendingString:@"?imageView2/1/w/200/h/200"];
    
    //设置缩略图片圆角
    CALayer *layer = [viewImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:5.0f];
    
    //异步显示图片
    [viewImage sd_setImageWithURL:[[NSURL alloc] initWithString: tempString]];
    
    //返回Cell
    return cell;
}

//删除日记
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

//刷新列表信息（按CreateTime 倒序）
- (void)reloadData
{
    self.array = [[DailyOne allObjects] arraySortedByProperty:@"CreateDate" ascending:NO];
    [self.tableView reloadData];
}

////列表各分组名字 （已弃用）
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    if(section == 0)
//    {
//        return @"本月";
//    }
//    else if (section ==1)
//    {
//        return @"三个月";
//    }
//    else if (section == 2)
//    {
//        return @"半年";
//    }
//    else
//    {
//        return @"半年之前";
//    }
//}

//列表分组高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //判断是主页列表还是搜索结果列表
    if(tableView ==self.tableView)
    {
        return 20.0f;
    }
    else
    {
        return 0.0f;
    }
}

//列表分组View的样式
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * headerView = [[UILabel alloc] initWithFrame:[tableView headerViewForSection:section].bounds];
    
    //各分组名字
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
    
    //分组字体，颜色，居中
    headerView.font = [UIFont boldSystemFontOfSize:17.0f];
    headerView.textColor = [UIColor whiteColor];
    headerView.textAlignment = NSTextAlignmentCenter;
    
    //分组背景色
    headerView.backgroundColor = [self colorWithHexString:@"75A5FF"];
    
    return headerView;
}

//列表分组数量
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

//Hex样式颜色转换
-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) return [UIColor grayColor];
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return  [UIColor grayColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

//各分组中日记的数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //取当前时间点
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    //本月时间点
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps = [calendar components:unitFlags fromDate:now];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    [comps setDay:([comps day] - ([comps day] -1))];
    NSDate *thisMonth = [calendar dateFromComponents:comps];
    
    //三个月时间点
    [comps setMonth:([comps month] - 3)];
    NSDate *lastThreeMonth = [calendar dateFromComponents:comps];
    
    //半年时间点
    [comps setMonth:([comps month] - 3)];
    NSDate *lastSixMonth = [calendar dateFromComponents:comps];
    
    //开始取值
    if(section == 0)
    {
        //谓词，大于等于本月
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"CreateDate >= %@",thisMonth];
        RLMArray *sectionCurrect = [[DailyOne objectsWithPredicate:pred] arraySortedByProperty:@"CreateDate" ascending:NO];
        [_sectionDaily setValue:sectionCurrect forKey:@"0"];
        return sectionCurrect.count;
    }
    if (section ==1)
    {
        //谓词，小于本月，大于等于三个月
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"CreateDate < %@ and CreateDate >= %@",thisMonth,lastThreeMonth];
        RLMArray *sectionCurrect = [[DailyOne objectsWithPredicate:pred] arraySortedByProperty:@"CreateDate" ascending:NO];
        [_sectionDaily setValue:sectionCurrect forKey:@"1"];
        return sectionCurrect.count;
    }
    if (section ==2)
    {
        //谓词，小于三个月，大于等于半年
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"CreateDate < %@ and CreateDate >= %@",lastThreeMonth,lastSixMonth];
        RLMArray *sectionCurrect = [[DailyOne objectsWithPredicate:pred] arraySortedByProperty:@"CreateDate" ascending:NO];
        [_sectionDaily setValue:sectionCurrect forKey:@"2"];
        return sectionCurrect.count;
    }
    else
    {
        //谓词，小于半年
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"CreateDate < %@",lastSixMonth];
        RLMArray *sectionCurrect = [[DailyOne objectsWithPredicate:pred] arraySortedByProperty:@"CreateDate" ascending:NO];
        [_sectionDaily setValue:sectionCurrect forKey:@"3"];
        return sectionCurrect.count;
    }
}

//列表每行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //判断是主页列表还是搜索结果列表
    if(tableView == self.tableView)
    {
        return 104;
    }
    else
    {
        return 71;
    }
}
@end

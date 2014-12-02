//
//  LookViewController.m
//  iDiary
//
//  Created by 龙 轶群 on 14/10/28.
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
    
    //设置Nav为白色以适应深色背景
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    //初始化广场列表
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _array = [[NSMutableArray alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    //加载广场日记列表
    [self LoadDailys];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//点击列表中日记，取得日记路径
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = [indexPath row];
    return indexPath;
}

//点击日记进入详细页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //根据日记路径获得日记
    DailyOne *selectedDaily = [_array objectAtIndex:indexPath.row];
    
    //初始化详细页面
    DailyDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DailyDetailViewController"];
    
    //把点击的日记传给详细页面
    detailViewController.daily = selectedDaily;
    
    //因为是在广场中，隐藏详细页面中的编辑功能
    detailViewController.navigationItem.rightBarButtonItem = nil;
    
    //跳转后隐藏底部状态栏
    [detailViewController setHidesBottomBarWhenPushed:YES];
    
    //进入到详细页面
    [self.navigationController pushViewController:detailViewController animated:YES];
}

//显示广场列表日记信息
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //构建Cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LookCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"LookCell"];
    }
    
    if(_array.count ==0)
    {
    
    }
    else
    {
        //根据日记路径取得日记
        DailyOne *daily = [_array objectAtIndex:indexPath.row];
        
        //把日记信息显示在Cell中
        //1. 显示Body
        UILabel* bodyLabel = (UILabel *)[cell.contentView viewWithTag:1];
        bodyLabel.text = daily.Body;
        
        //2. 显示日期
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

        //3. 显示用户信息
        UILabel *dailyUserLabel =(UILabel *)[cell.contentView viewWithTag:7];
        dailyUserLabel.text = daily.User;

        //4. 显示图片
        UIImageView *viewImage = (UIImageView *)[cell.contentView viewWithTag:100];
        NSString *tempString = [daily.Image stringByAppendingString:@"?imageView2/1/w/200/h/200"];
        
        //设置图片圆角
        CALayer *layer = [viewImage layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:5.0f];
        //异步显示图片
        [viewImage sd_setImageWithURL:[[NSURL alloc] initWithString: tempString]];
    }
    
    //返回Cell
    return cell;

}

//返回广场日记数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

//获取广场日记主方法
- (void)LoadDailys
{
    //初始化Loading面板，TabBar关闭
    [ProgressHUD show:@"Loading..."];
    [self disableTabBar];
    
    //获取广场日记URL
    NSURL *url = [NSURL URLWithString:@"http://teddylong.net/BabyDaily/PostEntity.php"];
    
    //设置Request不读取缓存
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    
    //初始化AFHTTP
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //Debug专用
        NSLog(@"Success: %@", operation.responseString);
        
        //成功响应Request，获取返回数据
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        
        //将返回数据转化成Array
        NSArray *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        
        //遍历Array，构建日记
        for(int i=0;i<resultDic.count;i++)
        {
            NSDictionary *dailyDetail = [resultDic objectAtIndex:i];
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
            
            //添加日记到日记数组中
            [_array addObject:daily];
        }
        
        //获取日记后，关闭Loading面板，TabBar开启
        [ProgressHUD dismiss];
        [self enableTabBar];
        
        //刷新广场日记列表
        [self.tableView reloadData];
     
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         //Debug专用
         NSLog(@"Failure: %@", error);
         
         //获取日记信息出错，Loading面板显示Error信息
         [ProgressHUD showError:@"Failed"];
     }];
    
    //开始Request
    [operation start];
}

//下拉广场列表刷新
- (void)headerRereshing
{
    //日记数组清空
    _array = [[NSMutableArray alloc]init];
    
    //Loading面板初始化
    [ProgressHUD show:@"Loading..."];
    
    //获取广场日记
    [self LoadDailys];
    
    //下拉完成
    [self.tableView headerEndRefreshing];
}

//禁用TabBar
-(void)disableTabBar
{
    UITabBar *myTb=self.tabBarController.tabBar;
    for(UITabBarItem *utb in myTb.items)
    {
        if( ![utb.title isEqualToString:@"随便看看"] )
        {
            utb.enabled=NO;
        }
        else {
            utb.enabled=YES;
        }
    }
}

//启用TabBar
-(void)enableTabBar
{
    UITabBar *myTb=self.tabBarController.tabBar;
    for(UITabBarItem *utb in myTb.items)
    {
        utb.enabled=YES;
    }
}

@end

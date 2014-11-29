//
//  WriteDailyViewController.m
//  iDiary
//
//  Created by 龙 轶群 on 14-10-13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "WriteDailyViewController.h"
#import "UzysAssetsPickerController.h"
#import "DailyOne.h"
#import "AFNetworking.h"

#import "QiniuUploadDelegate.h"
#import <MapKit/MapKit.h>
#import "ASPopUpView.h"
#import "ASProgressPopUpView.h"
#import "QiniuSimpleUploader.h"
#import "ProgressHUD.h"
#import "User.h"


@interface WriteDailyViewController () <UzysAssetsPickerControllerDelegate,CLLocationManagerDelegate,QiniuUploadDelegate>

@property (assign, nonatomic) CLLocationCoordinate2D *latestCoordinate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (assign, nonatomic) UIImage *willUploadImage;
@property (nonatomic, strong) DailyOne *daily;
@property (nonatomic) ASProgressPopUpView* myProgressView;
@property (nonatomic) BOOL isPublished;
@property (nonatomic, strong) NSMutableData* receiveData;


@end

@implementation WriteDailyViewController


@synthesize AllToken;
@synthesize PublishBtn;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //初始化
    _isPublished = NO;
    
    //UITextView获得焦点
    [self.DailyBody becomeFirstResponder];
    
    //初始化Daily
     _daily = [[DailyOne alloc] init];
    _daily.Weather = @"";
    _daily.Location = @"";
    
    //设置进度条
    _myProgressView = [[ASProgressPopUpView alloc]initWithFrame:CGRectMake(0.0f, 65.0f, 320.0f, 10.0f)];
    _myProgressView.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
    _myProgressView.popUpViewCornerRadius = 16.0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//从手机中选择一张图片
- (IBAction)AddImg:(id)sender {
    
    //取消UITextView的第一响应
    [self.DailyBody resignFirstResponder];
    
    //启动Image Picker
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = 1;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}
//选择并显示手机中照片
- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    self.upLoadImg.backgroundColor = [UIColor clearColor];

    __weak typeof(self) weakSelf = self;
    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *representation = obj;
            
            //获取到选择照片
            UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullScreenImage];

            //显示照片到按钮背景中
            weakSelf.willUploadImage = img;
            [weakSelf.AddImgBtn setBackgroundImage:img forState:UIControlStateNormal];
            [weakSelf.AddImgBtn setFrame:CGRectMake(45, 285, 50, 25)];
            
            *stop = YES;
        }];
    }
    //UITextView获取第一响应，弹出键盘
    BOOL isFirst = [weakSelf.DailyBody canBecomeFirstResponder];
    if(isFirst)
    {
        [weakSelf.DailyBody becomeFirstResponder];
    }
}

//保存日记
- (IBAction)SaveDaily:(id)sender {
    
    //获取user信息
    RLMArray *user = [User allObjects];
    if(user.count >0)
    {
        _daily.User = [[user objectAtIndex:0] UserName];
    }
    
    //ID 占位
    _daily.ID = @"1";
    
    //设置保存时间信息
    NSDate *now = [NSDate date];
    _daily.CreateDate = now;
    _daily.UpdateDate = now;
    
    //设置手机唯一标识符信息
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    _daily.UDID = idfv;
    
    //设置文字信息
    _daily.Body = self.DailyBody.text;
    
    //设置是否上传标签信息
    if(_isPublished)
    {
        _daily.Tag = @"YES";
    }
    else
    {
        _daily.Tag = @"NO";
    }
    
    //如果没有图片
    if( self.willUploadImage == nil)
    {
        //图片字段为空
        _daily.Image = @"";
        
        //保存到数据库
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:_daily];
        [realm commitWriteTransaction];
        
        //如果上传到广场
        if(_isPublished)
        {
            [ProgressHUD show:@"UpLoading..."];
            
            //上传到广场并回到主页
            [self PostDailyToWebServerAndBack:_daily];
        }
        else
        {
            //返回主页
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    //有图片
    else
    {
        [self getToken:_daily];
    }
}

//取得七牛空间Token
- (void)getToken:(DailyOne *) entity
{
    //Cancel以及Done按钮失效
    [self letSubmitBtnGone];
    
    //添加进度条到页面中
    [self.view addSubview:_myProgressView];
    [_myProgressView showPopUpViewAnimated:YES];
    
    //开始请求Token
    NSURL *url = [NSURL URLWithString:@"http://teddylong.net/qiniu/GetTokenOnce.php"];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", operation.responseString);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        
        //取得Token字符串
        AllToken = [resultDic objectForKey:@"MyToken"];
        
        //准备开始上传图片
        NSData *imageData = UIImagePNGRepresentation(self.willUploadImage);
        [self UploadImg: imageData:AllToken:entity];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
    }];
    [operation start];
}

//上传图片
-(void) UploadImg:(NSData *) uploaddata: (NSString *) token: (DailyOne *) entity
{
    QiniuSimpleUploader *newUpLoader = [QiniuSimpleUploader uploaderWithToken:token];
    newUpLoader.delegate = self;
    
    //准备上传图片名称
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    NSString *stringFromDate = [formatter stringFromDate:[[NSDate alloc]init]];
    NSString *filename = [stringFromDate stringByAppendingString:@".png"];
    
    //开始上传图片
    [newUpLoader uploadFileData:uploaddata key:filename extra:nil];
}

//准备获取天气地理位置信息
- (IBAction)GetLocationWeather:(id)sender {
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager requestAlwaysAuthorization];
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
}

//获取天气地理位置信息
- (void)locationManager:(CLLocationManager *)locationManager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //停止更新地理信息
    [_locationManager stopUpdatingLocation];
    double longitude = newLocation.coordinate.longitude;
    double latitude = newLocation.coordinate.latitude;
    
    NSNumber *nlongitude = [NSNumber numberWithDouble:longitude];
    NSNumber *nlatitude = [NSNumber numberWithDouble:latitude];
    
    //准备根据地理信息获取天气信息
    NSString *url = [[[@"http://api.openweathermap.org/data/2.5/weather?lat=" stringByAppendingString: [nlatitude stringValue]] stringByAppendingString:@"&lon="] stringByAppendingString:[nlongitude stringValue]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        //取得天气信息
        NSDictionary *countryDict = responseObject[@"sys"];
        NSString *country = countryDict[@"country"];
        NSDictionary *weatherDict = [responseObject[@"weather" ] firstObject];
        NSString *weather = weatherDict[@"description"];
        NSDictionary *tempDict = responseObject[@"main"];
        NSNumber *temp = tempDict[@"temp"];
        NSString *city = responseObject[@"name"];
        
        //转化为摄氏度
        double cTemp = [temp doubleValue];
        NSInteger convertedValue =  ceil(cTemp - 273.15);
        
        //设置Daily的weather以及location属性
        _daily.Weather = [[[weather stringByAppendingString:@","] stringByAppendingString:[@(convertedValue) stringValue]] stringByAppendingString:@"°"];
        _daily.Location = [[country stringByAppendingString:@","] stringByAppendingString:city];
        
        //显示在页面上
        UILabel *tempLabel = (UILabel *)[self.view viewWithTag:14];
        tempLabel.text = [[@(convertedValue) stringValue] stringByAppendingString:@"°"];
        
        //适配天气图标
        if([weather containsString:@"mist"])
        {
            [self.GetWeatherBtn setBackgroundImage:[UIImage imageNamed:@"Fog"] forState:UIControlStateNormal];
        }
        else if ([weather containsString:@"Clear"])
        {
            [self.GetWeatherBtn setBackgroundImage:[UIImage imageNamed:@"Sun"] forState:UIControlStateNormal];
        }
        else if ([weather containsString:@"rain"])
        {
            [self.GetWeatherBtn setBackgroundImage:[UIImage imageNamed:@"Rain"] forState:UIControlStateNormal];
        }
        else if ([weather containsString:@"clouds"])
        {
            [self.GetWeatherBtn setBackgroundImage:[UIImage imageNamed:@"Clouds"] forState:UIControlStateNormal];
        }
        else if ([weather containsString:@"hail"])
        {
            [self.GetWeatherBtn setBackgroundImage:[UIImage imageNamed:@"Hail"] forState:UIControlStateNormal];
        }
        else if ([weather containsString:@"thunderstorm"])
        {
            [self.GetWeatherBtn setBackgroundImage:[UIImage imageNamed:@"Storm"] forState:UIControlStateNormal];
        }
        else if ([weather containsString:@"snow"])
        {
            [self.GetWeatherBtn setBackgroundImage:[UIImage imageNamed:@"Snow"] forState:UIControlStateNormal];
        }
        else if ([weather containsString:@"haze"])
        {
            [self.GetWeatherBtn setBackgroundImage:[UIImage imageNamed:@"Fog"] forState:UIControlStateNormal];
        }
        
        //Debug专用
        NSLog(@"%@",country);
        NSLog(@"%@",weather);
        NSLog(@"%@",[temp stringValue]);
        NSLog(@"%@",city);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//定位失败
- (void)locationManager:(CLLocationManager *)locationManager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

//接受上传进度，1.0为100%
- (void)uploadProgressUpdated:(NSString *)filePath percent:(float)percent
{
    _myProgressView.progress = percent;
}

//上传成功
- (void)uploadSucceeded:(NSString *)filePath ret:(NSDictionary *)ret
{
    //关闭进度条
    _myProgressView.progress = 1.0;
    [_myProgressView showPopUpViewAnimated:NO];
    
    //向数据库中添加数据
    _daily.Image = [@"http://babydaily.qiniudn.com/" stringByAppendingString:filePath];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:_daily];
    [realm commitWriteTransaction];
    
    //如果上传到广场
    if(_isPublished)
    {
        [self PostDailyToWebServer:_daily];
    }
    //如果不上传到广场，直接返回主页面
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

}

//上传失败
- (void)uploadFailed:(NSString *)filePath error:(NSError *)error
{
    //返回到主页面
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//按钮失效
-(void)letSubmitBtnGone
{
    //Done按钮
    UIBarButtonItem *submitBtn = self.navigationItem.rightBarButtonItem;
    [submitBtn setEnabled:NO];
    
    //Cancel按钮
    UIBarButtonItem *leftBtn = self.navigationItem.leftBarButtonItem;
    [leftBtn setEnabled:NO];
}

//带图片的上传到广场
-(void)PostDailyToWebServer:(DailyOne *)entity
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //构造POST参数并上传
    NSDictionary *parameters = @{@"User": entity.User,
                                 @"Body": entity.Body,
                                 @"CreateTime": entity.CreateDate,
                                 @"ImageAddress": entity.Image,
                                 @"Location": entity.Location,
                                 @"Tag": entity.Tag,
                                 @"UDID": entity.UDID,
                                 @"UpdateTime": entity.UpdateDate,
                                 @"Weather": entity.Weather};

    [manager POST:@"http://teddylong.net/BabyDaily/QueryEntity.php" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        
        //获得返回ID
        NSDictionary *dic = responseObject;
        NSNumber *returnID = dic[@"Result"];
        
        //更新Daily ID属性
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        _daily.ID = [returnID stringValue];
        [realm commitWriteTransaction];
        
        //返回主页面
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//不带图片的上传到广场
-(void)PostDailyToWebServerAndBack:(DailyOne *)entity
{
    //Done,Cancle按钮失效
    [self letSubmitBtnGone];
    
    //构造POST参数并上传
    NSDictionary *parameters = @{@"User": entity.User,
                                 @"Body": entity.Body,
                                 @"CreateTime": entity.CreateDate,
                                 @"ImageAddress": entity.Image,
                                 @"Location": entity.Location,
                                 @"Tag": entity.Tag,
                                 @"UDID": entity.UDID,
                                 @"UpdateTime": entity.UpdateDate,
                                 @"Weather": entity.Weather};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://teddylong.net/BabyDaily/QueryEntity.php" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //获得返回ID
        NSDictionary *dic = responseObject;
        NSNumber *returnID = dic[@"Result"];
        
        //更新Daily ID属性
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        _daily.ID = [returnID stringValue];
        [realm commitWriteTransaction];
        
        //上传成功，取消HUD状态
        NSLog(@"Success: %@", responseObject);
        [ProgressHUD dismiss];
        
        //返回主页面
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //上传失败，弹出Error HUD状态
        NSLog(@"Error: %@", error);
        [ProgressHUD showError:@"Error"];
    }];
}

//点击是否上传到广场按钮
- (IBAction)ClickPublish:(id)sender {
    
    if(_isPublished)
    {
        _isPublished = NO;
        [PublishBtn setImage:[UIImage imageNamed:@"Publish"] forState:UIControlStateNormal];
    }
    else
    {
        _isPublished = YES;
        [PublishBtn setImage:[UIImage imageNamed:@"Published"] forState:UIControlStateNormal];
    }
}

//回到上一层Controller
- (IBAction)BackToRoot:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}
@end

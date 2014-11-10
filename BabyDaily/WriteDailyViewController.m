//
//  WriteDailyViewController.m
//  BabyDaily
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


@interface WriteDailyViewController () <UzysAssetsPickerControllerDelegate,CLLocationManagerDelegate,QiniuUploadDelegate>

@property (assign, nonatomic) CLLocationCoordinate2D *latestCoordinate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (assign, nonatomic) UIImage *willUploadImage;
@property (nonatomic, strong) DailyOne *daily;
@property (nonatomic) ASProgressPopUpView* myProgressView;
@property (nonatomic) BOOL isPublished;


@end

@implementation WriteDailyViewController

@synthesize strTtile;
@synthesize AllToken;
@synthesize PublishBtn;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //调试信息
    self.DText.text = strTtile;
    [self.DailyBody becomeFirstResponder];
    
     _daily = [[DailyOne alloc] init];
    _isPublished = NO;
    _daily.Weather = @"";
    _daily.Location = @"";
    
    
    _myProgressView = [[ASProgressPopUpView alloc]initWithFrame:CGRectMake(10.0f, 400.0f, 300.0f, 100.0f)];
    _myProgressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:26];
    _myProgressView.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
    _myProgressView.popUpViewCornerRadius = 16.0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

    //点击增加一张图片
- (IBAction)AddImg:(id)sender {
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = 1;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}
    //显示手机中照片集
- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    self.upLoadImg.backgroundColor = [UIColor clearColor];

    __weak typeof(self) weakSelf = self;
    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *representation = obj;
            
            UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullScreenImage];
            //weakSelf.upLoadImg.frame = CGRectMake(100.0f, 237.0f, 320.0f, img.size.height*320.0/img.size.width);
            
            
            weakSelf.willUploadImage = img;
            
            
            [weakSelf.AddImgBtn setBackgroundImage:img forState:UIControlStateNormal];
            
            
            *stop = YES;
        }];
        
        
    }
    
}


    //点击保存日记
- (IBAction)SaveDaily:(id)sender {
    
   
    
    _daily.User = @"Teddy";
    _daily.ID = @"1";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDate *now = [NSDate date];
    
    
    _daily.CreateDate = now;
    _daily.UpdateDate = now;

    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    _daily.UDID = idfv;
    _daily.Body = self.DailyBody.text;

    _daily.Tag = @"";
    if( self.willUploadImage == nil)
    {
        _daily.Image = @"";
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:_daily];
        [realm commitWriteTransaction];
        
        if(_isPublished)
        {
            [self PostDailyToWebServer:_daily];
        }

    }
    else
    {
        [self getToken:_daily];
    }
    
    
}
    //取得七牛空间Token
- (void)getToken:(DailyOne *) entity
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [self letSubmitBtnGone];
    [self.view addSubview:_myProgressView];
    [_myProgressView showPopUpViewAnimated:YES];
    
    
    [manager GET:@"http://teddylong.net/qiniu/GetTokenOnce.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);

        AllToken = [responseObject objectForKey:@"MyToken"];
        
        
        NSData *imageData = UIImagePNGRepresentation(self.willUploadImage);
        
        [self UploadImg: imageData:AllToken:entity];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}
    //上传图片并保存日记
-(void) UploadImg:(NSData *) uploaddata: (NSString *) token: (DailyOne *) entity
{
    
    QiniuSimpleUploader *newUpLoader = [QiniuSimpleUploader uploaderWithToken:token];
    newUpLoader.delegate = self;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    NSString *stringFromDate = [formatter stringFromDate:[[NSDate alloc]init]];
    NSString *filename = [stringFromDate stringByAppendingString:@".png"];
    
    [newUpLoader uploadFileData:uploaddata key:filename extra:nil];
    
    

}


- (IBAction)GetLocationWeather:(id)sender {
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager requestAlwaysAuthorization];
    [_locationManager requestWhenInUseAuthorization];
    
    [_locationManager startUpdatingLocation];
}

// Called when the location is updated
- (void)locationManager:(CLLocationManager *)locationManager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    [_locationManager stopUpdatingLocation];
    double longitude = newLocation.coordinate.longitude;
    double latitude = newLocation.coordinate.latitude;
    
    NSNumber *nlongitude = [NSNumber numberWithDouble:longitude];
    NSNumber *nlatitude = [NSNumber numberWithDouble:latitude];
    
    NSString *url = [[[@"http://api.openweathermap.org/data/2.5/weather?lat=" stringByAppendingString: [nlatitude stringValue]] stringByAppendingString:@"&lon="] stringByAppendingString:[nlongitude stringValue]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *countryDict = responseObject[@"sys"];
        NSString *country = countryDict[@"country"];
        NSDictionary *weatherDict = [responseObject[@"weather" ] firstObject];
        NSString *weather = weatherDict[@"description"];
        NSDictionary *tempDict = responseObject[@"main"];
        NSNumber *temp = tempDict[@"temp"];
        NSString *city = responseObject[@"name"];
        
        double cTemp = [temp doubleValue];
        NSInteger convertedValue =  ceil(cTemp - 273.15);
        
        _daily.Weather = [[[weather stringByAppendingString:@","] stringByAppendingString:[@(convertedValue) stringValue]] stringByAppendingString:@"°"];
        _daily.Location = [[country stringByAppendingString:@","] stringByAppendingString:city];
        
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
        
        
        
        
        NSLog(country);
        NSLog(weather);
        NSLog([temp stringValue]);
        NSLog(city);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];


}

- (void)locationManager:(CLLocationManager *)locationManager didFailWithError:(NSError *)error
{
    
}

// Progress updated. 1.0 indicates 100%.
- (void)uploadProgressUpdated:(NSString *)filePath percent:(float)percent
{
    _myProgressView.progress = percent;
}

// Upload completed successfully.
- (void)uploadSucceeded:(NSString *)filePath ret:(NSDictionary *)ret
{
    
    _myProgressView.progress = 1.0;
    [_myProgressView showPopUpViewAnimated:NO];
    _daily.Image = [@"http://babydaily.qiniudn.com/" stringByAppendingString:filePath];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:_daily];
    [realm commitWriteTransaction];
    // post to server
    if(_isPublished)
    {
        [self PostDailyToWebServer:_daily];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}

// Upload failed.
- (void)uploadFailed:(NSString *)filePath error:(NSError *)error
{
   
}

-(void)letSubmitBtnGone
{
    UIBarButtonItem *submitBtn = self.navigationItem.rightBarButtonItem;
    [submitBtn setEnabled:NO];
}

-(void)PostDailyToWebServer:(DailyOne *)entity
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

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
@end

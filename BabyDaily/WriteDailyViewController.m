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
#import "QiniuSDK.h"
#import <MapKit/MapKit.h>



@interface WriteDailyViewController () <UzysAssetsPickerControllerDelegate,CLLocationManagerDelegate>

@property (assign, nonatomic) CLLocationCoordinate2D *latestCoordinate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (assign, nonatomic) UIImage *willUploadImage;

@end

@implementation WriteDailyViewController

@synthesize strTtile;
@synthesize AllToken;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //调试信息
    self.DText.text = strTtile;
    
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
    
    DailyOne *d = [[DailyOne alloc] init];
    
    d.User = @"Teddy";
    d.ID = @"1";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    
    d.CreateDate = strDate;
    d.UpdateDate = strDate;
    d.Weather = @"Rain";
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    d.UDID = idfv;
    d.Body = self.DailyBody.text;
    d.Location = @"SH";
    d.Tag = @"";
    if( self.willUploadImage == nil)
    {
        d.Image = @"";
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:d];
        [realm commitWriteTransaction];
        
    }
    else
    {
        [self getToken:d];
    }
}
    //取得七牛空间Token
- (void)getToken:(DailyOne *) entity
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
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
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    NSString *stringFromDate = [formatter stringFromDate:[[NSDate alloc]init]];
    NSString *filename = [stringFromDate stringByAppendingString:@".png"];
    
    
    
    [upManager putData:uploaddata key:filename token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  entity.Image = [@"http://babydaily.qiniudn.com/" stringByAppendingString:filename];
                  
                  RLMRealm *realm = [RLMRealm defaultRealm];
                  [realm beginWriteTransaction];
                  [realm addObject:entity];
                  [realm commitWriteTransaction];
                  NSLog(@"%@", info);
                  NSLog(@"%@", resp);
                  
              } option:nil];
    
    
}


- (IBAction)GetWeatherBtn:(id)sender {
    
    //Get Location
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

@end

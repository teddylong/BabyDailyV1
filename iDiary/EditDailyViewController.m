//
//  EditDailyViewController.m
//  iDiary
//
//  Created by 龙 轶群 on 14/11/13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "EditDailyViewController.h"
#import "UIImageView+WebCache.h"
#import "UzysAssetsPickerController.h"
#import "DailyDetailViewController.h"
#import <Realm/Realm.h>

#import "QiniuUploadDelegate.h"
#import "ASPopUpView.h"
#import "ASProgressPopUpView.h"
#import "QiniuSimpleUploader.h"


@interface EditDailyViewController () <UzysAssetsPickerControllerDelegate,QiniuUploadDelegate>

@property (nonatomic) ASProgressPopUpView* myProgressView;
@property (nonatomic, strong) NSMutableData* receiveData;

@end

@implementation EditDailyViewController

@synthesize daily;
@synthesize AllToken;

bool isUpdateImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //初始设置
    isUpdateImage = NO;
    
    //设置进度条
    _myProgressView = [[ASProgressPopUpView alloc]initWithFrame:CGRectMake(0.0f, 65.0f, 320.0f, 10.0f)];
    _myProgressView.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
    _myProgressView.popUpViewCornerRadius = 16.0;
    
    //UITextView获得焦点
    [self.DailyBody becomeFirstResponder];
    //UITextView光标不居中，从第一行开始光标
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //显示Body
    UITextView *textView = (UITextView *)[self.view viewWithTag:1];
    textView.text = daily.Body;
    
    //显示Image
    NSString *tempString = [daily.Image stringByAppendingString:@"?imageView2/1/w/200/h/200"];
    [self.dailyImage sd_setImageWithURL:[[NSURL alloc] initWithString: tempString]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//点击更换图片按钮
- (IBAction)changeImage:(id)sender {
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

//点击编辑完成按钮
- (IBAction)editDone:(id)sender
{
    //如果有图片的情况下，先上传图片再更新
    if(isUpdateImage)
    {
        [self getToken:daily];
    }
    //只更新文字
    else
    {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        daily.Body = self.DailyBody.text;
        [realm commitWriteTransaction];
        
        //如果已经上传到广场，更新广场中此Daiy信息
        if([daily.Tag isEqual:@"YES"])
        {
            [self UpdateDailyToWebServer:daily];
        }

        //返回Detail页面
        DailyDetailViewController *detailViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        detailViewController.daily = daily;
        [self.navigationController popToViewController:detailViewController animated:YES];
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
        NSData *imageData = UIImagePNGRepresentation(self.dailyImage.image);
        [self UploadImg:imageData:AllToken:entity];
        
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
    
    //更新数据库数据
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    daily.Image = [@"http://babydaily.qiniudn.com/" stringByAppendingString:filePath];
    daily.Body = self.DailyBody.text;
    [realm commitWriteTransaction];
    
    //是否更新到广场
    if([daily.Tag isEqual:@"YES"])
    {
        [self UpdateDailyToWebServer:daily];
    }
    
    //返回Detail页面
    DailyDetailViewController *detailViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    detailViewController.daily = daily;
    [self.navigationController popToViewController:detailViewController animated:YES];
}

//上传失败
- (void)uploadFailed:(NSString *)filePath error:(NSError *)error
{
    //返回Detail页面
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//更新到广场
-(void)UpdateDailyToWebServer:(DailyOne *)entity
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
                                 @"Weather": entity.Weather,
                                 @"ID": entity.ID};
    
    [manager POST:@"http://teddylong.net/BabyDaily/UpdateEntity.php" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//显示并选择手机中照片
- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    __weak typeof(self) weakSelf = self;
    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *representation = obj;
            
            //获取到选择照片
            UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullScreenImage];
            weakSelf.dailyImage.image = img;
            
            //照片已更新状态
            isUpdateImage = YES;
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
//Cancel按钮回到Detail页面，无更改
- (IBAction)BackToRoot:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

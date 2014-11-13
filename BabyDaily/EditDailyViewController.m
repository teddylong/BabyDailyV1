//
//  EditDailyViewController.m
//  BabyDaily
//
//  Created by Ctrip on 14/11/13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "EditDailyViewController.h"
#import "UIImageView+WebCache.h"
#import "UzysAssetsPickerController.h"


@interface EditDailyViewController () <UzysAssetsPickerControllerDelegate>

@end

@implementation EditDailyViewController

@synthesize daily;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.DailyBody becomeFirstResponder];
    //self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITextView *textView = (UITextView *)[self.view viewWithTag:1];
    textView.text = daily.Body;
    
    
    NSString *tempString = [daily.Image stringByAppendingString:@"?imageView2/1/w/200/h/200"];
    [self.dailyImage sd_setImageWithURL:[[NSURL alloc] initWithString: tempString]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)changeImage:(id)sender {
    
    //取消textbox的第一响应
    [self.DailyBody resignFirstResponder];
    //启动Image Picker
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = 1;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
    
}

- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    //self.upLoadImg.backgroundColor = [UIColor clearColor];
    
    __weak typeof(self) weakSelf = self;
    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *representation = obj;
            
            UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullScreenImage];
            //weakSelf.upLoadImg.frame = CGRectMake(100.0f, 237.0f, 320.0f, img.size.height*320.0/img.size.width);
            [weakSelf.DailyBody becomeFirstResponder];
            
            weakSelf.dailyImage.image = img;
            
            //[weakSelf.AddImgBtn setBackgroundImage:img forState:UIControlStateNormal];
            //[weakSelf.AddImgBtn setFrame:CGRectMake(45, 285, 50, 25)];
            *stop = YES;
        }];
    }
    //textbox获取第一响应，弹出键盘
    BOOL isFirst = [weakSelf.DailyBody canBecomeFirstResponder];
    if(isFirst)
    {
        [weakSelf.DailyBody becomeFirstResponder];
    }
}
@end

//
//  TestV2ControllerViewController.m
//  BabyDaily
//
//  Created by 龙 轶群 on 14-11-15.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "TestV2ControllerViewController.h"
#import "TestViewController.h"
#import "User.h"
#import <Realm/Realm.h>
#import "PAImageView.h"
#import "UzysAssetsPickerController.h"

@interface TestV2ControllerViewController () <UzysAssetsPickerControllerDelegate>

@property (nonatomic,strong)PAImageView *avatarView;
@property (nonatomic,strong)UIImage *tempImage;


@end

@implementation TestV2ControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *tempImage = (UIImageView *)[self.view viewWithTag:1];
    
    
    _avatarView = [[PAImageView alloc] initWithFrame:tempImage.frame backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
    [self.view addSubview:_avatarView];
    _avatarView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(PAClicked:)];
    
    [_avatarView addGestureRecognizer:singleTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) PAClicked:(UIGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"asdasd");
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
    
    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *representation = obj;
            
            //获取到选择照片
            UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullScreenImage];
            _tempImage = img;
            //显示照片到背景中
            [_avatarView setImage:img];
            
            *stop = YES;
        }];
    }
}

- (IBAction)editDone:(id)sender {
    
    User *user = [[User alloc] init];
    user.UserName = self.myTextField.text;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"UserImage.png"]];   // 保存文件的名称
    BOOL result = [UIImagePNGRepresentation(_tempImage) writeToFile: filePath    atomically:YES];
    if(result)
    {
        user.UserImageName = filePath;
    }
    
    
    RLMRealm * realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:user];
    [realm commitWriteTransaction];
    
    TestViewController *detailViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    detailViewController.DataLabel.text = self.myTextField.text;
    
    NSArray *getPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *getFilePath = [[getPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"UserImage.png"]];
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end

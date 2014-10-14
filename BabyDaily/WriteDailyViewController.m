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



@interface WriteDailyViewController () <UzysAssetsPickerControllerDelegate>




@end

@implementation WriteDailyViewController

@synthesize strTtile;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.DText.text = strTtile;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)AddImg:(id)sender {
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = 1;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    self.upLoadImg.backgroundColor = [UIColor clearColor];

    __weak typeof(self) weakSelf = self;
    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *representation = obj;
            
            UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullResolutionImage
                                               scale:representation.defaultRepresentation.scale
                                         orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
            weakSelf.upLoadImg.image = img;
            *stop = YES;
        }];
        
        
    }
    
}

- (IBAction)SaveDaily:(id)sender {
    
    DailyOne *d = [[DailyOne alloc] init];
    
    d.User = @"Teddy";
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    d.CreateDate = dateString;
    d.Body = self.DailyBody.text;
    
    NSData *imageData = UIImagePNGRepresentation(self.upLoadImg.image);
    NSString *testString = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
    d.Image = @"";

    RLMRealm *realm = [RLMRealm defaultRealm];
    
    
    [realm beginWriteTransaction];
    [realm addObject:d];
    [realm commitWriteTransaction];
}




@end

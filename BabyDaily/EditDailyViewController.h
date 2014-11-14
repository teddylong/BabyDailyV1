//
//  EditDailyViewController.h
//  BabyDaily
//
//  Created by Ctrip on 14/11/13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyOne.h"

@interface EditDailyViewController : UIViewController

@property (nonatomic, strong) DailyOne *daily;

- (IBAction)changeImage:(id)sender;

-(IBAction)editDone:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *changImgBtn;
@property (weak, nonatomic) IBOutlet UITextView *DailyBody;
@property (weak, nonatomic) IBOutlet UIImageView *dailyImage;

@end

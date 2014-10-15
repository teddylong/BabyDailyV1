//
//  DailyDetailViewController.h
//  BabyDaily
//
//  Created by Ctrip on 14-10-15.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyOne.h"

@interface DailyDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *BigImage;
@property (weak, nonatomic) IBOutlet UITextView *BigBody;

@property (nonatomic, strong) DailyOne *daily;
@end

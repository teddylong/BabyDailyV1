//
//  DailyDetailViewController.h
//  BabyDaily
//
//  Created by Ctrip on 14-10-15.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyOne.h"
//#import "PAImageView.h"
#import "AsyncImageView.h"

@interface DailyDetailViewController : UIViewController
{
    IBOutlet UIScrollView *scrollView;
    AsyncImageView *BigImage;
    UITextView *BigText;
}

@property (nonatomic, strong) DailyOne *daily;

@end

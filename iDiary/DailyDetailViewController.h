//
//  DailyDetailViewController.h
//  iDiary
//
//  Created by 龙 轶群 on 14-10-15.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyOne.h"
//#import "PAImageView.h"
#import "AsyncImageView.h"
#import <Realm/Realm.h>

@interface DailyDetailViewController : UIViewController
{
    IBOutlet UIScrollView *scrollView;
    AsyncImageView *BigImage;
    UITextView *BigText;
    UIView *SmallView;
}

@property (nonatomic, strong) DailyOne *daily;
@property (nonatomic,strong) RLMNotificationToken *notification;
@end

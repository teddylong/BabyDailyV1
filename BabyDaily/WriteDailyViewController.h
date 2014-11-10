//
//  WriteDailyViewController.h
//  BabyDaily
//
//  Created by 龙 轶群 on 14-10-13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WriteDailyViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *DText;
@property (weak, nonatomic) IBOutlet UIButton *AddImgBtn;
- (IBAction)AddImg:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *upLoadImg;
- (IBAction)SaveDaily:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *DailyBody;
@property(nonatomic,weak)NSString *strTtile;

- (IBAction)GetLocationWeather:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *GetWeatherBtn;
@property(nonatomic, weak) NSString *AllToken;
- (IBAction)ClickPublish:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *PublishBtn;
@end

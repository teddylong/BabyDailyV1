//
//  WriteDailyViewController.h
//  iDiary
//
//  Created by 龙 轶群 on 14-10-13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WriteDailyViewController : UIViewController<NSURLConnectionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *DText;
@property (weak, nonatomic) IBOutlet UIButton *AddImgBtn;
- (IBAction)AddImg:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *upLoadImg;
- (IBAction)SaveDaily:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *DailyBody;


- (IBAction)GetLocationWeather:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *GetWeatherBtn;
@property(nonatomic, weak) NSString *AllToken;
- (IBAction)ClickPublish:(id)sender;
- (IBAction)BackToRoot:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *PublishBtn;
@end
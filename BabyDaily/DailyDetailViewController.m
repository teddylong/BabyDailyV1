//
//  DailyDetailViewController.m
//  BabyDaily
//
//  Created by Ctrip on 14-10-15.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//


#import "DailyDetailViewController.h"
//#import "PAImageView.h"
#import "AsyncImageView.h"
#import "EditDailyViewController.h"



@implementation DailyDetailViewController

@synthesize daily;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goEdit"])
    {
        EditDailyViewController *editDaily = segue.destinationViewController;
        
        editDaily.daily = daily;
        
    }
    
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Set realm notification block
    __weak typeof(self) weakSelf = self;
    
    
    
    self.notification = [RLMRealm.defaultRealm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [realm refresh];
        realm.autorefresh = YES;
        [self ProcessPage];
        
    }];

    [self ProcessPage];
    
    
}

-(void)ProcessPage
{
    //加载Scroll VIew
    scrollView = (UIScrollView *)[self.view viewWithTag:99];
    
    //加载大图片
    BigImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:BigImage];
    
    BigImage.contentMode =UIViewContentModeScaleAspectFill;
    
    if([daily.Image isEqual:@""])
    {
        BigImage.image = nil;
        
        CGRect frame = BigImage.frame;
        frame.size.height = 0;
        
        BigImage.frame = frame;
        
    }
    else
    {
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:BigImage];
        BigImage.imageURL = [[NSURL alloc] initWithString:daily.Image];
    }
    
    
    //加载Small View
    SmallView = (UIView*)[self.view viewWithTag:200];
    
    CGRect smallViewFrame = CGRectMake(0, BigImage.frame.size.height, 320, 60);
    SmallView.frame = smallViewFrame;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    UILabel *dateLabel = (UILabel *)[SmallView viewWithTag:201];
    dateLabel.text = [dateFormatter stringFromDate:daily.CreateDate];
    
    if(dateLabel.text == (NSString*)nil)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *now2 = daily.CreateDate;
        NSString *tempTime = (NSString *)now2;
        NSDate *now3 = [dateFormatter dateFromString:tempTime];
        
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate: now3];
        NSDate *localeDate = [now3 dateByAddingTimeInterval: interval];
        
        dateLabel.text = [dateFormatter stringFromDate:localeDate];
    }
    
    UILabel *tempLabel = (UILabel *)[SmallView viewWithTag:203];
    tempLabel.text = daily.Weather;
    
    UILabel *locationLabel = (UILabel *)[SmallView viewWithTag:204];
    locationLabel.text = daily.Location;
    
    if([tempLabel.text isEqual: @""] || [locationLabel.text isEqual: @""])
    {
        CGRect smallViewFrame = CGRectMake(0, BigImage.frame.size.height, 320, 30);
        SmallView.frame = smallViewFrame;
    }
    else
    {
        UIImageView* weatherImage = (UIImageView *)[SmallView viewWithTag:210];
        
        if([tempLabel.text containsString:@"mist"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Fog"];
        }
        else if ([tempLabel.text containsString:@"Clear"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Sun"];
        }
        else if ([tempLabel.text containsString:@"rain"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Rain"];
        }
        else if ([tempLabel.text containsString:@"clouds"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Clouds"];
        }
        else if ([tempLabel.text containsString:@"hail"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Hail"];
        }
        else if ([tempLabel.text containsString:@"thunderstorm"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Storm"];
        }
        else if ([tempLabel.text containsString:@"snow"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Snow"];
        }
        else if ([tempLabel.text containsString:@"haze"])
        {
            weatherImage.image =  [UIImage imageNamed:@"Fog"];
        }
    }
    
    //加载Body详细
    BigText = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, BigImage.frame.size.height + SmallView.frame.size.height + 10, 320.0f, 200.0f)];
    BigText.text = daily.Body;
    [BigText setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    
    double height = 0.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        CGRect textFrame=[[BigText layoutManager]usedRectForTextContainer:[BigText textContainer]];
        height = textFrame.size.height;
        
    }else {
        
        height = BigText.contentSize.height;
    }
    
    
    
    [scrollView addSubview:BigImage];
    
    [scrollView addSubview:SmallView];
    
    [scrollView addSubview:BigText];
    
    
    [BigText setFrame:CGRectMake(0.0f, BigImage.frame.size.height + SmallView.frame.size.height, 320.0f, height + 50.0f)];
    BigText.scrollEnabled = NO;
    
    CGSize newSize = CGSizeMake(self.view.frame.size.width, BigImage.frame.size.height + BigText.frame.size.height + SmallView.frame.size.height + 50.0f);
    
    if(newSize.height < 568.0)
    {
        newSize = CGSizeMake(self.view.frame.size.width, 600.0);
    }
    
    [scrollView setContentSize:newSize];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

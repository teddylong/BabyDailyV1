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
    UIView *smallView = [self.view viewWithTag:200];
    
    CGRect smallViewFrame = CGRectMake(0, BigImage.frame.size.height, 320, 60);
    smallView.frame = smallViewFrame;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    UILabel *dateLabel = (UILabel *)[smallView viewWithTag:201];
    dateLabel.text = [dateFormatter stringFromDate:daily.CreateDate];
    
    if(dateLabel.text == (NSString*)nil)
    {
        //dateLabel.text = (NSString*)daily.CreateDate;
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
    
    UILabel *tempLabel = (UILabel *)[smallView viewWithTag:203];
    tempLabel.text = daily.Weather;
    
    UILabel *locationLabel = (UILabel *)[smallView viewWithTag:204];
    locationLabel.text = daily.Location;
    
    if([tempLabel.text isEqual: @""] || [locationLabel.text isEqual: @""])
    {
        CGRect smallViewFrame = CGRectMake(0, BigImage.frame.size.height, 320, 30);
        smallView.frame = smallViewFrame;
    }
    
    
    
    
    //加载Body详细
    BigText = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, BigImage.frame.size.height + smallView.frame.size.height + 10, 320.0f, 200.0f)];
    BigText.text = daily.Body;
    
    double height = 0.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        CGRect textFrame=[[BigText layoutManager]usedRectForTextContainer:[BigText textContainer]];
        height = textFrame.size.height;
        
    }else {
        
        height = BigText.contentSize.height;
    }
    
    
    
    [scrollView addSubview:BigImage];
    
    [scrollView addSubview:smallView];

    [scrollView addSubview:BigText];
    
    
    [BigText setFrame:CGRectMake(0.0f, BigImage.frame.size.height + smallView.frame.size.height, 320.0f, height + 50.0f)];
    BigText.scrollEnabled = NO;
    
    CGSize newSize = CGSizeMake(self.view.frame.size.width, BigImage.frame.size.height + BigText.frame.size.height + smallView.frame.size.height + 50.0f);
    
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

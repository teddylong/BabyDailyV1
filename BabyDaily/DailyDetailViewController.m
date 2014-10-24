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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(imageLoaded:)
//                                                 name:AsyncImageLoadDidFinish
//                                               object:nil];
    
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
   
    
    //加载Body详细
    BigText = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, BigImage.frame.size.height + 10, 320.0f, 200.0f)];
    BigText.text = daily.Body;
    
    double height = 0.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        CGRect textFrame=[[BigText layoutManager]usedRectForTextContainer:[BigText textContainer]];
        height = textFrame.size.height;
        
    }else {
        
        height = BigText.contentSize.height;
    }
    
    
    
    [scrollView addSubview:BigImage];

    [scrollView addSubview:BigText];
    
    
    [BigText setFrame:CGRectMake(0.0f, BigImage.frame.size.height, 320.0f, height + 50.0f)];
    BigText.scrollEnabled = NO;
    
    CGSize newSize = CGSizeMake(self.view.frame.size.width, BigImage.frame.size.height + BigText.frame.size.height + 50.0f);
    
    if(newSize.height < 568.0)
    {
        newSize = CGSizeMake(self.view.frame.size.width, 600.0);
    }
    
    [scrollView setContentSize:newSize];

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

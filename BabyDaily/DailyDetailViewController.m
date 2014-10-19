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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageLoaded:)
                                                 name:AsyncImageLoadDidFinish
                                               object:nil];
    
    //加载Scroll VIew
    scrollView = (UIScrollView *)[self.view viewWithTag:99];
    
    //加载大图片
    BigImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 200.0f)];
    
    
    BigImage.contentMode =UIViewContentModeScaleAspectFit;
    BigImage.clipsToBounds = YES;
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:BigImage];
    if([daily.Image isEqual:@""])
    {
        BigImage.image = nil;
        
        CGRect frame = BigImage.frame;
        frame.size.height = 0;
        
        BigImage.frame = frame;
        
    }
    else
    {
        BigImage.imageURL = [[NSURL alloc] initWithString:daily.Image];
        
        //取消cache
        [AsyncImageLoader sharedLoader].cache = nil;
    }
   
    
    //加载Body详细
    BigText = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, BigImage.frame.size.height + 10, 320.0f, 200.0f)];
    BigText.text = daily.Body;
    
    
    CGSize newSize = CGSizeMake(self.view.frame.size.width, BigImage.frame.size.height + BigText.frame.size.height+20);
    
    [scrollView setContentSize:newSize];

    [scrollView addSubview:BigText];
    [scrollView addSubview:BigImage];

}
    //异步加载Image
- (void)imageLoaded:(NSNotification *)notification
{
    
    BigImage = notification.object;
    
    [BigImage setFrame:CGRectMake(0.0f, 0.0f, 320.0f, BigImage.image.size.height*320.0/BigImage.image.size.width)];
    
    
    [BigText setFrame:CGRectMake(0.0f, BigImage.frame.size.height, 320.0f, BigText.contentSize.height)];
    
    CGRect frame = BigText.frame;
    frame.size.height = BigText.contentSize.height;
    BigText.frame = frame;

    [scrollView addSubview:BigImage];
    [scrollView addSubview:BigText];
    
    CGSize newSize = CGSizeMake(self.view.frame.size.width, BigText.frame.size.height+ + BigImage.frame.size.height + 50);
    [scrollView setContentSize:newSize];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

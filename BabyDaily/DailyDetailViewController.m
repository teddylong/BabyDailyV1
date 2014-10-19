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
@synthesize BigBody;
@synthesize BigAsyncImg;

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
    //加载Body详细
    BigBody.text = daily.Body;
    //加载大图片
    AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0.0f, 80.0f, 320.0f, 200.0f)];
    imageView.contentMode =UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imageView];
    imageView.imageURL = [[NSURL alloc] initWithString:daily.Image];
    //调整大图片背景大小
    imageView.frame = CGRectMake(0.0f, 80.0f, 320.0f, imageView.image.size.height*320.0/imageView.image.size.width);
    
    //调试信息
    //NSString *stringFloat = [NSString stringWithFormat:@"%f",imageView.image.size.width];
    //NSLog(stringFloat);

    [self.view addSubview:imageView];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

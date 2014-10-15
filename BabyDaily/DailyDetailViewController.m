//
//  DailyDetailViewController.m
//  BabyDaily
//
//  Created by Ctrip on 14-10-15.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "DailyDetailViewController.h"

@implementation DailyDetailViewController

@synthesize daily;
@synthesize BigBody;
@synthesize BigImage;

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
    // Do any additional setup after loading the view.
    
    
    BigBody.text = daily.Body;
    NSData *reader = [NSData dataWithContentsOfFile:daily.Image];
    BigImage.image = [UIImage imageWithData:reader];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

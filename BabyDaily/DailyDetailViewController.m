//
//  DailyDetailViewController.m
//  BabyDaily
//
//  Created by Ctrip on 14-10-15.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "DailyDetailViewController.h"
#import "PAImageView.h"

@implementation DailyDetailViewController

@synthesize daily;
@synthesize BigBody;
@synthesize cirImg;

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
    
    cirImg = [[PAImageView alloc] initWithFrame:CGRectMake(80.0f, 80.0f, 200.0f, 200.0f) backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
    [self.view addSubview:cirImg];
    [cirImg setImageURL:[[NSURL alloc] initWithString:daily.Image]];
    BigBody.text = daily.Body;
   
    
//    UIImage *asdasd = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:daily.Image]]];
//    
//    BigImage.image = asdasd;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  WriteDailyViewController.m
//  BabyDaily
//
//  Created by 龙 轶群 on 14-10-13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "WriteDailyViewController.h"

@interface WriteDailyViewController ()

@end

@implementation WriteDailyViewController

@synthesize strTtile;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.DText.text = strTtile;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end

//
//  FirstViewController.m
//  BabyDaily
//
//  Created by Ctrip on 14-10-13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "FirstViewController.h"
#import "NewView.h"

@interface FirstViewController ()


@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToNext:(id)sender {
    NewView *secView = [[NewView alloc]init];
    [self.navigationController pushViewController:secView animated:YES];
    secView.title = @"Sec View";
}
@end

//
//  FirstViewController.m
//  BabyDaily
//
//  Created by Ctrip on 14-10-13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "FirstViewController.h"
#import "WriteDailyViewController.h"

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

//- (IBAction)goToNext:(id)sender {
    //WriteDailyViewController *temp = [[WriteDailyViewController alloc] init];
    //temp.DText.text = self.testText.text;
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goNext"]) //"goView2"是SEGUE连线的标识
    {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:@"这里是要传递的值" forKey:@"strTtile"];
    }
}
@end

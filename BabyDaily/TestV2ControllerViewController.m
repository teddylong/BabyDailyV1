//
//  TestV2ControllerViewController.m
//  BabyDaily
//
//  Created by 龙 轶群 on 14-11-15.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "TestV2ControllerViewController.h"
#import "TestViewController.h"

@interface TestV2ControllerViewController ()

@end

@implementation TestV2ControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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


- (IBAction)editDone:(id)sender
{
    TestViewController *detailViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    detailViewController.DataLabel.text = self.myTextField.text;
    //    [detailViewController setHidesBottomBarWhenPushed:YES];
    //[self.navigationController pushViewController:detailViewController animated:YES];
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController popToViewController:detailViewController animated:YES];

}
@end

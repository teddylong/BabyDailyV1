//
//  FirstViewController.h
//  BabyDaily
//
//  Created by Ctrip on 14-10-13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
//- (IBAction)goToNext:(id)sender;
//@property (weak, nonatomic) IBOutlet UILabel *testText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


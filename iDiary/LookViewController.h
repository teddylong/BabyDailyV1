//
//  LookViewController.h
//  iDiary
//
//  Created by 龙 轶群 on 14/10/28.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LookViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

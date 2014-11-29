//
//  TestViewController.h
//  iDiary
//
//  Created by 龙 轶群 on 14-10-25.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UISearchController *myUISearchDisplayController;
@property (weak, nonatomic) IBOutlet UILabel *DataLabel;
@property (weak, nonatomic) IBOutlet UIImageView *DataImage;


@end

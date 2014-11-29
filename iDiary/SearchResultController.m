//
//  SearchResultController.m
//  iDiary
//
//  Created by 龙 轶群 on 14-11-12.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "SearchResultController.h"
#import "DailyOne.h"
#import "UIImageView+WebCache.h"

@interface SearchResultController ()

@end

@implementation SearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellReuseIdentifier:@"SearchResultCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dailys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DailyOne *object = self.dailys[indexPath.row];
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    UILabel* bodyLabel = (UILabel *)[cell.contentView viewWithTag:2];
    bodyLabel.text = object.Body;
    
    
    
    NSDate *now2 = object.CreateDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    
    
    UILabel* dailyDateLabel = (UILabel *)[cell.contentView viewWithTag:3];
    dailyDateLabel.text = [dateFormatter stringFromDate:now2];
    
    
    
    UIImageView *viewImage = (UIImageView *)[cell.contentView viewWithTag:1];
    NSString *tempString = [object.Image stringByAppendingString:@"?imageView2/1/w/200/h/200"];
    
    CALayer *layer = [viewImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:5.0f];
    
    [viewImage sd_setImageWithURL:[[NSURL alloc] initWithString: tempString]];
    
    return cell;
}


@end

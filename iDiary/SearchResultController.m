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
    
    //重用Tabel Cell （定义为TabelCell.xib）
    [self.tableView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellReuseIdentifier:@"SearchResultCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//返回搜索列表中日记的数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dailys.count;
}

//显示搜索列表日记信息
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //构建Cell
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //根据日记路径取得日记
    DailyOne *object = self.dailys[indexPath.row];
    
    //把日记信息显示在Cell中
    //1. 显示Body
    UILabel* bodyLabel = (UILabel *)[cell.contentView viewWithTag:2];
    bodyLabel.text = object.Body;
    
    //2. 显示日期
    NSDate *now2 = object.CreateDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    UILabel* dailyDateLabel = (UILabel *)[cell.contentView viewWithTag:3];
    dailyDateLabel.text = [dateFormatter stringFromDate:now2];
    
    //4. 显示图片
    UIImageView *viewImage = (UIImageView *)[cell.contentView viewWithTag:1];
    NSString *tempString = [object.Image stringByAppendingString:@"?imageView2/1/w/200/h/200"];
    
    //设置图片圆角
    CALayer *layer = [viewImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:5.0f];
    
    //异步显示图片
    [viewImage sd_setImageWithURL:[[NSURL alloc] initWithString: tempString]];
    
    //返回Cell
    return cell;
}

@end

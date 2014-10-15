//
//  FirstViewController.m
//  BabyDaily
//
//  Created by Ctrip on 14-10-13.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import "FirstViewController.h"
#import "WriteDailyViewController.h"
#import "DailyOne.h"
#import <Realm/Realm.h>
#import "DailyDetailViewController.h"

static NSString * const kCellID    = @"cell";
static NSString * const kTableName = @"table";

@interface FirstViewController ()

@property (nonatomic, strong) RLMArray *array;
@property (assign, nonatomic) NSInteger selectedRow;
@property (nonatomic, strong) RLMNotificationToken *notification;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Set realm notification block
    __weak typeof(self) weakSelf = self;
    
    self.notification = [RLMRealm.defaultRealm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf reloadData];
    }];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goNext"])
    {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:@"这里是要传递的值" forKey:@"strTtile"];
    }
    if([segue.identifier isEqualToString:@"goDetail"])
    {
        DailyDetailViewController *dailyDetail = segue.destinationViewController;
        dailyDetail.daily = self.array[_selectedRow];
        
    }
    self.hidesBottomBarWhenPushed = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    self.hidesBottomBarWhenPushed = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = [indexPath row];
    return indexPath;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"cell"];
    }
    
    DailyOne *object = self.array[indexPath.row];
    
    UILabel* bodyLabel = (UILabel *)[cell.contentView viewWithTag:1];
    bodyLabel.text = object.Body;
    
    UILabel* timeLabel = (UILabel *)[cell.contentView viewWithTag:2];
    timeLabel.text = object.CreateDate;
    
    UIImageView *imageAtt = (UIImageView *)[cell.contentView viewWithTag:3];
    
    
    UIImage *asdasd = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:object.Image]]];
    
    imageAtt.image = asdasd;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RLMRealm *realm = RLMRealm.defaultRealm;
        [realm beginWriteTransaction];
        [realm deleteObject:self.array[indexPath.row]];
        [realm commitWriteTransaction];
    }
}
//-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    DailyOne *object = self.array[indexPath.row];
//    
//    DailyDetailViewController *detailC = [[DailyDetailViewController alloc]init];
//    detailC.BigBody.text = object.Body;
//    NSData *reader = [NSData dataWithContentsOfFile:object.Image];
//    detailC.BigImage.image = [UIImage imageWithData:reader];
//}

#pragma mark - Actions

- (void)reloadData
{
    self.array = [[DailyOne allObjects] arraySortedByProperty:@"CreateDate" ascending:NO];
    [self.tableView reloadData];
}
@end

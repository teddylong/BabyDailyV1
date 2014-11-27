//
//  SearchResultController.h
//  BabyDaily
//
//  Created by 龙 轶群 on 14-11-12.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Realm/Realm.h"

@interface SearchResultController : UITableViewController

@property (nonatomic, strong) RLMArray *dailys;

@end

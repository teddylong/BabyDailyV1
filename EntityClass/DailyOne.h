//
//  DailyOne.h
//  BabyDaily
//
//  Created by Ctrip on 14-10-14.
//  Copyright (c) 2014年 Ctrip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface DailyOne : RLMObject

@property NSString *ID;
@property NSDate *CreateDate;
@property NSString *User;
@property NSString *Body;
@property NSString *Weather;
@property NSString *Image;
@property NSString *Location;
@property NSDate *UpdateDate;
@property NSString *Tag;
@property NSString *UDID;
//@property NSInteger *Publish;

@end

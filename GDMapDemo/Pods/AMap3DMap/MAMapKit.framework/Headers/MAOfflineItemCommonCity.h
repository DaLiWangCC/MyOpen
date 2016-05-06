//
//  MAOfflineItemCommonCity.h
//  MapKit_static
//
//  Created by songjian on 14-4-23.
//  Copyright (c) 2014年 songjian. All rights reserved.
//

#import "MAOfflineCity.h"

/* 普通城市. */
@interface MAOfflineItemCommonCity : MAOfflineCity

/*!
 @brief 所属省份
 */
@property (nonatomic, weak) MAOfflineItem *province;


@end

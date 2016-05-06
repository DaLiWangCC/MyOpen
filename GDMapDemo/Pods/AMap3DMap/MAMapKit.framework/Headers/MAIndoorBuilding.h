//
//  MAIndoorBuilding.h
//  MAMapKit
//
//  Created by 翁乐 on 2/23/16.
//  Copyright © 2016 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  室内地图信息
 */
@interface MAIndoorBuilding : NSObject

///楼层名
@property (nonatomic, readonly, copy) NSString *floorName;

///楼层数
@property (nonatomic, readonly, assign) NSInteger floor;

///楼块名（中文名）
@property (nonatomic, readonly, copy) NSString *buildingName;

///楼块ID
@property (nonatomic, readonly, copy) NSString *poiID;

///楼层总数
@property (nonatomic, readonly, assign) NSInteger numberOfFloor;

@end

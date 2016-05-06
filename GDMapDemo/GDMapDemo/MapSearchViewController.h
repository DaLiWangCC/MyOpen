//
//  MapSearchViewController.h
//  CatEyesDemo
//
//  Created by wanghao on 16/4/29.
//  Copyright © 2016年 wanghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

typedef void(^moveBlock)(AMapPOI *location);
@interface MapSearchViewController : UIViewController

@property (nonatomic,retain) MAUserLocation *currentLocation;//当前位置

@property (nonatomic,retain) NSString *currentCity;//当前参数

@property (nonatomic,copy) moveBlock moveBlock;

@property (nonatomic,retain) NSString *searchStr;//搜索的内容

@end

//
//  MapViewController.h
//  CatEyesDemo
//
//  Created by wanghao on 16/4/29.
//  Copyright © 2016年 wanghao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>



@interface MapViewController : UIViewController

@property (nonatomic,retain) MAMapView *mapView;

@property (nonatomic,retain) MAUserLocation *currentLocation;
@property (nonatomic,retain) AMapPOI *currentPOI;

@property (nonatomic,retain) MAPointAnnotation *destinationPoint;//目标点

@end

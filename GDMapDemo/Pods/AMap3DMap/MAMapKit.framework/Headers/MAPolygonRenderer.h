//
//  MAPolygonRenderer.h
//  MAMapKit
//
//  
//  Copyright (c) 2011年 Autonavi Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MAPolygon.h"
#import "MAOverlayPathRenderer.h"

/*!
 @brief 此类用于绘制MAPolygon,可以通过MAOverlayPathRenderer修改其fill和stroke attributes
 */
@interface MAPolygonRenderer : MAOverlayPathRenderer

/*!
 @brief 根据指定的多边形生成一个多边形Renderer
 @param polygon 指定的多边形数据对象
 @return 新生成的多边形Renderer
 */
- (instancetype)initWithPolygon:(MAPolygon *)polygon;

/*!
 @brief 关联的MAPolygon model
 */
@property (nonatomic, readonly) MAPolygon *polygon;

@end
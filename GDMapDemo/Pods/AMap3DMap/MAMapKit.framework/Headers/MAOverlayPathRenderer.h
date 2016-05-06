//
//  MAOverlayPathRenderer.h
//  MAMapKit
//
//
//  Copyright (c) 2011年 Autonavi Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAOverlayRenderer.h"

/*!
 @brief 该类设置overlay绘制的属性，可以使用该类的子类MACircleRenderer, MAPolylineRenderer, MAPolygonRenderer或者继承该类
 */
@interface MAOverlayPathRenderer : MAOverlayRenderer

/*!
 @brief 填充颜色,默认是kMAOverlayRendererDefaultFillColor
 */
@property (retain) UIColor *fillColor;

/*!
 @brief 笔触颜色,默认是kMAOverlayRendererDefaultStrokeColor
 */
@property (retain) UIColor *strokeColor;

/*!
 @brief 笔触宽度,默认是0
 */
@property CGFloat lineWidth;

/*!
 @brief LineJoin,默认是kMALineJoinBevel
 */
@property MALineJoinType lineJoinType;

/*!
 @brief LineCap,默认是kMALineCapButt
 */
@property MALineCapType lineCapType;

/*!
 @brief MiterLimit,默认是10.f
 */
@property CGFloat miterLimit;

/*!
 @brief 是否绘制成虚线, 默认是NO
 */
@property BOOL lineDash;


@end

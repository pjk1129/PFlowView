//
//  PFlowView.h
//  PFlowView
//
//  Created by JK.Peng on 13-9-12.
//  Copyright (c) 2013年 njut. All rights reserved.
//

/*
 1.如果锯齿明显需要抗锯齿效果，在项目plist文件中配置Renders with edge antialisasing为YES
 2.需要往项目中添加 QuartzCore.framework 框架， 才能正确运行
 
 PFlowView目的志在为业内初学者提供一种图片浏览效果的思路，在这个小demo开发过程中，
 不可避免可能会有雷同之处，在README.md中Reference处有该工程参考和使用的一些开源项目。
 另外，希望更多的网友，能对此加工，优化代码，修复潜在的bug。
 
 欢迎大家技术/业内动态交流！
*/

#import <UIKit/UIKit.h>
#import "PFlowViewCell.h"

@protocol PFlowViewDataSource, PFlowViewDelegate;

@interface PFlowView : UIView

@property (nonatomic, assign) id<PFlowViewDelegate>    delegate;
@property (nonatomic, assign) id<PFlowViewDataSource>  dataSource;

@property (nonatomic, retain) UIColor  *borderColor;          //边框颜色，可以为空

@property (nonatomic, assign) CGFloat    zMarginValue;        //图片之间z方向的间距值，越小间距越大,默认值为5.0f，不能为0
@property (nonatomic, assign) CGFloat    xMarginValue;        //图片之间x方向的间距值，越小间距越大,默认值为10.0f，不能为0
@property (nonatomic, assign) CGFloat    angleValue;          //偏移角度，默认值为0.3f,不能为0

@property (nonatomic, assign) CGFloat    alphaValue;          //图片的透明比率值, 默认值为1000

@property (nonatomic, assign) CGFloat    shadowValueX;        //阴影的y方向的值，默认值为２.0f
@property (nonatomic, assign) CGFloat    shadowValueY;        //阴影的y方向的值，默认值为２.0f
@property (nonatomic, assign) CGFloat    shadowAlpha;         //阴影透明度,默认值为0.7f

@property (nonatomic, assign) NSInteger  currentIndex;        //当前显示的图片index
@property (nonatomic, assign) NSInteger  numberTotalItems;    //当前显示的图片数目

- (void)reloadData;

- (PFlowViewCell *)dequeueReusableCell;   // Should be called in pFlowView:cellForItemAtIndex: to reuse a cell
- (void)queueReusableCell:(PFlowViewCell *)cell;
- (PFlowViewCell *)cellForItemAtIndex:(NSInteger)index;    // Might return nil if cell not loaded for the specific index

@end


@protocol PFlowViewDataSource <NSObject>

@required
// Populating subview items
- (NSInteger)numberOfItemsInPFlowView:(PFlowView *)pFlowView;
- (PFlowViewCell *)pFlowView:(PFlowView *)pFlowView cellForItemAtIndex:(NSInteger)index;

@end


@protocol PFlowViewDelegate <NSObject>
@optional
- (void)pFlowView:(PFlowView *)pFlowView didSelectItemAtIndex:(NSInteger)index;

@end

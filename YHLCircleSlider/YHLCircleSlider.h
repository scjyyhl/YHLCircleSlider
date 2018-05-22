//
//  YHLCircleSlider.h
//  YHLCircleSlider
//
//  Created by Yanghl on 2018/4/13.
//  Copyright © 2018年 com.dragonlis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHLCircleSlider : UIView

/// 最小值 (默认值为0)
@property int minValue;
/// 最大值 （默认值为100）
@property int maxValue;
/// 当前值
@property (assign, nonatomic) int value;

/// 开始角度（3点钟为0，顺时针增加，默认值为90）
@property(assign, nonatomic) uint startAngle;
/// 结束角度（3点钟为0，顺时针增加，默认值为450）
@property(assign, nonatomic) uint endAngle;

/// 滑动块图片
@property(assign, nonatomic) UIImage *sliderImage;
/// 滑动块的半径(默认10)
@property (assign, nonatomic) CGFloat sliderRadius;
/// 圆弧的粗细 (默认值为2)
@property (assign, nonatomic) CGFloat arcThickness;

/// 未滑动的颜色
@property (strong, nonatomic) UIColor *defaultColor;
/// 滑动的颜色
@property (strong, nonatomic) UIColor *fullColor;

/// 是否可以手动调节进度
@property (assign, nonatomic) BOOL enableCustom;
/// value 变化时的回调
@property (strong, nonatomic) void(^progressChange)(YHLCircleSlider *circleView, int currentNum);

/**
 当滑动滑块抬起手指时要执行的操作

 @param action 要执行的操作
 */
- (void)addActionWhenTouchUp:(void(^)(YHLCircleSlider *circleView, int currentNum))action;

@end

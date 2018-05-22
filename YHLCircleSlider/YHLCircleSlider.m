//
//  YHLCircleSlider.m
//  YHLCircleSlider
//
//  Created by Yanghl on 2018/4/13.
//  Copyright © 2018年 com.dragonlis. All rights reserved.
//

#import "YHLCircleSlider.h"
#import <math.h>
#import <QuartzCore/QuartzCore.h>

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)

@interface YHLCircleSlider () <UIGestureRecognizerDelegate>

/// 可以完整显示的最大圆半径
@property (assign, nonatomic) CGFloat maxRadius;
/// 圆弧轨道的半径 = maxRadius - sliderRadius - 1
@property (assign, nonatomic) CGFloat arcRadius;
@property (assign, nonatomic) CGPoint boundCenter;
/// 当前滑块在哪个角度上
@property (assign, nonatomic) double currentAngle;
/// 滑块View
@property (strong, nonatomic) UIImageView *circle;
/// 轨道的layer
@property (nonatomic, strong) CAShapeLayer *trackLayer;
/// 当前进度的layer
@property (nonatomic, strong) CAShapeLayer *progressLayer;
/// 逻辑结束角度（0到360）
@property (assign, nonatomic) uint logicEndAngle;
/// 手势
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
/// 滑动的最后一个度数值，用户辅助判断滑动方向
@property (assign, nonatomic) double lastAngle;
/// 手指松开时要执行的操作
@property (strong, nonatomic) void(^touchUpActionHanlde)(YHLCircleSlider *circleView, int currentNum);
@end

@implementation YHLCircleSlider

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initParamAndSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initParamAndSubViews];
    }
    
    return self;
}

- (void)initParamAndSubViews {
    // 初始化参数
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    // 初始化默认值
    _minValue = 0;
    _maxValue = 100;
    _value = _minValue;
    _startAngle = 90;
    _endAngle = _startAngle + 360;
    _logicEndAngle = 90;
    _currentAngle = _startAngle;
    _sliderRadius = 10;
    _arcThickness = 2.0;
    _defaultColor = [UIColor colorWithRed:0.7176 green:0.7176 blue:0.7176 alpha:1];
    _fullColor = [UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1.0f];
    
    // 画圆弧
    [self createArcPath];
    
    // 初始化滑块View
    CGPoint circleCenter = _boundCenter;
    circleCenter.y += self.arcRadius * sin(M_PI/180 * (0 + _startAngle));
    circleCenter.x += self.arcRadius * cos(M_PI/180 * (0 + _startAngle));
    
    self.circle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.sliderRadius * 2, self.sliderRadius * 2)];
    self.circle.userInteractionEnabled = YES;
    self.circle.layer.cornerRadius = _sliderRadius;
    self.circle.backgroundColor = _defaultColor;
    self.circle.center = circleCenter;
    [self addSubview: self.circle];
    
    // 添加手势
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGesture.delegate = self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self createArcPath];
}

- (void)createArcPath {
    // 计算圆弧参数
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    _boundCenter = CGPointMake(width / 2, height / 2);
    self.maxRadius = MIN(width, height) / 2;
    _arcRadius = _maxRadius - _sliderRadius - 1;
    // 轨道层
    if (_trackLayer) {
        [_trackLayer removeFromSuperlayer];
    }
    _trackLayer=[CAShapeLayer layer];
    _trackLayer.frame=self.bounds;
    _trackLayer.fillColor = [UIColor clearColor].CGColor;
    _trackLayer.strokeColor = _defaultColor.CGColor;
    _trackLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:_trackLayer];
    UIBezierPath *path=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                      radius:self.arcRadius startAngle:DEGREES_TO_RADIANS(_startAngle) endAngle:DEGREES_TO_RADIANS(_endAngle) clockwise:YES];
    _trackLayer.path = path.CGPath;
    _trackLayer.lineWidth = self.arcThickness;
    
    // 覆盖层
    if (_progressLayer) {
        [_progressLayer removeFromSuperlayer];
    }
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor = [[UIColor clearColor] CGColor];
    _progressLayer.strokeColor = _fullColor.CGColor;//!!!不能用clearColor
    _progressLayer.lineCap=kCALineCapRound;
    _progressLayer.strokeEnd=0.0;
    [self.layer addSublayer:_progressLayer];
    
    self.arcRadius = MIN(self.arcRadius, self.maxRadius - self.sliderRadius);
    CGFloat start = _startAngle;
    CGFloat end = _endAngle;
    UIBezierPath *path1=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:self.arcRadius startAngle:DEGREES_TO_RADIANS(start) endAngle:DEGREES_TO_RADIANS(end) clockwise:YES];
    
    _progressLayer.path = path1.CGPath;
    _progressLayer.lineWidth = self.arcThickness;
    
    [self bringSubviewToFront:self.circle];
    
    [self moveCircleToAngle:_currentAngle];
}

/// 设置当前进度Layer的覆盖参数
- (void)setProgressLayerStrokeEnd: (double)angle {
    if (angle < _startAngle) {
        angle = 360 - _startAngle + angle ;
        if (angle > 360) {
            angle -= 360;
        }
    }
    else {
        angle = angle - _startAngle;
    }
    _progressLayer.strokeEnd = angle / (_endAngle - _startAngle);
    _value = _progressLayer.strokeEnd * (_maxValue - _minValue) + _minValue;
}

/// 将滑块移动到指定的位置
- (void) moveCircleToAngle: (double)angle{
    _currentAngle = angle;
    
    CGPoint newCenter = _boundCenter;
    newCenter.y += self.arcRadius * sin(M_PI/180 * (angle));
    newCenter.x += self.arcRadius * cos(M_PI/180 * (angle));
    self.circle.center = newCenter;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:1];
    
    [self setProgressLayerStrokeEnd:angle];
    if (self.progressChange) {
        self.progressChange(self, _value);
    }
    [CATransaction commit];
}

#pragma mark - getter/setter
-(void)setValue:(int)value {
    if (value < _minValue) {
        value = _minValue;
    }
    if (value > _maxValue) {
        value = _maxValue;
    }
    if (_value == value) {
        return;
    }
    _value = value;
    
    CGFloat perc = ((CGFloat)value - _minValue) / (_maxValue - _minValue);
    double angle = _startAngle + perc * (_endAngle - _startAngle);
    [self moveCircleToAngle:angle];
}

-(void)setEnableCustom:(BOOL)enableCustom{
    _enableCustom = enableCustom;
    if (_enableCustom) {
        self.circle.userInteractionEnabled = YES;
        self.circle.hidden = NO;
        [self addGestureRecognizer:_panGesture];
    }else{
        self.circle.userInteractionEnabled = NO;
        self.circle.hidden = YES;
        [self removeGestureRecognizer:_panGesture];
    }
}

- (void)setSliderImage:(UIImage *)sliderImage {
    _sliderImage = sliderImage;
    self.circle.image = _sliderImage;
}

- (void)setStartAngle:(uint)startAngle {
    _startAngle = startAngle;
    if (_startAngle > 360) {
        _startAngle = _startAngle % 360;
    }
    _currentAngle = _startAngle;
    [self createArcPath];
}

- (void)setEndAngle:(uint)endAngle {
    _endAngle = ((int)endAngle - (int)_startAngle) % 360 + _startAngle;
    if (_endAngle <= _startAngle) {
        _endAngle += 360;
    }
    
    _logicEndAngle = _endAngle;
    if (_logicEndAngle > 360) {
        _logicEndAngle = _endAngle % 360;
    }
    [self createArcPath];
}

- (void)setSliderRadius:(CGFloat)sliderRadius {
    _sliderRadius = sliderRadius;
    CGRect newFrame = CGRectMake(0, 0, sliderRadius * 2, sliderRadius *2);
    _circle.frame = newFrame;
    _circle.layer.cornerRadius = sliderRadius;
    
    [self createArcPath];
}

- (void)setArcThickness:(CGFloat)arcThickness {
    _arcThickness = arcThickness;
    
    [self createArcPath];
}

- (void)setFullColor:(UIColor *)fullColor {
    _fullColor = fullColor;
    [self createArcPath];
}

- (void)setDefaultColor:(UIColor *)defaultColor {
    _defaultColor = defaultColor;
    _circle.backgroundColor = defaultColor;
    [self createArcPath];
}

#pragma mark -public method
- (void)addActionWhenTouchUp:(void (^)(YHLCircleSlider *, int))action {
    _touchUpActionHanlde = action;
}

#pragma mark - 拖动手势处理
- (void)handlePan:(UIPanGestureRecognizer *)pv {
    if (pv.state == UIGestureRecognizerStateEnded ||
        pv.state == UIGestureRecognizerStateFailed ||
        pv.state == UIGestureRecognizerStateCancelled) {
        if (_touchUpActionHanlde) {
            _touchUpActionHanlde(self, _value);
        }
        return;
    }
    
    CGPoint translation = [pv locationInView:self];
    CGFloat x_displace = translation.x - self.boundCenter.x;
    CGFloat y_displace = -1.0*(translation.y - self.boundCenter.y);
    double angle = -180/M_PI * atan2(y_displace, x_displace);
    if (angle < 0) {
        angle = 360 + angle;
    }
    
    NSLog(@"computer angle == %f ==", angle);
    if (angle >= _startAngle && angle <= _endAngle) {
        [self moveCircleToAngle:angle];
    }
    else if (_endAngle > 360 && angle < (_endAngle - 360)) {
        [self moveCircleToAngle:angle];
    }
    else {
        
        double sabs = fabs(angle - _startAngle);
        double eabs = fabs(angle - _logicEndAngle);
        if (sabs > eabs) {
            angle = _endAngle;
        }
        else {
            angle = _startAngle;
        }
        [self moveCircleToAngle:angle];
    }
    _lastAngle = angle;
}

#pragma mark gestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint pt = [gestureRecognizer locationInView:self];
    return CGRectContainsPoint(CGRectInset(self.circle.frame, -8, -8), pt);
}

@end

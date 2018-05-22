//
//  ViewController.m
//  YHLCircleSliderDemo
//
//  Created by Ch-Yanghl on 2018/4/13.
//  Copyright © 2018年 com.dragonlis. All rights reserved.
//

#import "ViewController.h"
#import "YHLCircleSlider.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *otLabel;
@property (weak, nonatomic) IBOutlet UISlider *otSlider;
@property (weak, nonatomic) IBOutlet YHLCircleSlider *otCircleSlider1;
@property (weak, nonatomic) IBOutlet YHLCircleSlider *otCircleSlider2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _otSlider.minimumValue = 0;
    _otSlider.maximumValue = 365;
    [_otSlider addTarget:self action:@selector(actSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
    _otCircleSlider1.sliderImage = [UIImage imageNamed:@"icon_slider"];
    _otCircleSlider1.minValue = 0;
    _otCircleSlider2.minValue = 0;
    _otCircleSlider1.maxValue = 365;
    _otCircleSlider2.maxValue = 365;
    _otCircleSlider1.startAngle = 120;
    _otCircleSlider2.startAngle = 120;
    _otCircleSlider1.endAngle = 60;
    _otCircleSlider2.endAngle = 60;
    _otCircleSlider2.sliderRadius = 10;
    _otCircleSlider2.sliderRadius = 0;
    _otCircleSlider1.enableCustom = YES;
    
    _otCircleSlider1.progressChange = ^(YHLCircleSlider *circleView, int currentNum) {
        _otSlider.value = currentNum;
        _otCircleSlider2.value = currentNum;
    };
    [_otCircleSlider1 addActionWhenTouchUp:^(YHLCircleSlider *circleView, int currentNum) {
        _otLabel.text = [NSString stringWithFormat:@"%d", currentNum];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actSliderValueChange:(UISlider *)slider {
    float value = slider.value;
    _otLabel.text = [NSString stringWithFormat:@"%f", value];
    _otCircleSlider1.value = value;
    _otCircleSlider2.value = value;
}

@end

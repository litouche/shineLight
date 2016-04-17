//
//  ViewController.m
//  shineLight
//
//  Created by zjj on 16/4/15.
//  Copyright © 2016年 zjj. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *showHz;
@property (weak, nonatomic) IBOutlet UISwitch *isShine;
@property (weak, nonatomic) IBOutlet UISwitch *isScreen;
@property (weak, nonatomic) IBOutlet UIButton *start;
@property (strong,nonatomic) NSArray *numbers;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (strong,nonatomic) NSTimer *uiTimer;
@property (weak, nonatomic) IBOutlet UILabel *uiDesLabel;
@property (assign,nonatomic) BOOL isOpen;
@property (assign,nonatomic) BOOL onScreen;
@property (assign,nonatomic) BOOL onShine;

@end

@implementation ViewController{
     NSString *vstr;
     AVCaptureSession * AVSession;//调用闪光灯的时候创建的类
     AVCaptureDevice *device;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _slider.minimumValue = 0.0;            //滑块下限
    _slider.value = 0.0;                   //当前数值
    _slider.continuous = YES;
    _slider.userInteractionEnabled = NO;
    [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    vstr = [NSString stringWithFormat:@"%lu",(unsigned long)_slider.value];
    _showHz.text = [vstr stringByAppendingString:@"/Hz"];
    _isShine.on = NO;
    _isShine.onTintColor = [UIColor purpleColor];
    _isScreen.on = NO;
    _isScreen.onTintColor = [UIColor purpleColor];
}

- (void)valueChanged:(UISlider *)sender{
    if (_onScreen == NO){
        [self closeTimer];
        NSUInteger index = (NSUInteger)(sender.value );
        [_slider setValue:index animated:YES];
        NSNumber *number = _numbers[index];
        vstr = [NSString stringWithFormat:@"%@",number];
        _showHz.text = [vstr stringByAppendingString:@"/Hz"];
        if ([vstr isEqualToString:@"0"]){
            [self closeFlash];
        }else{
            [self openFlash];
        }
        [self openTimer];
    }else{
        _showHz.text = [NSString stringWithFormat:@"%f",sender.value];
        float value = sender.value;
        [[UIScreen mainScreen] setBrightness:value];
    }
    
    
}

//开启闪光灯
- (void)openFlash{
    AVSession = [[AVCaptureSession alloc]init];
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOn];
    [device setFlashMode:AVCaptureFlashModeOn];
    [device unlockForConfiguration];
    [AVSession startRunning];
    
}
//关闭闪光灯
- (void)closeFlash{
    AVSession = [[AVCaptureSession alloc]init];
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOff];
    [device setFlashMode:AVCaptureFlashModeOff];
    [device unlockForConfiguration];
    [AVSession stopRunning];
    AVSession = nil;
    device = nil;
    
}

- (IBAction)start:(id)sender {
    
    _isShine.on = NO;
    _slider.value = 0.0f;
    _showHz.text = @"0/Hz";
    if (_isOpen == NO || device.torchMode == AVCaptureTorchModeOff){
        [self openFlash];
        _isOpen = YES;
        _modeLabel.text = @"闪光灯开启";
        [self closeTimer];
        
        
    }else if (_isOpen == YES || device.torchMode == AVCaptureTorchModeOn){
        [self closeFlash];
        [self closeTimer];
        _modeLabel.text = @"闪光灯关闭";
        _isOpen = NO;
    }
    
}

- (IBAction)beginShine:(id)sender {
    _onScreen = NO;
    
    _numbers = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    NSInteger numberOfSteps = ((NSUInteger)[_numbers count] - 1);
    _slider.minimumValue = 0.0;            //滑块下限
    _slider.maximumValue = numberOfSteps;  //滑块上限
    _slider.value = 0.0;                   //当前数值
    _slider.minimumTrackTintColor = [UIColor yellowColor];
    _slider.maximumTrackTintColor = [UIColor whiteColor];
    UISwitch *uiswitch = (UISwitch *)sender;
    if (uiswitch.on == NO){
        _slider.userInteractionEnabled = NO;
        _onShine = NO;
        _modeLabel.text = @"请选择模式";
        [self closeFlash];
        [self closeTimer];
        _slider.value = 0.0f;
         _showHz.text = @"0/Hz";
        vstr = @"1";
      

    }else{
        _onShine = YES;
         _slider.userInteractionEnabled = YES;
        _modeLabel.text = @"模式闪光";
        [self openTimer];
        if (_slider.value == 0.0f){
            _showHz.text = @"1/Hz";
        }

    }
    [self checkSwitch];
    
}

- (IBAction)changeScreen:(id)sender {
    _onScreen = YES;
    _onShine = NO;
    [self closeTimer];
    [self closeFlash];
    _slider.minimumTrackTintColor = [UIColor purpleColor];
    _slider.maximumTrackTintColor = [UIColor blackColor];
    _slider.maximumValue = 1.0f;
    _slider.minimumValue = 0.0f;
     float curValue = [UIScreen mainScreen].brightness;
    _showHz.text = [NSString stringWithFormat:@"%f",curValue];
    
    UISwitch *uiswitch = (UISwitch *)sender;
    if (uiswitch.on == NO){
//        _start.userInteractionEnabled = YES;
        _slider.userInteractionEnabled = NO;
        _slider.value = 0.0;
        _modeLabel.text = @"请选择模式";
        _uiDesLabel.text = @"当前频率(/Hz)";
        _showHz.text = @"0/Hz";

        
    }else{
//        _start.userInteractionEnabled = NO;
        _slider.userInteractionEnabled = YES;
        _modeLabel.text = @"模式屏幕";
        _uiDesLabel.text = @"当前亮度";
        [self closeFlash];
        _slider.value = curValue;
       
        
    }
    [self checkSwitch];
}

//检查switch状态
- (void)checkSwitch{
    _isShine.userInteractionEnabled = _isScreen.on == NO ? YES : NO;
    _isScreen.userInteractionEnabled = _isShine.on == NO ? YES : NO;
    _start.userInteractionEnabled = _isScreen.on == NO ? YES : NO;

}
//打开定时器
- (void)openTimer{
    _uiTimer = [NSTimer scheduledTimerWithTimeInterval:(11 - [vstr integerValue])*0.075 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
    [_uiTimer fire];

}
//关闭定时器
- (void)closeTimer{
    [_uiTimer invalidate];
    _uiTimer = nil;
}

//定时器事件
- (void)timerFire:(NSTimer *)sender{

  if (device.torchMode == AVCaptureTorchModeOn){
    [self closeFlash];
        return;
  }else if (device.torchMode == AVCaptureTorchModeOff){
        [self openFlash];
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
@end

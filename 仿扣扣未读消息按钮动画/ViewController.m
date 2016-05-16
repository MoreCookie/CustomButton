//
//  ViewController.m
//  仿扣扣未读消息按钮动画
//
//  Created by 时双齐 on 16/5/5.
//  Copyright © 2016年 亿信互联. All rights reserved.
//

/**
 *  
 *   自定义房QQ的未读消息按钮  CustomButton
 *   封装倒计时按钮（分类实现） UIButton+countDown
 */

#import "ViewController.h"
#import "CustomButton.h"
#import "UIButton+countDown.h"

@interface ViewController ()

@property (nonatomic,strong) UIButton *countDownBtn;

@property (nonatomic,strong) CustomButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //仿扣扣未读消息按钮
    [self.view addSubview:self.btn];
    
    //倒计时按钮
    [self.view addSubview:self.countDownBtn];
}

//懒加载
-(CustomButton *)btn
{
    if (!_btn) {
        
        _btn = [[CustomButton alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
        _btn.backgroundColor = [UIColor blueColor];
        [_btn setTitle:@"11" forState:0];
        [_btn setTitleColor:[UIColor whiteColor] forState:0];
    }
    
    return _btn;
}

-(UIButton *)countDownBtn
{
    if (!_countDownBtn) {
        _countDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _countDownBtn.frame = CGRectMake(100, 200, 100, 30);
        [_countDownBtn addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
        _countDownBtn.backgroundColor = [UIColor blueColor];
        [_countDownBtn setTitle:@"获取验证码" forState:0];
    }
    
    return _countDownBtn;
}


-(void)buttonClick
{
    [self.countDownBtn startWithTime:60 title:@"获取验证码" countDownTitle:@"s" mainColor:[UIColor blueColor] countColor:[UIColor darkGrayColor]];
}

@end

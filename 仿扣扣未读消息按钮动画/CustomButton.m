//
//  CustomButton.m
//  仿扣扣未读消息按钮动画
//
//  Created by 时双齐 on 16/5/5.
//  Copyright © 2016年 亿信互联. All rights reserved.
//

#define kBtnWidth self.bounds.size.width
#define kBtnHeight self.bounds.size.height

#import "CustomButton.h"

@interface CustomButton ()
/**底部小圆*/
@property (nonatomic,strong) UIView *cireleView;
/** 绘制不规则图形 */
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation CustomButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //创建视图
        [self setUpUI];
    }
    return self;
}

/**
 *  重写父类backgroundColor的setter方法
 *
 *  @param backgroundColor 背景颜色
 */
-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    _cireleView.backgroundColor = backgroundColor;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.superview insertSubview:_cireleView belowSubview:self];
}

#pragma mark - 懒加载
-(UIView *)cireleView
{
    if (!_cireleView) {
        
        _cireleView = [[UIView alloc]init];
       
    }
    
    return _cireleView;
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:_shapeLayer below:self.layer];
    }
    
    return _shapeLayer;
}


-(void)setUpUI
{
    CGFloat cornerRadius = kBtnWidth > kBtnHeight ? kBtnWidth / 2 : kBtnHeight / 2;
    //设置圆角半径
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    _maxDistance = cornerRadius * 5;
    //添加button下面的小圆
    self.cireleView.frame = CGRectMake(0, 0, cornerRadius * 2, cornerRadius *2);
    self.cireleView.center = self.center;
    //设置小圆圆角半径
    self.cireleView.layer.cornerRadius = self.cireleView.bounds.size.height / 2;
    
    //添加点击事件
    [self addTarget:self action:@selector(customButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}

#pragma mark - 手势
-(void)pan:(UIPanGestureRecognizer *)pan
{
    [self.layer removeAnimationForKey:@"shake"];
    
    CGPoint panPoint = [pan translationInView:self];
    
    CGPoint changeCenter = self.center;
    changeCenter.x += panPoint.x;
    changeCenter.y += panPoint.y;
    self.center = changeCenter;
    
    [pan setTranslation:CGPointZero inView:self];
    
    //俩个圆的中心点之间的距离
    CGFloat dist = [self pointToPoitnDistanceWithPoint:self.center potintB:self.cireleView.center];
    
    //小于最大距离时
    if (dist < _maxDistance) {
        CGFloat cornerRadius = (kBtnHeight > kBtnWidth ? kBtnWidth / 2 : kBtnHeight / 2);
        CGFloat samllCrecleRadius = cornerRadius - dist / 10;
        self.cireleView.bounds = CGRectMake(0, 0, samllCrecleRadius * (2 - 0.5), samllCrecleRadius * (2 - 0.5));
        self.cireleView.layer.cornerRadius = self.cireleView.bounds.size.width / 2;
        
        if (self.cireleView.hidden == NO && dist > 0) {
            //画不规则矩形
            self.shapeLayer.path = [self pathWithBigCirCleView:self smallCirCleView:self.cireleView].CGPath;
        }
        
    }else
    {
        //大于设置的最大距离时销毁
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
        
        self.cireleView.hidden = YES;
    }
    
    //停止手势时
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        if (dist < _maxDistance) {
            
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.shapeLayer removeFromSuperlayer];
                self.shapeLayer = nil;
                self.center = self.cireleView.center;
            } completion:^(BOOL finished) {
                self.cireleView.hidden = NO;
            }];
        }else
        {
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            
            [self removeFromSuperview];
            [self.cireleView removeFromSuperview];
        }
    }
}

#pragma mark - 两个圆心之间的距离
- (CGFloat)pointToPoitnDistanceWithPoint:(CGPoint)pointA potintB:(CGPoint)pointB
{
    CGFloat offestX = pointA.x - pointB.x;
    CGFloat offestY = pointA.y - pointB.y;
    CGFloat dist = sqrtf(offestX * offestX + offestY * offestY);
    
    return dist;
}

#pragma mark - 不规则路径
- (UIBezierPath *)pathWithBigCirCleView:(UIView *)bigCirCleView  smallCirCleView:(UIView *)smallCirCleView
{
    CGPoint bigCenter = bigCirCleView.center;
    CGFloat x2 = bigCenter.x;
    CGFloat y2 = bigCenter.y;
    CGFloat r2 = bigCirCleView.bounds.size.width / 2;
    
    CGPoint smallCenter = smallCirCleView.center;
    CGFloat x1 = smallCenter.x;
    CGFloat y1 = smallCenter.y;
    CGFloat r1 = smallCirCleView.bounds.size.width / 2;
    
    // 获取圆心距离
    CGFloat d = [self pointToPoitnDistanceWithPoint:self.cireleView.center potintB:self.center];
    CGFloat sinθ = (x2 - x1) / d;
    CGFloat cosθ = (y2 - y1) / d;
    
    // 坐标系基于父控件
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ , y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ , y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ , y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ , y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d / 2 * sinθ , pointA.y + d / 2 * cosθ);
    CGPoint pointP = CGPointMake(pointB.x + d / 2 * sinθ , pointB.y + d / 2 * cosθ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // A
    [path moveToPoint:pointA];
    // AB
    [path addLineToPoint:pointB];
    // 绘制BC曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    // CD
    [path addLineToPoint:pointD];
    // 绘制DA曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}

//btn点击事件
-(void)customButtonClick
{
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = nil;
    
    [self removeFromSuperview];
    [self.cireleView removeFromSuperview];
}

//高亮状态下左右摇摆
-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self.layer removeAnimationForKey:@"shake"];
    
    //摇摆幅度
    CGFloat shake = 5;
    
    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animation];
    keyAnim.keyPath = @"transform.translation.x";
    keyAnim.values = @[@(-shake),@(shake),@(-shake)];
    keyAnim.duration = 0.3;
    keyAnim.removedOnCompletion = NO;
    keyAnim.repeatCount = MAXFLOAT;
    
    [self.layer addAnimation:keyAnim forKey:@"shake"];
}

@end
















//
//  UIView+LXMAppleReveal.m
//  LXMRevealDemo
//
//  Created by luxiaoming on 15/7/22.
//  Copyright (c) 2015年 luxiaoming. All rights reserved.
//

#import "UIView+LXMAppleReveal.h"

@interface LXMAppleRevealView : UIImageView

@property (nonatomic, strong) CAShapeLayer *borderLayer;//中间的圆透明，圆与边框之间的内容半透明的layer
@property (nonatomic, strong) CAShapeLayer *clockCircleLayer;//中心动画的layer
@property (nonatomic, assign) BOOL isAnimating;

- (instancetype)initWithTargetView:(UIView *)view;

- (void)reveal;

@end


@implementation LXMAppleRevealView

- (instancetype)initWithTargetView:(UIView *)view {
    self = [super initWithFrame:view.bounds];
    if (self) {
        [self setupDefault];
    }
    return self;
}


- (void)setupDefault {
    if (self.isAnimating) {
        return;
    }
    [self.layer addSublayer:self.borderLayer];
    [self.layer addSublayer:self.clockCircleLayer];
    self.layer.masksToBounds = YES;//这一句必须要设置，否则layer会超出view范围
    
}

- (void)reveal {
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    [self.clockCircleLayer addAnimation:[self clockRevealAnimation] forKey:@"clockRevealAnimation"];
    
}


/**
 *  根据直径生成圆的path，注意圆点是self的中心点，所以（x，y）不是（0，0）
 */
- (UIBezierPath *)pathWithDiameter:(CGFloat)diameter {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(CGRectGetWidth(self.bounds) / 2, (CGRectGetHeight(self.bounds) -diameter) / 2)];
    [path addArcWithCenter:self.center radius:diameter / 2 startAngle:-M_PI / 2 endAngle:M_PI *3.0/2.0 clockwise:YES];//用这种方式没用类方法是为了控制path的起点和终点
    return [path bezierPathByReversingPath];//注意动画是从strokeEnd从1到0，所以path应该取反
}

/**
 *  用添加的方式画一个边是矩形，中间有一个圆形的path，配合fillRule和fillRule可以做出中间透明、外部半透明的效果
 */
- (UIBezierPath *)maskPathWithDiameter:(CGFloat)diameter  {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    [path moveToPoint:CGPointMake(CGRectGetWidth(self.bounds) / 2, (CGRectGetHeight(self.bounds) -diameter) / 2)];
    [path addArcWithCenter:self.center radius:diameter / 2 startAngle:-M_PI / 2 endAngle:M_PI *3.0/2.0 clockwise:YES];
    return path;
}

#pragma mark - animation

- (CABasicAnimation *)clockRevealAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.toValue = @(0);
    animation.duration = 3;
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

- (CABasicAnimation *)expandAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.toValue = (id)[self maskPathWithDiameter:150].CGPath;
    animation.duration = 2.0;
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([self.clockCircleLayer animationForKey:@"clockRevealAnimation"] == anim) {
        [self.borderLayer addAnimation:[self expandAnimation] forKey:@"expandAnimation"];
    } else if ([self.borderLayer animationForKey:@"expandAnimation"] == anim) {
        self.isAnimating = NO;
        [self removeFromSuperview];
    }
}

#pragma mark - property

- (CAShapeLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        _borderLayer.path = [self maskPathWithDiameter:CGRectGetHeight(self.bounds) - 20].CGPath;
        _borderLayer.fillRule = kCAFillRuleEvenOdd;
    }
    return _borderLayer;
}

- (CAShapeLayer *)clockCircleLayer {
    //这里是用线宽度=圆直径 线来画圆（为什么是直径不是半径呢？因为fillColor是从线的中心开始算范围的）
    if (!_clockCircleLayer) {
        _clockCircleLayer = [CAShapeLayer layer];
        _clockCircleLayer.fillColor = [UIColor clearColor].CGColor;//[UIColor colorWithWhite:0 alpha:0.5].CGColor;//
        _clockCircleLayer.strokeColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        _clockCircleLayer.lineWidth = (CGRectGetHeight(self.bounds) - 30 ) / 2;
        _clockCircleLayer.path = [self pathWithDiameter:(CGRectGetHeight(self.bounds) - 30 ) / 2].CGPath;
        _clockCircleLayer.strokeEnd = 1;
    }
    return _clockCircleLayer;
}


@end



@implementation UIView (LXMAppleReveal)

NSInteger const kLXMAppleRevealViewTag = 9527;

- (void)setupForLXMAppleReveal {
    LXMAppleRevealView *revealView = (LXMAppleRevealView *)[self viewWithTag:kLXMAppleRevealViewTag];
    if (!revealView) {
        revealView = [[LXMAppleRevealView alloc] initWithTargetView:self];
        revealView.layer.cornerRadius = self.layer.cornerRadius;
        revealView.layer.masksToBounds = self.layer.masksToBounds;
        revealView.tag = kLXMAppleRevealViewTag;
        [self addSubview:revealView];
        [self bringSubviewToFront:revealView];
    }
}

- (void)lxmAppleReveal {
    LXMAppleRevealView *revealView = (LXMAppleRevealView *)[self viewWithTag:kLXMAppleRevealViewTag];
    [revealView reveal];
}

@end

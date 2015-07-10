//
//  UIView+LXMReveal.m
//  TEST_Layer
//
//  Created by luxiaoming on 15/7/10.
//  Copyright (c) 2015年 luxiaoming. All rights reserved.
//

#import "UIView+LXMReveal.h"

@interface LXMRevealView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, assign) CGFloat smallDiameter;
@property (nonatomic, assign) CGFloat bigDiameter;

@end

@implementation LXMRevealView

- (instancetype)initWithTargetView:(UIView *)view {
    self = [super initWithFrame:view.bounds];
    if (self) {
        [self setupDefault];
    }
    return self;
}


- (void)setupDefault {
    self.backgroundColor = [UIColor lightGrayColor];
    self.smallDiameter = 40;
    self.bigDiameter = sqrt(CGRectGetWidth(self.bounds)*CGRectGetWidth(self.bounds) + CGRectGetHeight(self.bounds) *CGRectGetHeight(self.bounds));
    [self.layer addSublayer:self.circleLayer];
}


- (void)reveal {
    self.backgroundColor = [UIColor clearColor];
    [self.circleLayer removeFromSuperlayer];//理论上作为mask的layer不能有父layer，所以要remove掉
    self.superview.layer.mask = self.circleLayer;
    
    //让圆的变大的动画
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    UIBezierPath *toPath = [self pathWithDiameter:self.bigDiameter];
    //    UIBezierPath *toPath = [self pathWithDiameter:0];//缩小当前path的动画
    pathAnimation.toValue = (id)toPath.CGPath;
    pathAnimation.duration = 1.0;
 
    
    //让圆的线的宽度变大的动画，效果是内圆变小
    CABasicAnimation *lineWidthAnimation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(lineWidth))];
    lineWidthAnimation.toValue = @(self.bigDiameter);
    lineWidthAnimation.duration = 1.0;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[pathAnimation, lineWidthAnimation];
    group.duration = 1.0;
    group.removedOnCompletion = NO;//这两句的效果是让动画结束后不会回到原处，必须加
    group.fillMode = kCAFillModeForwards;//这两句的效果是让动画结束后不会回到原处，必须加
    group.delegate = self;
    
    [self.circleLayer addAnimation:group forKey:@"revealAnimation"];
}

/**
 *  根据直径生成圆的path，注意圆点是self的中心点，所以（x，y）不是（0，0）
 */
- (UIBezierPath *)pathWithDiameter:(CGFloat)diameter {
    return [UIBezierPath bezierPathWithOvalInRect:CGRectMake((CGRectGetWidth(self.bounds) - diameter) / 2, (CGRectGetHeight(self.bounds) - diameter) / 2, diameter, diameter)];
}


#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.superview.layer.mask = nil;
    [self removeFromSuperview];
}


#pragma mark - property

- (CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.fillColor = [UIColor clearColor].CGColor;//这个必须透明，因为这样内圆才是不透明的
        _circleLayer.strokeColor = [UIColor yellowColor].CGColor;//注意这个必须不能透明，因为实际上是这个显示出后面的图片了
        _circleLayer.path = [self pathWithDiameter:self.smallDiameter].CGPath;
    }
    return _circleLayer;
}


@end





@implementation UIView (LXMReveal)

NSInteger const kLXMRevealViewTag = 9527;

- (void)setupForReveal {
    LXMRevealView *revealView = [[LXMRevealView alloc] initWithTargetView:self];
    revealView.tag = kLXMRevealViewTag;
    [self addSubview:revealView];
    [self bringSubviewToFront:revealView];
}

- (void)lxmReveal {
    LXMRevealView *revealView = (LXMRevealView *)[self viewWithTag:kLXMRevealViewTag];
    [revealView reveal];
}

@end

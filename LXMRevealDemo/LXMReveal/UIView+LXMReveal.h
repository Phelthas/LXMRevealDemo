//
//  UIView+LXMReveal.h
//  TEST_Layer
//
//  Created by luxiaoming on 15/7/10.
//  Copyright (c) 2015年 luxiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXMRevealView : UIImageView

- (instancetype)initWithTargetView:(UIView *)view;

- (void)reveal;

@end


@interface UIView (LXMReveal)

- (void)setupForReveal;

- (void)lxmReveal;

@end

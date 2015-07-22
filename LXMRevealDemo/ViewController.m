//
//  ViewController.m
//  LXMRevealDemo
//
//  Created by luxiaoming on 15/7/10.
//  Copyright (c) 2015年 luxiaoming. All rights reserved.
//

#import "ViewController.h"
#import "UIView+LXMReveal.h"
#import "UIView+LXMAppleReveal.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *testImageView;


@property (weak, nonatomic) IBOutlet UIImageView *twoImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.testImageView setupForReveal];
    
    self.twoImageView.layer.cornerRadius = 10;
    self.twoImageView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - buttonAction



- (IBAction)handleResetButtonTapped:(id)sender {
    for (UIView *subView in self.testImageView.subviews) {
        [subView removeFromSuperview];
    }
    [self.testImageView setupForReveal];
}

- (IBAction)handleRevealButtonTapped:(id)sender {
    [self.testImageView lxmReveal];
}

- (IBAction)handleLXMAppleRevealButtonTapped:(id)sender {
    
    [self.twoImageView setupForLXMAppleReveal];
    [self.twoImageView lxmAppleReveal];
}
@end

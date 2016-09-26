//
//  ViewController.m
//  HexagonAnimation
//
//  Created by YangHan on 16/9/26.
//  Copyright © 2016年 bot. All rights reserved.
//

#import "ViewController.h"
#import "HexagonBackgroundView.h"

@interface ViewController ()<HexagonBackgroundViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HexagonBackgroundView *backView = [[HexagonBackgroundView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    backView.center = self.view.center;
    backView.delegate = self;
    [self.view addSubview:backView];
}

- (void)hexagonBackgroundView:(HexagonBackgroundView *)hexagonBgView didSelectHexagonType:(HexagonContentType)type
{
    NSLog(@"%ld",type);
}





@end

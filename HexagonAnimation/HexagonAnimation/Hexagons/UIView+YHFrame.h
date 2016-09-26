//
//  UIView+YHFrame.h
//  
//
//  Created by bot on 16/6/26.
//  Copyright © 2016年 bot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YHFrame)

@property (assign,nonatomic) CGFloat x;
@property (assign,nonatomic) CGFloat y;
@property (assign,nonatomic) CGFloat width;
@property (assign,nonatomic) CGFloat height;
@property (nonatomic,assign) CGSize size;
@property (assign,nonatomic) CGFloat centerX;
@property (assign,nonatomic) CGFloat centerY;
@property (nonatomic,assign) CGFloat left;
@property (nonatomic,assign) CGFloat right;
@property (nonatomic,assign) CGFloat top;
@property (nonatomic,assign) CGFloat bottom;

@end

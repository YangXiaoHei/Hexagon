/*********************************************************************************
 *Copyright (c) 8-7 fangstar. All rights reserved.
 *FileName:     HexagonView           // 文件名
 *Author:       yanghan               // 创建文档的作者
 *Date:         8-7                   // 创建日期
 *Description:  正六边形view           // 用于主要说明此程序文件完成的主要功能
 *Others:       无                    // 其他内容说明
 *History:                            // 修改历史记录列表，每条修改记录应包含修改日期、修改者及修改内容简介
 ********************************************************************************/

#import "HexagonView.h"
#import "UIView+YHFrame.h"

#define kDefalutFont [UIFont systemFontOfSize:17]

static CGFloat const shrinkFactor   = 0.7;
static CGFloat const flipDuration   = 0.25;
static CGFloat const scaleDuration  = 0.3;

@interface HexagonView ()

/** 内容文字label **/
@property (nonatomic,weak) UILabel             * contentTitleLabel;
/** 六边形贝赛尔路径 **/
@property (nonatomic,strong) UIBezierPath      * hexagonPath;
/** 翻转隐藏动画 **/
@property (nonatomic,strong) CABasicAnimation  * flipFadeAnimation;
/** 翻转出现动画 **/
@property (nonatomic,strong) CABasicAnimation  * flipAppearAnimation;
/** 是否需要创建内容label **/
@property (nonatomic,assign) BOOL                needLoadLabel;
/** 翻转动画时长 **/
@property (nonatomic,assign,readwrite) CGFloat   flipDuration;
/** 缩放动画时长 **/
@property (nonatomic,assign,readwrite) CGFloat   scaleDuration;
/** 初始frame **/
@property (nonatomic,assign,readwrite)  CGRect   contentRect;

@property (nonatomic,assign,getter=isPlaying) BOOL playing;

@end

@implementation HexagonView

#pragma mark - 初始化
+ (instancetype)hexagonWithRadius:(CGFloat)radius
{
    HexagonView *hexagon = [[HexagonView alloc]initWithFrame:CGRectMake(0, 0, radius, radius)];
    return hexagon;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}
/**
 *  从xib或代码创建公用的初始化方法
 */
- (void)commonInit
{
    //背景色
    self.backgroundColor = [UIColor clearColor];
    //六边形区域填充色
    self.contentColor = [UIColor redColor];
    //默认字体
    self.font = kDefalutFont;
    //默认字体颜色
    self.textColor = [UIColor whiteColor];
    //默认翻转动画时长
    self.flipDuration = flipDuration;
    //默认缩放动画时长
    self.scaleDuration = scaleDuration;
    
    self.playing = NO;
}

#pragma mark - setter
- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.text = self.contentTitleLabel.text;
    
}
- (void)setFont:(UIFont *)font
{
    _font = font;
    self.text = self.contentTitleLabel.text;
}
- (void)setText :(NSString *)text
{
    _text = text;
    if (text.length) { // 如果设置了长度不为0的文字,才加载label
        self.needLoadLabel = YES;
        self.contentTitleLabel.text = text;
        self.contentTitleLabel.textColor = self.textColor;
        self.contentTitleLabel.font = self.font;
    }
    else {
        self.needLoadLabel = NO;
        [_contentTitleLabel removeFromSuperview];
        _contentTitleLabel = nil;
    }
}
- (void)setContentColor:(UIColor *)contentColor
{
    _contentColor = contentColor;
    [self setNeedsDisplay];
}

- (void)setContentRect:(CGRect)contentRect
{
    _contentRect = contentRect;
    [self setNeedsLayout];
}

#pragma mark - 绘图
- (void)drawRect:(CGRect)rect
{
    //获取最小边长
    CGFloat viewWidth = MIN(rect.size.width, rect.size.height);
    //截取最小边长的正方形
    self.contentRect = (CGRect){rect.origin.x,rect.origin.y,viewWidth,viewWidth};
    //正方形内接圆的圆心
    CGPoint centerP = (CGPoint){self.contentRect.size.width * 0.5,self.contentRect.size.height * 0.5};
    //正三角形角度
    CGFloat angle = M_PI / 3;
    
    //绘制六边形
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGPoint startP = (CGPoint){viewWidth * 0.5,0};
    CGPoint p1 = RotateCGPointAroundCenter(startP,centerP,angle);
    CGPoint p2 = RotateCGPointAroundCenter(p1, centerP, angle);
    CGPoint p3 = RotateCGPointAroundCenter(p2, centerP, angle);
    CGPoint p4 = RotateCGPointAroundCenter(p3, centerP, angle);
    CGPoint p5 = RotateCGPointAroundCenter(p4, centerP, angle);
    
    [path moveToPoint:startP];
    [path addLineToPoint:p1];
    [path addLineToPoint:p2];
    [path addLineToPoint:p3];
    [path addLineToPoint:p4];
    [path addLineToPoint:p5];
    
    [path closePath];
    
    //保存六边形路径
    self.hexagonPath = path;
    
    //设置填充色
    [self.contentColor setFill];
    //填充
    [path fill];
}

- (void)resetting
{
    CGFloat leftOffset = (1 - shrinkFactor) * 0.5 * self.contentRect.size.width;
    CGFloat upOffset = (1 - shrinkFactor) * 0.5 * self.contentRect.size.height;
    self.transform = CGAffineTransformMakeScale(shrinkFactor, shrinkFactor);
    CGRect frame = self.frame;
    frame.origin.x -= leftOffset;
    frame.origin.y -= upOffset;
    self.frame = frame;
    self.selected = YES;
}

#pragma mark - 动画
- (void)flipFade
{
    self.playing = YES;
    CABasicAnimation *flip = [CABasicAnimation animation];
    flip.keyPath = @"transform.rotation.y";
    flip.fromValue = @(0);
    flip.toValue = @(M_PI_2);
    flip.duration = flipDuration;
    flip.removedOnCompletion = NO;
    flip.fillMode = kCAFillModeForwards;
    flip.delegate = self;
    [self.layer addAnimation:flip forKey:@"flipFade"];
    self.flipFadeAnimation = flip;
}
- (void)shrink
{
    self.playing = YES;
    CGFloat leftOffset = (1 - shrinkFactor) * 0.5 * self.contentRect.size.width;
    CGFloat upOffset = (1 - shrinkFactor) * 0.5 * self.contentRect.size.height;
    [UIView animateWithDuration:scaleDuration animations:^{
        CGRect frame = self.frame;
        frame.origin.x -= leftOffset;
        frame.origin.y -= upOffset;
        self.frame = frame;
        self.transform = CGAffineTransformMakeScale(shrinkFactor, shrinkFactor);
        
    } completion:^(BOOL finished) {
        self.selected = YES;
        self.playing = NO;
    }];
}

- (void)recover
{
    self.playing = YES;
    CGFloat rightOffset = (1 - shrinkFactor) * 0.5 * self.contentRect.size.width;
    CGFloat downOffset = (1 - shrinkFactor) * 0.5 * self.contentRect.size.height;
    [UIView animateWithDuration:scaleDuration animations:^{
        CGRect frame = self.frame;
        frame.origin.x += rightOffset;
        frame.origin.y += downOffset;
        self.frame = frame;
        self.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        self.selected = NO;
        self.playing = NO;
    }];
}

- (void)flipAppear
{
    self.playing = YES;
    CABasicAnimation *flip = [CABasicAnimation animation];
    flip.keyPath = @"transform.rotation.y";
    flip.fromValue = @(M_PI_2);
    flip.toValue = @(0);
    flip.duration = flipDuration;
    flip.removedOnCompletion = NO;
    flip.fillMode = kCAFillModeForwards;
    flip.delegate = self;
    [self.layer addAnimation:flip forKey:@"flipAppear"];
    self.flipAppearAnimation = flip;
}

- (void)animationDidStart:(CAAnimation *)anim
{
    CABasicAnimation *basicAnim = (CABasicAnimation *)anim;
    if (self.flipAppearAnimation) {
        if ([basicAnim.fromValue isEqualToValue:self.flipAppearAnimation.fromValue]) {
            self.hidden = NO;
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CABasicAnimation *basicAnim = (CABasicAnimation *)anim;
    if (self.flipFadeAnimation) {
        if ([basicAnim.fromValue isEqualToValue:self.flipFadeAnimation.fromValue]) {
            self.hidden = YES;
        }
    }
    self.playing = NO;
}
#pragma mark - 响应事件
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    //仅当点击范围在六边形路径内，才返回YES
    return [self.hexagonPath containsPoint:point];
}
#pragma mark - 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.needLoadLabel) {
        [self.contentTitleLabel sizeToFit];
        self.contentTitleLabel.centerX = self.contentRect.size.width * 0.5;
        self.contentTitleLabel.centerY = self.contentRect.size.height * 0.5;
    }
}
#pragma mark - 懒加载
- (UILabel *)contentTitleLabel
{
    if (!_contentTitleLabel) {
        UILabel *titleLabel = [[UILabel alloc]init];
        [self addSubview:titleLabel];
        _contentTitleLabel = titleLabel;
    }
    return _contentTitleLabel;
}

#pragma mark - 计算函数
/**
 *  计算给指定坐标点围绕指定圆心旋转某一角度得到的点坐标
 *
 *  @param point  待旋转的初始坐标点
 *  @param center 围绕旋转的圆心
 *  @param angle  需要旋转的角度
 *
 *  @return 旋转的到的点坐标
 */
static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    //到圆心的位移 --> 半径长度
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    //旋转
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    //先计算 圆心角 * 半径 -> 弧长
    //再计算 弧长对应的弦长向量
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    //经仿射变换得到的点坐标
    return CGPointApplyAffineTransform(point, transformGroup);
}

@end

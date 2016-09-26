/*********************************************************************************
 *Copyright (c) 8-7 fangstar. All rights reserved.
 *FileName:     HexagonBackgroundView // 文件名
 *Author:       yanghan               // 创建文档的作者
 *Date:         8-7                   // 创建日期
 *Description:  容纳三个正六边形的背景view// 用于主要说明此程序文件完成的主要功能
 *Others:       无                    // 其他内容说明
 *History:                            // 修改历史记录列表，每条修改记录应包含修改日期、修改者及修改内容简介
 ********************************************************************************/

#import "HexagonBackgroundView.h"
#import "HexagonView.h"
#import "UIView+YHFrame.h"

#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1]

//默认内边距
static CGFloat const kHexagonsDefaultInset = 5;
//内边距的可调范围
static CGFloat const kHexagonsInsetAdjustableRange = 30;


@interface HexagonBackgroundView ()

/** 存储六边形view数组 **/
@property (nonatomic,strong) NSMutableArray<HexagonView *> * hexagonViews;
/** 是否展开 **/
@property (nonatomic,assign,getter=isUnfold) BOOL unfold;

@end

@implementation HexagonBackgroundView

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUIWithFrame:frame];
    }
    return self;
}
- (void)setupUIWithFrame:(CGRect)frame
{
    //清除背景色
    self.backgroundColor = [UIColor clearColor];
    
    //设置默认间距
    //不能用self
    _hexagonsInset = kHexagonsDefaultInset;
    //默认状态不展开
    self.unfold = NO;

    //在可调节范围内的矩形
    frame = (CGRect){frame.origin.x,frame.origin.y,frame.size.width - kHexagonsInsetAdjustableRange,frame.size.height - kHexagonsInsetAdjustableRange};
    
    //在可调节范围矩形内,计算正六边形外接正方形最大边长
    CGFloat maxSideLength = MaxHexagonViewLengthWithInset(frame.size,0);
    
    //初始化三个正六边形
    for (NSInteger i = 0; i < 3; i++) {
        HexagonView *v = [HexagonView hexagonWithRadius:maxSideLength];
        [self addSubview:v];
        [self.hexagonViews addObject:v];
        [v addTarget:self action:@selector(hexagonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //默认只显示左上角
        if (i != 0) {
            v.hidden = YES;
        }
    }
    //设置title,绑定tag,设置颜色
    [self setType];
}
- (void)setType
{
    self.hexagonViews[0].tag = HexagonContentTypeHouseSource;
    self.hexagonViews[0].text = @"房源";
    self.hexagonViews[0].contentColor = RGB(52,108,239);
    self.hexagonViews[1].tag = HexagonContentTypeHouses;
    self.hexagonViews[1].text = @"楼盘";
    self.hexagonViews[1].contentColor = RGB(133,0,3);
    self.hexagonViews[2].tag = HexagonContentTypeCommunity;
    self.hexagonViews[2].text = @"小区";
    self.hexagonViews[2].contentColor = RGB(192,136,8);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [self.hexagonViews[0] resetting];
}

#pragma mark - 监听点击
- (void)hexagonDidClick:(HexagonView *)hexagon
{
    HexagonView *v0 = self.hexagonViews[0];
    HexagonView *v1 = self.hexagonViews[1];
    HexagonView *v2 = self.hexagonViews[2];
    
    if (v0.isPlaying || v1.isPlaying || v2.isPlaying) return;
    
    //没被选中，点击才会调用代理方法
    if (!hexagon.isSelected) {
        if ([self.delegate respondsToSelector:@selector(hexagonBackgroundView:didSelectHexagonType:)]) {
            [self.delegate hexagonBackgroundView:self didSelectHexagonType:hexagon.tag];
        }
    }
 
    //被点击正六边形和左上角正六边形交换title和tag
    NSInteger clickType = hexagon.tag;
    NSString *clickText = hexagon.text;
    hexagon.text = v0.text;
    hexagon.tag = v0.tag;
    v0.tag = clickType;
    v0.text = clickText;
    
    //若当前未展开
    if (!self.isUnfold) {
        [v0 recover];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(v0.scaleDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [v1 flipAppear];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(v1.flipDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [v2 flipAppear];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(v2.flipDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.unfold = YES;
                });
            });
        });
       
    }else { // 若当前已展开
        [v2 flipFade];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(v2.flipDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [v1 flipFade];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(v1.flipDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [v0 shrink];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(v0.scaleDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.unfold = NO;
                });
            });
        });
        
    }
}

#pragma mark - setter
- (void)setHexagonsInset:(CGFloat)hexagonsInset
{
    _hexagonsInset = hexagonsInset;
    //如果外界设置了内边距，那么重新布局子控件
    if (hexagonsInset >= kHexagonsInsetAdjustableRange) {
        _hexagonsInset = kHexagonsInsetAdjustableRange;
    }else if (hexagonsInset <= 0) {
        _hexagonsInset = 0;
    }
    [self setNeedsLayout];
}

#pragma mark - 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    HexagonView *v0 = self.hexagonViews[0];
    HexagonView *v1 = self.hexagonViews[1];
    HexagonView *v2 = self.hexagonViews[2];
    
    //计算正六边形外接正方形左右的间隙长度
    CGFloat paddingLR = PaddingBetweenHexagonPathAndContentRectLR(v1.bounds.size.width);
    //计算正六边形外接正方形上下的间隙长度
    CGFloat paddingUD = PaddingBetweenHexagonPathAndContentRectUD(v1.bounds.size.width);
    
    //左上角
    v0.left = -paddingLR;
    v0.top = 0;
    
    //下方
    v1.centerX = v0.right - paddingLR + self.hexagonsInset * 0.5;
    v1.top = v0.bottom - paddingUD + self.hexagonsInset;
    
    //右上角
    v2.left = v0.right - 2 * paddingLR + self.hexagonsInset;
    v2.top = v0.top;
}

#pragma mark - 懒加载
- (NSMutableArray<HexagonView *> *)hexagonViews
{
    if (!_hexagonViews) {
        _hexagonViews = [NSMutableArray array];
    }
    return _hexagonViews;
}

#pragma mark - 计算
/**
 *  根据三个正六边形的内边距，以及容纳三个正六边形的矩形size,计算得到最大的正六边形边长的两倍
 *
 *  @param size  容纳矩形size
 *  @param inset 三个正六边形的内边距
 *
 *  @return 最大正六边形边长的两倍
 */
static CGFloat MaxHexagonViewLengthWithInset(CGSize size,CGFloat inset){
    //以容纳view高度为基准计算正六边形边长
    CGFloat hexagonRectLengthUD = ((size.height - inset) / 3.5) * 2;
    
    //以容纳view宽度为基准计算正六边形边长
    CGFloat rectSideLengthLR = size.width - inset;
    CGFloat hexagonRectLengthLR = (rectSideLengthLR / (2 * sqrt(3.0))) * 2;
    
    //取最小正六边形边长 - 内边距可调范围
    return MIN(hexagonRectLengthUD, hexagonRectLengthLR);
}

/**
 *  计算正六边形外接正方形左右间隙距离
 *
 *  @param rectWidth 外接正方形边长
 *
 *  @return 左右间隙距离
 */
static CGFloat PaddingBetweenHexagonPathAndContentRectLR(CGFloat rectWidth){
    return  rectWidth * 0.5 - rectWidth * 0.5 * cos(M_PI / 6);
}
/**
 *  计算正六边形外接正方形上下间隙距离
 *
 *  @param rectWidth 外接正方形边长
 *
 *  @return 左右间隙距离
 */
static CGFloat PaddingBetweenHexagonPathAndContentRectUD(CGFloat rectWidth){
    return rectWidth * 0.5 * sin(M_PI / 6);
}

@end

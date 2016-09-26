/*********************************************************************************
 *Copyright (c) 8-7 fangstar. All rights reserved.
 *FileName:     HexagonView           // 文件名
 *Author:       yanghan               // 创建文档的作者
 *Date:         8-7                   // 创建日期
 *Description:  正六边形view           // 用于主要说明此程序文件完成的主要功能
 *Others:       无                    // 其他内容说明
 *History:                            // 修改历史记录列表，每条修改记录应包含修改日期、修改者及修改内容简介
 ********************************************************************************/

#import <UIKit/UIKit.h>

@interface HexagonView : UIControl

/** 六边形区域填充色 **/
@property (nonatomic,strong) UIColor * contentColor;
/** 内容文字 **/
@property (nonatomic,copy) NSString * text;
/** 内容文字颜色 **/
@property (nonatomic,strong) UIColor * textColor;
/** 内容文字字体 **/
@property (nonatomic,strong) UIFont * font;
/** 翻转动画时长 **/
@property (nonatomic,assign,readonly) CGFloat flipDuration;
/** 缩放动画时长 **/
@property (nonatomic,assign,readonly) CGFloat scaleDuration;

@property (nonatomic,assign,getter=isPlaying,readonly) BOOL playing;
/**
 *  用外接圆半径初始化一个正六边形view
 *
 *  @param radius  外接圆半径
 *
 *  @return 正六边形view
 */
+ (instancetype)hexagonWithRadius:(CGFloat)radius;
/**
 *  初始化
 */
- (void)resetting;
/**
 *  翻转隐藏
 */
- (void)flipFade;
/**
 *  翻转出现
 */
- (void)flipAppear;
/**
 *  缩小动画
 */
- (void)shrink;
/**
 *  恢复原状
 */
- (void)recover;

@end

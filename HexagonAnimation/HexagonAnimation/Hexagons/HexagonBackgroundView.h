/*********************************************************************************
 *Copyright (c) 8-7 fangstar. All rights reserved.
 *FileName:     HexagonBackgroundView // 文件名
 *Author:       yanghan               // 创建文档的作者
 *Date:         8-7                   // 创建日期
 *Description:  容纳三个正六边形的背景view// 用于主要说明此程序文件完成的主要功能
 *Others:       无                    // 其他内容说明
 *History:                            // 修改历史记录列表，每条修改记录应包含修改日期、修改者及修改内容简介
 ********************************************************************************/

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,HexagonContentType) {
    HexagonContentTypeHouseSource = 1000,//房源
    HexagonContentTypeHouses, //楼盘
    HexagonContentTypeCommunity//小区
};

@class HexagonBackgroundView;

@protocol HexagonBackgroundViewDelegate <NSObject>
/**
 *  点击正六边形view的代理方法
 *
 *  @param hexagonBgView 三个正六边形view的容纳view
 *  @param type          被点击正六边形的类型
 */
- (void)hexagonBackgroundView:(HexagonBackgroundView *)hexagonBgView didSelectHexagonType:(HexagonContentType)type;

@end

@interface HexagonBackgroundView : UIView

/** 三个正六边形的间距 **/
@property (nonatomic,assign) CGFloat hexagonsInset;
/** 代理 **/
@property (nonatomic,weak) id<HexagonBackgroundViewDelegate>  delegate;

@end

//
//  RSPendant.h
//
//  Created by jerrysun on 2016/10/26.
//  Copyright © 2016年 hydee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DraperDelegate;


@interface DraperCard : UIView
@property (nonatomic ,weak) id <DraperDelegate> delegate;
@property (nonatomic ,assign) CGPoint originCenter;
@property (nonatomic ,strong) UIImageView *imageView;
@property (nonatomic ,strong) UILabel *titleLab;

@property (nonatomic,copy) void (^runThrow)(DraperCard *pendant);

- (void)addAnimatorsWithReferenceView:(UIView *)refrenceView;
- (void)removeAllAnimations;
@end

@protocol DraperDelegate <NSObject>
@required

// 开始移除
-(void)draperBeginMoveOut:(DraperCard *)draper;
@optional
// 开始拖动
-(void)draperBeginDrag:(DraperCard *)draper;
// 正在拖动
-(void)draperDraging:(DraperCard *)draper;
// 完全移除
-(void)draperMoveOut:(DraperCard *)draper;
// 开始归位
-(void)draperRegress:(DraperCard *)draper;

-(void)draperDidTap:(DraperCard *)draper;

@end

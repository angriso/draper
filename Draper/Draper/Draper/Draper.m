//
//  Draper.m
//  DynamicBehavior
//
//  Created by jerrysun on 16/5/20.
//  Copyright © 2016年 hydee. All rights reserved.
//

#import "Draper.h"


@interface Draper ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachment;
@property (nonatomic ,strong) UIGravityBehavior *gravity;
@property (nonatomic ,strong) UIPushBehavior *shakePush; // 摇晃的推力
@property (nonatomic ,strong) UIPushBehavior *throwPush; // 扔掉的推力
@property (nonatomic ,strong) UIDynamicItemBehavior *itemBehavior;
@end
@implementation Draper{
    CGPoint  _currentPoint,_firstPoint,_velocity;
    CGFloat _magnitude;
}
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self configure];
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        [self configure];
    }
    return self;
}

-(void)configure{
    
   [self.layer setCornerRadius:4.0];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,-4);
    self.layer.shadowOpacity = 0.4;
    
    
    _imageView = [[UIImageView alloc] init];
    _imageView.frame =  CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10);
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.layer.cornerRadius = 4.0;
    _imageView.clipsToBounds = YES;
    
    [self addSubview:_imageView];
    
    
    _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _titleLab.font = [UIFont systemFontOfSize:35];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLab];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
    
    [self addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
}
-(void)willMoveToSuperview:(UIView *)newSuperview{
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:newSuperview];
    self.animator = animator;
}
- (void)tapAction:(UITapGestureRecognizer *)tap{
    if ([_delegate respondsToSelector:@selector(draperDidTap:)]) {
        [_delegate draperDidTap:self];
    }
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    
    
    _velocity = [pan velocityInView:self];
    _magnitude = sqrtf((_velocity.x * _velocity.x) + (_velocity.y * _velocity.y));
    
    CGPoint superPoint = [pan locationInView:pan.view.superview];
    _currentPoint = superPoint;
    
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        CGPoint  location = [pan locationInView:self];
        UIOffset offset = UIOffsetMake(location.x-self.frame.size.width/2, location.y-self.frame.size.height/2);
        _firstPoint = superPoint;
        
        [self.animator removeAllBehaviors];
        
        // 重力效果
        self.gravity = [[UIGravityBehavior alloc] initWithItems:@[self]];
        self.gravity.magnitude = 2;
        [self.animator addBehavior:self.gravity];
        
        // 吸附效果关键在于吸附点这个是核心
        self.attachment= [[UIAttachmentBehavior alloc] initWithItem:self offsetFromCenter:offset attachedToAnchor:superPoint];
        [self.animator addBehavior:self.attachment];
        
        // 摇动时候给一个作用力
        self.shakePush = [[UIPushBehavior alloc] initWithItems:@[self] mode:UIPushBehaviorModeInstantaneous];
        [self.animator addBehavior:_shakePush];
        
        // 自定义效果添加旋转
        self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
        // 角速度阻力
        _itemBehavior.angularResistance = 0.5;
        [self.animator addBehavior:_itemBehavior];
        
        
        if ([_delegate respondsToSelector:@selector(draperBeginDrag:)]) {
            [_delegate draperBeginDrag:self];
        }
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
    
        self.attachment.anchorPoint = superPoint;

        _shakePush.pushDirection = CGVectorMake((_velocity.x / 10) , (_velocity.y / 10));
        _shakePush.magnitude = _magnitude/60;
        _shakePush.active = YES;
        
        
        // 根据速度判断如何添加角速度
        
        NSInteger plusMinus;

        if (fabs(_velocity.x) >= fabs(_velocity.y)) {
            plusMinus = _velocity.x>0 ? -1 : 1;
        }else{
            plusMinus = _velocity.y>0 ? -1 : 1;
        }
        CGFloat angularVelocity = _magnitude/1000 * plusMinus;
        
        [_itemBehavior addAngularVelocity:angularVelocity forItem:self];
        
        
        if ([_delegate respondsToSelector:@selector(draperDraging:)]) {
            [_delegate draperDraging:self];
        }
        
    } else if (pan.state == UIGestureRecognizerStateEnded||
               pan.state == UIGestureRecognizerStateCancelled||
               pan.state == UIGestureRecognizerStateFailed){
        
        if (_magnitude >= 400||
            self.center.y > pan.view.superview.frame.size.height
            ){
            [self triggeParabolicMotion];
        }else{
            
            if ([_delegate respondsToSelector:@selector(draperRegress:)]) {
                [_delegate draperRegress:self];
            }
            
            [self.animator removeAllBehaviors];
            [UIView animateKeyframesWithDuration:0.7 delay:0.0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
                self.center = _originCenter;
                self.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
}

-(void)triggeParabolicMotion{
    
    
    self.userInteractionEnabled = NO;
    
    if ([_delegate respondsToSelector:@selector(draperBeginMoveOut:)]) {
        [_delegate draperBeginMoveOut:self];
    }
    
    [self.animator removeBehavior:self.attachment];
    
    // 3. 添加推动行为
    self.throwPush = [[UIPushBehavior alloc] initWithItems:@[self] mode:UIPushBehaviorModeInstantaneous];
    
    
    _throwPush.pushDirection = CGVectorMake((_velocity.x / 10) , (_velocity.y / 10));

    //_push.magnitude = _magnitude / 20;
    
    CGPoint offset = CGPointMake(_currentPoint.x - _firstPoint.x, _currentPoint.y - _firstPoint.y);
    
    // angle和pushDirection 的效果都是设定作用力的方向
    
    /*
      CGFloat angle = atan(offset.y / offset.x);
      if (_currentPoint.x > _firstPoint.x) { angle = angle - M_PI;}
      _push.angle =  - angle;
     */
    
    CGFloat distance = hypot(offset.y, offset.x);
    _throwPush.magnitude = distance/1.5;
    _throwPush.active = YES;
    
    [self.animator addBehavior:_throwPush];
    

}
- (void)resetDraper
{
    
    [self.animator removeAllBehaviors];
     self.transform = CGAffineTransformIdentity;
     self.userInteractionEnabled = YES;

    
    if ([_delegate respondsToSelector:@selector(draperMoveOut:)]) {
        [_delegate draperMoveOut:self];
    }
   
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"ceter"context:nil];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context  {
    if ([keyPath isEqualToString:@"center"]) {
        
        if (CGRectIsEmpty(CGRectIntersection(self.superview.bounds, self.frame))||
            CGRectIsNull(CGRectIntersection(self.superview.bounds, self.frame))) {
            [self resetDraper];
        }
    }
}


@end

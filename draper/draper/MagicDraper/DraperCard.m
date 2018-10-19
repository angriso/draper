//
//  RSPendant.m
//
//  Created by jerrysun on 2016/10/26.
//  Copyright © 2016年 hydee. All rights reserved.
//

#import "DraperCard.h"
#import "Derivator.h"
@interface DraperCard ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachment;
@property (nonatomic ,strong) UIGravityBehavior *gravity;
@property (nonatomic ,strong) UIPushBehavior *shakePush;
@property (nonatomic ,strong) UIPushBehavior *throwPush;
@property (nonatomic ,strong) UIDynamicItemBehavior *itemBehavior;
@property (nonatomic ,strong) Derivator *der;
@end
@implementation DraperCard{
    CGPoint _currentPoint;
    CGPoint _firstPoint;
    CGPoint _velocity;
    CGFloat _magnitude;
}
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
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
    
    _der = [[Derivator alloc] init];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.frame =  CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10);
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.layer.cornerRadius = 4.0;
    _imageView.userInteractionEnabled = YES;
    _imageView.clipsToBounds = YES;
    
    [self addSubview:_imageView];
    
    
    _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _titleLab.font = [UIFont systemFontOfSize:35];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLab];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
}

- (void)addAnimatorsWithReferenceView:(UIView *)refrenceView
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:refrenceView];
    // 重力效果
    self.gravity = [[UIGravityBehavior alloc] initWithItems:@[self]];
    // 摇动时候给一个作用力
    self.shakePush = [[UIPushBehavior alloc] initWithItems:@[self] mode:UIPushBehaviorModeInstantaneous];
    // 自定义效果添加旋转
    self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
    
    self.attachment = [[UIAttachmentBehavior alloc] initWithItem:self attachedToAnchor:CGPointMake(0.5, 0.5)];
    
    // 3. 添加推动行为
    self.throwPush = [[UIPushBehavior alloc] initWithItems:@[self] mode:UIPushBehaviorModeInstantaneous];
    
    __weak typeof (self) weakSelf = self;
    [self.throwPush setAction:^{
        if (weakSelf.runThrow) {
            weakSelf.runThrow(weakSelf);
        }
    }];
    
}
- (void)tapAction:(UITapGestureRecognizer *)tap{
    if ([_delegate respondsToSelector:@selector(draperDidTap:)]) {
        [_delegate draperDidTap:self];
    }
}
- (void)removeAllAnimations{
    [self.animator removeAllBehaviors];
}


- (void)panAction:(UIPanGestureRecognizer *)pan {
    
    _velocity = [pan velocityInView:self];
    _magnitude = sqrtf((_velocity.x * _velocity.x) + (_velocity.y * _velocity.y));
    
    CGPoint superPoint = [pan locationInView:pan.view.superview];
    _currentPoint = superPoint;
    
    static UIOffset offset;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        CGPoint  location = [pan locationInView:self];
        offset = UIOffsetMake(location.x-self.frame.size.width/2, location.y-self.frame.size.height/2);
        
//        CGFloat d = sqrtf((offset.horizontal*offset.horizontal) + (offset.vertical*offset.vertical));
//        
//        d*d /

        
        _firstPoint = superPoint;
        
        [self.animator removeAllBehaviors];
        
        // 重力效果
        self.gravity.magnitude = 2;
        [self.animator addBehavior:self.gravity];
        
        // 吸附效果关键在于吸附点这个是核心
        self.attachment= [[UIAttachmentBehavior alloc] initWithItem:self offsetFromCenter:offset attachedToAnchor:superPoint];
        
        // 此处 attachedToAnchor 与 layer的anchor不同
        
        // 这种方式可以创建一次每次调整锚点复位之后也要将锚点复位很烦不如每次创建得了
        //        CGPoint achor = CGPointMake(location.x/self.frame.size.width, location.y/self.frame.size.height);
        //        self.layer.anchorPoint = achor;
        //
        //        self.frame = CGRectMake(self.originCenter.x-self.frame.size.width/2, self.originCenter.y-self.frame.size.height/2, self.frame.size.width, self.frame.size.height);
         //        self.attachment.anchorPoint = superPoint;
        
        [self.animator addBehavior:self.attachment];
        
        
       // [self.animator addBehavior:_shakePush];
        
       
        // 角速度阻力
        _itemBehavior.angularResistance = 0.5;
        [self.animator addBehavior:_itemBehavior];
        
        
        if ([_delegate respondsToSelector:@selector(draperBeginDrag:)]) {
            [_delegate draperBeginDrag:self];
        }
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
        self.attachment.anchorPoint = superPoint; //这个是变化的一定要
        
        [_shakePush setTargetOffsetFromCenter:offset forItem:self];
        _shakePush.pushDirection = CGVectorMake((_velocity.x) , (_velocity.y));
        _shakePush.magnitude = _magnitude/10;
        _shakePush.active = YES;
//
//        NSLog(@"%@",NSStringFromCGVector(_shakePush.pushDirection));
//        NSLog(@"%f",_shakePush.magnitude);
        
        
        // 根据速度判断如何添加角速度
        
        CGPoint sPoint = [pan locationInView:pan.view];
        //NSLog(@"%@",NSStringFromCGPoint(sPoint));

        
        NSInteger sign;
        
        if (fabs(_velocity.x) >= fabs(_velocity.y)) {
            sign = _velocity.x>0 ? -1 : 1;
        }else{
            sign = _velocity.y>0 ? -1 : 1;
        }
        if (sPoint.x>self.frame.size.width/2) {
            sign = 0 - sign;
        }
        
        CGFloat angularVelocity = _magnitude/1000 * sign *1.4 ;
        
        if (sPoint.x>self.frame.size.width/3 && sPoint.x<self.frame.size.width/3*2) {
            angularVelocity = angularVelocity/2;
        }
        
        
        //NSLog(@"%f",angularVelocity * 180 / M_PI);
        [_itemBehavior addAngularVelocity:angularVelocity forItem:self];
        
        
        if ([_delegate respondsToSelector:@selector(draperDraging:)]) {
            [_delegate draperDraging:self];
        }
        
        [_der addValue:_magnitude limitTime:0.3];
        
    } else if (pan.state == UIGestureRecognizerStateEnded||
               pan.state == UIGestureRecognizerStateCancelled||
               pan.state == UIGestureRecognizerStateFailed){
        
        if (_magnitude >= 400||
            self.center.y > pan.view.superview.frame.size.height
            ){
            [self triggeParabolicMotion:pan];
        }else{
            
            if ([_delegate respondsToSelector:@selector(draperRegress:)]) {
                [_delegate draperRegress:self];
            }
            
            [self.animator removeAllBehaviors];
            [UIView animateKeyframesWithDuration:0.7 delay:0.0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
                self.center = self.originCenter;
                //self.layer.anchorPoint = CGPointMake(0.5, 0.5);
                self.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
}

-(void)triggeParabolicMotion:(UIPanGestureRecognizer *)sender{
    
    if ([_delegate respondsToSelector:@selector(draperBeginMoveOut:)]) {
        [_delegate draperBeginMoveOut:self];
    }
    
    [self.animator removeBehavior:self.attachment];
    
    
    _velocity = [sender velocityInView:self];
    //NSLog(@"%@",NSStringFromCGPoint(_velocity));
    _magnitude = sqrtf((_velocity.x * _velocity.x) + (_velocity.y * _velocity.y));
    [_der addValue:_magnitude limitTime:0.3];

    
    CGFloat minVeloctiy  = MIN(fabs(_velocity.x), fabs(_velocity.y));
    _throwPush.pushDirection = CGVectorMake((_velocity.x / minVeloctiy) , (_velocity.y / minVeloctiy));
    

    //CGPoint  location = [sender locationInView:self];
    //UIOffset offset = UIOffsetMake(location.x-self.frame.size.width/2, location.y-self.frame.size.height/2);
    [_throwPush setTargetOffsetFromCenter:UIOffsetMake(0, 0) forItem:self];

    // angle和pushDirection 的效果都是设定作用力的方向
    
    /*
     CGFloat angle = atan(offset.y / offset.x);
     if (_currentPoint.x > _firstPoint.x) { angle = angle - M_PI;}
     _push.angle =  - angle;
     */
    
    Derivator *ld = [_der.samples lastObject];
    Derivator *fd = [_der.samples firstObject];

    
    double value = ld.value - fd.value;
    double time = ld.time - fd.time;
    
    CGFloat mag = value/time/300;
    
    _throwPush.magnitude = mag;

   // NSLog(@"----%f",mag);
    
//    CGPoint offset_ = CGPointMake(_currentPoint.x - _firstPoint.x, _currentPoint.y - _firstPoint.y);
//    CGFloat distance = hypot(offset_.y, offset_.x);
    
    //_throwPush.magnitude = distance/1.5;
    _throwPush.active = YES;
    
    [self.animator addBehavior:_throwPush];
    
}
- (void)resetDraper
{
    
    [self.animator removeAllBehaviors];
    //self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.transform = CGAffineTransformIdentity;
    
    
    if ([_delegate respondsToSelector:@selector(draperMoveOut:)]) {
        [_delegate draperMoveOut:self];
    }
    
}

-(void)dealloc{
    NSLog(@"RSPendant---Dealloc");
}
@end

//
//  UIImage+Blur.h
//  SSCardDemo
//
//  Created by sonny on 16/3/12.
//  Copyright © 2016年 sonny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blur)

- (UIImage *)blurImageWithBlur:(CGFloat)blur exclusionPath:(UIBezierPath *)exclusionPath;

@end

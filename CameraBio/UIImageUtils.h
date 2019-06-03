//
//  UIImageUtils.h
//  FaceCapture
//
//  Created by Arkivus on 09/03/17.
//  Copyright © 2017 Arkivus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageUtils : NSObject

+ (UIImage *)flipImage:(UIImage *)image;

+ (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees;

+ (NSString *)getBase64Image:(UIImage*)image;

@end

//
//  UIImageUtils.m
//  FaceCapture
//
//  Created by Arkivus on 09/03/17.
//  Copyright © 2017 Arkivus. All rights reserved.
//

#import "UIImageUtils.h"

@implementation UIImageUtils

+ (UIImage *)flipImage:(UIImage *)image {
    UIGraphicsBeginImageContext(image.size);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(0.,0., image.size.width, image.size.height), image.CGImage);
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}

+ (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees {
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, oldImage.size.height, oldImage.size.width)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.height / 2, -oldImage.size.width / 2, oldImage.size.height, oldImage.size.width), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString *)getBase64Image:(UIImage*)image {
    NSString *base64Image = nil;
    
    @try {
        NSData *imageData;
        if (image.size.width == 480) {
            imageData = UIImageJPEGRepresentation(image, 1.0);
        } else {
            imageData = UIImageJPEGRepresentation(image, 0.8);
        }
        
        base64Image = [imageData base64EncodedStringWithOptions:0];
    }
    @catch (NSException *exception) {
        NSLog(@"error while get base64Image: %@", [exception reason]);
    }
    
    return base64Image;
}

@end

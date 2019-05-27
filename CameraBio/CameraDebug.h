//
//  CameraDebug.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 24/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraDebug : NSObject {
    
    UIView *viewLog;
    UILabel *lbNosePosition;
    UILabel *lbRightEye;
    UILabel *lbLeftEye;
    UILabel *lbRightEar;
    UILabel *lbLeftEar;
    UILabel *lbEulerX;
    UILabel *lbSpaceEye;
    
}


- (id)initWithView:(UIView *)view;

@property (strong,nonatomic) UIView *view;

-(void)showLogs : (float)screen_width screen_height: (float)screen_height topOffsetPercent: (float)topOffsetPercent  sizeBetweenTopAndBottomPercent: (float)sizeBetweenTopAndBottomPercent marginOfSides : (float) marginOfSides ;


- (void)clearDots;
- (void)addCircleToPoint : (CGPoint) point color : (UIColor *)color;
- (void)addLabelToLog : (CGPoint) point type : (NSString * )type;


@end

NS_ASSUME_NONNULL_END

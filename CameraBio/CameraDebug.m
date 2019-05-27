//
//  CameraDebug.m
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 24/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "CameraDebug.h"

@implementation CameraDebug


- (id)initWithView:(UIView *)view
{
    self = [super init];
    if(self) {
        self.view = view;
    }
    return self;
}


-(void)showLogs : (float)screen_width screen_height: (float)screen_height topOffsetPercent: (float)topOffsetPercent  sizeBetweenTopAndBottomPercent: (float)sizeBetweenTopAndBottomPercent marginOfSides : (float) marginOfSides  {
    
    UIButton *btClear = [[UIButton alloc]initWithFrame:CGRectMake(20, screen_height - 100 , 80, 50)];
    [btClear setTitle:@"RESET" forState:UIControlStateNormal];
    [btClear.titleLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:14.0]];
    [btClear setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btClear setBackgroundColor:[UIColor blackColor]];
    [btClear addTarget:self action:@selector(clearDots) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btClear];
    
    viewLog = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 160)];
    [viewLog setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:viewLog];
    
    lbLeftEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 150, 20)];
    [self setLayoutToLabel:lbLeftEye];
    [viewLog addSubview:lbLeftEye];
    
    lbRightEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 150, 20)];
    [self setLayoutToLabel:lbRightEye];
    [viewLog addSubview:lbRightEye];
    
    lbNosePosition = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 150, 20)];
    [self setLayoutToLabel:lbNosePosition];
    [viewLog addSubview:lbNosePosition];
    
    lbLeftEar = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 150, 20)];
    [self setLayoutToLabel:lbLeftEar];
    [viewLog addSubview:lbLeftEar];
    
    lbRightEar = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 150, 20)];
    [self setLayoutToLabel:lbRightEar];
    [viewLog addSubview:lbRightEar];
    
    lbEulerX = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 150, 20)];
    [self setLayoutToLabel:lbEulerX];
    [viewLog addSubview:lbEulerX];
    
    lbSpaceEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 140, 150, 20)];
    [self setLayoutToLabel:lbSpaceEye];
    [viewLog addSubview:lbSpaceEye];
    
    UIView *v1 = [[UIView alloc]initWithFrame:CGRectMake(0, topOffsetPercent, screen_width, 2)];
    [v1 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:v1];
    
    UIView *v2 = [[UIView alloc]initWithFrame:CGRectMake(0, sizeBetweenTopAndBottomPercent, screen_width, 2)];
    [v2 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:v2];
    
    UIView *v3 = [[UIView alloc]initWithFrame:CGRectMake(marginOfSides, 0, 2, screen_height)];
    [v3 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:v3];
    
    UIView *v4 = [[UIView alloc]initWithFrame:CGRectMake(screen_width - marginOfSides, 0, 2, screen_height)];
    [v4 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:v4];
    
}

- (void)setLayoutToLabel  : (UILabel *)label{
    [label setFont:[UIFont systemFontOfSize:10.0]];
    [label setTextColor: [UIColor blackColor]];
    [label setTag:-1];
}

- (void)clearDots {
    for (UIView *view in [self.view subviews]) {
        if(view.tag == - 1) {
            [view removeFromSuperview];
        }
    }
}


- (void)addCircleToPoint : (CGPoint) point color : (UIColor *)color{
    
    CGFloat widht = 10;
    
    CGFloat POINT_X = point.x;
    CGFloat POINT_Y = point.y;
    
    CGRect circleRect = CGRectMake(POINT_X - (widht / 2), POINT_Y - (widht / 2), widht, widht);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIView *circleView = [[UIView alloc] initWithFrame:circleRect];
        circleView.layer.cornerRadius = widht/2;
        circleView.alpha = 0.7;
        circleView.backgroundColor = color;
        circleView.tag = -1;
        [self.view addSubview:circleView];
        
    });
    
}

- (void)addLabelToLog : (CGPoint) point type : (NSString * )type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([type isEqualToString:@"left_eye"]) {
            [self->lbLeftEye setText:[NSString stringWithFormat:@"Leyft eye - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"right_eye"]) {
            [self->lbRightEye setText:[NSString stringWithFormat:@"Right eye - X: %.0f Y: %.0f", point.x, point.y]];
        }if([type isEqualToString:@"left_ear"]) {
            [self->lbLeftEar setText:[NSString stringWithFormat:@"Leyft ear - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"right_ear"]) {
            [self->lbRightEar setText:[NSString stringWithFormat:@"Right ear - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"euler"]) {
            [self->lbEulerX setText:[NSString stringWithFormat:@"Euler X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"space-eye"]) {
            [self->lbSpaceEye setText:[NSString stringWithFormat:@"Space eye: %.0f", point.x]];
        }else{
            [self->lbNosePosition setText:[NSString stringWithFormat:@"Base nose - X: %.0f Y: %.0f", point.x, point.y]];
        }
        
    });
    
}

@end

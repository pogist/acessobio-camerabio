//
//  CameraFrame.m
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 24/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "CameraFrame.h"
#import "CameraMain.h"


@implementation CameraFrame

- (id)initWithView:(CameraMain *)cameraMain button: (UIButton *)button autoCapture: (BOOL)autoCapture contagem: (BOOL) contagem view: (UIView*)view
{
    self = [super init];
    if(self) {
        self.cameraMain = cameraMain;
        self.btTakePicture = button;
        self.isAutoCapture = autoCapture;
        self.isContagem = contagem;
        self.view = view;
        
        [self setOffsetTopPercent:30.0f];
        [self setSizePercentBetweenTopAndBottom:50.0f];
        [self setMarginOfSides:80.0f];
        [self setupFrame];
    }
    return self;
}

-(void)setCountdownValue:(NSInteger)countdownValue {
    countDown = countdownValue;
}

- (void)setOffsetTopPercent : (float)percent {
    topOffsetPercent = percent/100 *  SCREEN_HEIGHT;
}

- (void)setSizePercentBetweenTopAndBottom  : (float)percent{
    float pixels = percent/100 *  SCREEN_HEIGHT;
    sizeBetweenTopAndBottomPercent = topOffsetPercent + pixels;
}

- (void)setMarginOfSides: (float)margin {
    marginOfSides = margin;
}

- (float)getOffsetTopPercent {
    return topOffsetPercent;
}

- (float)getSizePercentBetweenTopAndBottom {
   return sizeBetweenTopAndBottomPercent;
}

- (float)getMarginOfSides{
    return marginOfSides;
}


- (void)setupFrame {
    
    rectangle = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 5, self.view.bounds.size.width, 5)];
    [rectangle setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:rectangle];
    
    rectangleTop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 5)];
    [rectangleTop setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:rectangleTop];
    
    rectangleLeft = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, self.view.bounds.size.height)];
    [rectangleLeft setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:rectangleLeft];
    
    rectangleRight = [[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 5, 0, 5, self.view.bounds.size.height)];
    [rectangleRight setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:rectangleRight];
    
    [self.view addSubview:self.btTakePicture];
    
    /*  UIButton *btSwitch = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 50) - 20, SCREEN_HEIGHT - 90, 50, 50)];
     [btSwitch setImage:[UIImage imageNamed:@"switch_cam"] forState:UIControlStateNormal];
     [[btSwitch imageView] setContentMode: UIViewContentModeScaleAspectFit];
     [btSwitch addTarget:self action:@selector(switchCam) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:btSwitch]; */
    
    
    lbCountPic = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH/2) - 50, (SCREEN_HEIGHT/2) - 60 , 100, 120)];
    [lbCountPic setTextColor: [UIColor darkGrayColor]];
    [lbCountPic setTag:-1];
    [lbCountPic setText:@"3"];
    [lbCountPic setTextAlignment:NSTextAlignmentCenter];
    [lbCountPic setAlpha:0.7];
    [lbCountPic setFont:[UIFont fontWithName:@"Avenir-Medium" size:120]];
    [lbCountPic setHidden:YES];
    [self.view addSubview:lbCountPic];
    
}

- (void)showRed{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self->timerCountDown != nil) {
            [self resetTimer];
        }
        
        [self.btTakePicture setAlpha:0.5];
        [self.btTakePicture setEnabled:NO];
        [self->rectangle setBackgroundColor:[UIColor redColor]];
        [self->rectangleTop setBackgroundColor:[UIColor redColor]];
        [self->rectangleLeft setBackgroundColor:[UIColor redColor]];
        [self->rectangleRight setBackgroundColor:[UIColor redColor]];
        
    });
}

- (void)showGray{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self->timerCountDown != nil) {
            [self resetTimer];
        }
        
        [self.btTakePicture setAlpha:0.5];
        [self.btTakePicture setEnabled:NO];
        [self->rectangle setBackgroundColor:[UIColor grayColor]];
        [self->rectangleTop setBackgroundColor:[UIColor grayColor]];
        [self->rectangleLeft setBackgroundColor:[UIColor grayColor]];
        [self->rectangleRight setBackgroundColor:[UIColor grayColor]];
        
    });
}

- (void)showGreen{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.isAutoCapture) {
            if(!self->isCountDown) {
                [self performSelector:@selector(createTimer) withObject:nil afterDelay:1];;
                self->isCountDown = YES;
            }
        }
        
        [self.cameraMain.view hideToasts];
        
        [self.btTakePicture setAlpha:1];
        [self.btTakePicture setEnabled:YES];
        [self->rectangle setBackgroundColor:[UIColorBio getColorPrimary]];
        [self->rectangleTop setBackgroundColor:[UIColorBio getColorPrimary]];
        [self->rectangleLeft setBackgroundColor:[UIColorBio getColorPrimary]];
        [self->rectangleRight setBackgroundColor:[UIColorBio getColorPrimary]];
        
    });
}

- (void)resetTimer {
    [self->timerCountDown invalidate];
    [self->lbCountPic setHidden:YES];
    self->countDown = 3;
    self->isCountDown = NO;
    self->timerCountDown = nil;
}

- (void)createTimer {
    if(!self.isContagem) {
        countDown = 0;
        [self countDown];
    }else{
        self->timerCountDown = [NSTimer scheduledTimerWithTimeInterval:1
                                                                target:self
                                                              selector:@selector(countDown)
                                                              userInfo:nil
                                                               repeats:YES];
    }
    
}

- (void)countDown {
    
    [lbCountPic setHidden:NO];
    [lbCountPic setText:[NSString stringWithFormat:@"%lu",countDown]];
    
    if(countDown == 0) {
        [self resetTimer];
        [self.cameraMain invokeTakePicture];
    }
    
    countDown --;
    
}



@end

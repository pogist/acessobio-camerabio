//
//  DocumentInsertView.m
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 20/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "DocumentInsertView.h"
#import "CameraBio.h"

@interface DocumentInsertView ()

@end

@implementation DocumentInsertView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupCamera:isSelfie];
    [self startCamera];
    
    UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    if(self.type == 4) {
        [iv setImage:[UIImage imageNamed:@"frame_cnh"]];
    }else if (self.type == 501) {
        [iv setImage:[UIImage imageNamed:@"frame_rg_frente"]];
    }else if (self.type == 502){
        [iv setImage:[UIImage imageNamed:@"frame_rg_verso"]];
    }else{
        [iv setHidden:YES];
    }
    
    [self.view addSubview:iv];
    
    
    [self.btTakePic setEnabled:YES];
    [self.btTakePic setAlpha:1.0];
    [self.btTakePic setFrame:CGRectMake((SCREEN_WIDTH/2) - 25, SCREEN_HEIGHT - 75, 60, 60)];

    [self.view addSubview:self.btTakePic];
    
}

- (void)actionAfterTakePicture : (NSString *)base64 {
    [self.cam onSuccessCaptureDocument:base64];
}



@end

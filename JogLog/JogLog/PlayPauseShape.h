//
//  PauseShape.h
//  SoundCompass
//
//  Created by Matthew Ragonese on 9/5/13.
//  Copyright (c) 2013 sharif ahmed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayPauseShape : UIView
{
    UIBezierPath *aPath;
    UIBezierPath *bPath;
    
    UIColor *fillColor;
    UIColor *lineColor;
    
    BOOL drawingForFirstTime;
}

-(void)showPlayImage;
-(void)showPauseImage;

@end

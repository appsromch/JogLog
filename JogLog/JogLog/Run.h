//
//  Run.h
//  RunRagoneseRun
//
//  Created by Matthew Ragonese on 5/1/13.
//  Copyright (c) 2013 Matthew Ragonese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Run : NSObject

@property(nonatomic)int totalTime;
@property(nonatomic)float totalDistance;
@property(nonatomic)float averagePace;

//Display Strings
@property(nonatomic, retain)NSString *totalTimeString;
@property(nonatomic, retain)NSString *totalDistanceString;
@property(nonatomic, retain)NSString *averagePaceString;


-(id)initWithTotalTime:(int)time
         TotalDistance:(float)distance;

@end

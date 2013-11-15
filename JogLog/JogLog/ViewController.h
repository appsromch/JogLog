//
//  ViewController.h
//  JogLog
//
//  Created by Matthew Ragonese on 10/15/13.
//  Copyright (c) 2013 Matthew Ragonese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Run.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MarqueeLabel.h"
#import "CustomCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "BackShape.h"
#import "NextShape.h"
#import "PlayPauseShape.h"


@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, MKOverlay, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    //*** AppDelegate ***//
        __weak AppDelegate *AD;
    
    
    //*** Manages both Map Page and Player Page ***//
        IBOutlet UIScrollView *scrollView;
        IBOutlet UIPageControl *pageControl;
    
    
    //*** Map Page Variables ***//
    
        //For location tracking and display
        CLLocationManager *locationManager;
        IBOutlet MKMapView *worldView;
        BOOL hasInitiallyFoundCurrentLocation;
        MKPolyline *routeLine;
        NSMutableArray *routePoints;
        IBOutlet UIActivityIndicatorView *activityIndicator;

        //Variables pertaining to individual Runs
        Run *recentRun;
        IBOutlet UIButton *beginAndEndButton;
        IBOutlet UILabel *runDistanceLabel;
        IBOutlet UILabel *runDurationLabel;
        IBOutlet UILabel *runPaceLabel;
        IBOutlet UILabel *recordingStatusLabel;
        BOOL recordingRun;
        NSTimer *runTimer;
        int currentTime;
        float runDistance;
    
        //Map Page UI Elements for Player Control (notated with "MP" for "MapPage")
        IBOutlet UIView *songInfoViewMP;
        IBOutlet UIButton *playPauseButtonMP; //button atop playPauseShape
        PlayPauseShape *playPauseShapeMP;
        IBOutlet MarqueeLabel *currentSongLabelMP;
        IBOutlet UILabel *currentlyPlayingArtistMP;

    
    //*** Player Page Variables ***//
    
        //Variables controlling songsTable
        IBOutlet UITableView *songsTable;
        NSMutableArray *songList;
        BOOL playlistFound;
        MPMusicPlayerController *myPlayer;
        int indexOfCurrentTrack;
        BOOL isPlaying;
        
        //Player Page UI Elements (notated with "PP" for "PlayerPage")
        IBOutlet UIView *songInfoViewPP;
        IBOutlet UIButton *playPauseButtonPP;
        IBOutlet UIButton *backButtonPP;
        IBOutlet UIButton *forwardButtonPP;
        BackShape *backShapePP;
        NextShape *nextShapePP;
        PlayPauseShape *playPauseShapePP;
        IBOutlet MarqueeLabel *currentlySongLabelPP;
        IBOutlet UILabel *currentlyPlayingArtistPP;
        IBOutlet UIImageView *currentlyPlayingArtworkPP;
}

@property (nonatomic, retain) MKPolyline* polyline; //Line for drawing atop MKMapView

-(IBAction)beginAndEndButtonPressed:(UIButton*)sender; //Begins and ends the recording of a Run
-(IBAction)playPauseButtonPressed:(UIButton*)sender; //Starts or ends the playlist's current song
-(IBAction)backButtonPressed:(UIButton*)sender; //Selects previous track in playlist for playback
-(IBAction)forwardButtonPressed:(UIButton*)sender; //Selects next track in playlist for playback
-(IBAction)changePage:(id)sender; //UIPageControll method for side swiping

@end

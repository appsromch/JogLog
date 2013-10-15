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

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, MKOverlay, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    __weak AppDelegate *AD;
    
    CLLocationManager *locationManager;
    
    IBOutlet MKMapView *worldView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    //IBOutlet UITextField *locationTitleField;
    
    BOOL hasInitiallyFoundCurrentLocation;
    
    MKPolyline *routeLine;
    
    NSMutableArray *routePoints;
    
    //IBOutlet UIButton *beginAndEndButton;
    BOOL recordingRun;
    IBOutlet UIButton *beginAndEndButton;
    
    IBOutlet UILabel *runDurationLabel;
    NSTimer *runTimer;
    int currentTime;
    
    IBOutlet UILabel *runDistanceLabel;
    float runDistance;
    
    IBOutlet UILabel *runPaceLabel;
    
    IBOutlet UILabel *recordingStatusLabel;
    
    Run *recentRun;
    
    IBOutlet UIBarButtonItem *playlistButton;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    
    
    //Properties for Playlist Player
    
    IBOutlet UITableView *songsTable;
    
    NSMutableArray *songList;
    BOOL playlistFound;
    
    MPMusicPlayerController *myPlayer;
    
    int indexOfCurrentTrack;
    
    IBOutlet UIButton *playPauseButton;
    IBOutlet UIButton *playPauseButton2;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *forwardButton;
    BOOL isPlaying;
    
    IBOutlet MarqueeLabel *currentlyPlayingSong;
    IBOutlet UILabel *currentlyPlayingArtist;
    
    IBOutlet MarqueeLabel *currentlyPlayingSong2;
    IBOutlet UILabel *currentlyPlayingArtist2;
    IBOutlet UIImageView *currentlyPlayingArtwork;
    
    IBOutlet UIView *songInfoView;
}

@property (nonatomic, retain) MKPolyline* polyline;

-(IBAction)beginAndEndButtonPressed:(UIButton*)sender;
-(IBAction)playlistButtonPressed:(UIBarButtonItem*)sender;
-(IBAction)playPauseButtonPressed:(UIButton*)sender;
-(IBAction)backButtonPressed:(UIButton*)sender;
-(IBAction)forwardButtonPressed:(UIButton*)sender;


@end

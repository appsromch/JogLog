//
//  ViewController.m
//  JogLog
//
//  Created by Matthew Ragonese on 10/15/13.
//  Copyright (c) 2013 Matthew Ragonese. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize polyline;

//Synthesize protocol properties
@synthesize coordinate;
@synthesize boundingMapRect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Initialize UI elements, location-tracking, and music player
    [self initializeRunRecordingProperties];
    [self initializeUIElements];
    [self initializeLocationProperties];
    [self initializePlayerProperties];
    [self roundCorners];
    
    self.navigationItem.title = @"JogLog";
}

//Initializes properties pertaining to the recording of Runs
-(void)initializeRunRecordingProperties
{
    routePoints = [[NSMutableArray alloc] init];
    
    recordingRun = NO;
    [beginAndEndButton setTitle:@"GO!" forState:UIControlStateNormal];
    runDistance = 0;
    [runDistanceLabel setText:[NSString stringWithFormat:@"%.2f miles", runDistance]];
    
    beginAndEndButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    beginAndEndButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    currentTime = 0;
    [self populateTimeLabel:runDurationLabel withTimeInterval:currentTime];
    runTimer = nil;
    
    [self populatePaceLabel:runPaceLabel WithDistance:runDistance AndTime:currentTime];
    
    [recordingStatusLabel setText:@"No Run In Progress"];
}

//Initializes constant UI elements
-(void)initializeUIElements
{
    scrollView.pagingEnabled = YES;
    scrollView.scrollEnabled = YES;
    scrollView.delegate = self;
    scrollView.contentSize =  CGSizeMake(scrollView.frame.size.width*2, scrollView.frame.size.height);
    
    //Add shape behind forwardButton, backButton and playButtons (to avoid subclassing UIButton)
    playPauseShapeMP = [[PlayPauseShape alloc] initWithFrame:playPauseButtonMP.frame];
    nextShapePP = [[NextShape alloc] initWithFrame:forwardButtonPP.frame];
    backShapePP = [[BackShape alloc] initWithFrame:backButtonPP.frame];
    playPauseShapePP = [[PlayPauseShape alloc] initWithFrame:playPauseButtonPP.frame];
    [songInfoViewMP addSubview: playPauseShapeMP];
    [songInfoViewPP addSubview:nextShapePP];
    [songInfoViewPP addSubview:backShapePP];
    [songInfoViewPP addSubview:playPauseShapePP];
    [songInfoViewMP bringSubviewToFront:playPauseButtonMP];
    [songInfoViewPP bringSubviewToFront:forwardButtonPP];
    [songInfoViewPP bringSubviewToFront:backButtonPP];
    [songInfoViewPP bringSubviewToFront:playPauseButtonPP];
}

//Initializes location-tracking properties
-(void)initializeLocationProperties
{
    hasInitiallyFoundCurrentLocation = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];
    
    [worldView setShowsUserLocation:YES];
    [worldView setDelegate:self];
    [worldView setUserInteractionEnabled:NO];
    [worldView setMapType:MKMapTypeHybrid];
}

//Initializes the music player and retrieves playlist titled "JogLog" for playback within the app
-(void)initializePlayerProperties
{
    songList = [[NSMutableArray alloc] init];
    
    if(![AD isRunningOnSimulator]) {
        
        myPlayer = [MPMusicPlayerController iPodMusicPlayer];
        
        [myPlayer setShuffleMode:MPMusicShuffleModeSongs];
        [myPlayer setRepeatMode:MPMusicRepeatModeAll];
        
        // Assume we will not find our playlist
        playlistFound = NO;
        
        // Get a collection of all playlists on the device
        MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
        NSArray *playlists = [playlistsQuery collections];
        
        // Check each playlist to see if it is the right one
        for (MPMediaPlaylist *playlist in playlists) {
            NSString *playlistName = [playlist valueForProperty: MPMediaPlaylistPropertyName];
            if ([playlistName isEqualToString:@"JogLog"]) {
                // Add the playlist to the player's queue
                songList = [[playlist items] mutableCopy];
                [myPlayer setQueueWithItemCollection:playlist];
                playlistFound = YES;
                break;
            }
        }
        
        // If no playlist found, play any song
        if (!playlistFound) {
            [myPlayer setQueueWithQuery:[MPMediaQuery songsQuery]];
        }
        
        isPlaying = NO;
        
        // start playing from the beginning of the queue
        if([songList count] > 0)
        {
            indexOfCurrentTrack = arc4random() % [songList count];
            [myPlayer setNowPlayingItem:(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack]];
            [myPlayer play];
            isPlaying = YES;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNowPlayingItemChanged:)
                                                     name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                   object:myPlayer];
        [myPlayer beginGeneratingPlaybackNotifications];
        
        if(isPlaying) {
            [playPauseShapeMP showPauseImage];
            [playPauseShapePP showPauseImage];
        } else {
            [playPauseShapeMP showPlayImage];
            [playPauseShapePP showPlayImage];
        }
        
        MPMediaItem *song;
        MPMediaItemArtwork *itemArtwork;
        if(playlistFound) {
            [currentlyPlayingArtistMP setText:[NSString stringWithFormat:@"By %@", [(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyArtist]]];
            [currentSongLabelMP setText:[(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyTitle]];
            [currentlyPlayingArtistPP setText:[NSString stringWithFormat:@"By %@", [(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyArtist]]];
            [currentlySongLabelPP setText:[(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyTitle]];
            
            song = (MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack];
            itemArtwork = [song valueForProperty:MPMediaItemPropertyArtwork];
        } else {
            [currentlyPlayingArtistMP setText:@"Press Play to Shuffle"];
            [currentSongLabelMP setText:@"Shuffle Mode"];
            [currentlyPlayingArtistPP setText:@"Press Play to Shuffle"];
            [currentlySongLabelPP setText:@"Shuffle Mode"];
        }
        
        UIImage *albumArtworkImage = NULL;
        
        if (itemArtwork != nil) {
            albumArtworkImage = [itemArtwork imageWithSize:CGSizeMake(250.0, 250.0)];
        }
        
        if (albumArtworkImage) {
            [currentlyPlayingArtworkPP setImage:albumArtworkImage];
        } else { // no album artwork
            [currentlyPlayingArtworkPP setImage:[UIImage imageNamed:@"noartwork.png"]];
        }
        
    } else {
        
        [currentlyPlayingArtistMP setText:@"Device Required"];
        [currentSongLabelMP setText:@"Cannot Play on Simulator"];
        [currentlyPlayingArtistPP setText:@"Cannot Play on Simulator"];
        [currentlySongLabelPP setText:@"Device Required"];
    }

    currentSongLabelMP.numberOfLines = 1;
    currentSongLabelMP.shadowOffset = CGSizeMake(0.0, -1.0);
    currentSongLabelMP.textAlignment = NSTextAlignmentCenter;
    currentSongLabelMP.textColor = [UIColor whiteColor];
    currentSongLabelMP.backgroundColor = [UIColor clearColor];
    currentSongLabelMP.marqueeType = MLContinuous;
    currentSongLabelMP.fadeLength = 7;
    
    currentlySongLabelPP.numberOfLines = 1;
    currentlySongLabelPP.shadowOffset = CGSizeMake(0.0, -1.0);
    currentlySongLabelPP.textAlignment = NSTextAlignmentCenter;
    currentlySongLabelPP.textColor = [UIColor whiteColor];
    currentlySongLabelPP.backgroundColor = [UIColor clearColor];
    currentlySongLabelPP.marqueeType = MLContinuous;
    currentlySongLabelPP.fadeLength = 7;
    
    [songsTable setBackgroundColor:[UIColor colorWithRed:0.239 green:0.447 blue:0.643 alpha:1.0]];
}


//*** UITableView Delegation/Datasource Methods ***//

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([songList count] == 0) {
        return 2;
    } else {
        return [songList count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *noResults;
    CustomCell *cell;
    
    UIColor *backgroundColor = [UIColor colorWithRed:0.239 green:0.447 blue:0.643 alpha:1.0];
    
    if([songList count] == 0) {
        
        noResults = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"No Songs%d", indexPath.row]];
        if(noResults == nil) {
            noResults = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"No Songs%d", indexPath.row]];
        }
        [[noResults textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:13.0]];
        [[noResults textLabel] setTextColor:[UIColor whiteColor]];
        [[noResults textLabel] setTextAlignment:NSTextAlignmentCenter];
        [[noResults textLabel] setNumberOfLines:2];
        if(indexPath.row == 0) {
            [[noResults textLabel] setText:@"Create an iTunes playlist with the title \"JogLog\""];
        } else {
            [[noResults textLabel] setText:@"In the meantime, press play to shuffle library"];
        }
        [noResults setBackgroundColor:backgroundColor];
        noResults.selectionStyle = UITableViewCellSelectionStyleNone;
        noResults.userInteractionEnabled = NO;
        return noResults;
    }
    
    
    cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%d", indexPath.row]];
    
    if(!cell) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"cell%d", indexPath.row]];
    }
    
    [cell setBackgroundColor:backgroundColor];
    
    MPMediaItem *song = [songList objectAtIndex:indexPath.row];
    
    [[cell textLabel] setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:16]];
    [[cell textLabel] setTextColor:[UIColor whiteColor]];
    [[cell textLabel] setText:[song valueForProperty:MPMediaItemPropertyTitle]];
    
    [[cell detailTextLabel] setFont:[UIFont fontWithName:@"TrebuchetMS" size:12]];
    [[cell detailTextLabel] setTextColor:[UIColor lightGrayColor]];
    [[cell detailTextLabel] setText:[song valueForProperty:MPMediaItemPropertyArtist]];
    
    if(indexOfCurrentTrack == indexPath.row) {
        UIImageView *currentlyPlaying = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"120-headphones.png"]];
        [cell setAccessoryView:currentlyPlaying];
    } else {
        [cell setAccessoryView:nil];
    }
    
    UIImage *albumArtworkImage = NULL;
    MPMediaItemArtwork *itemArtwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    if (itemArtwork != nil) {
        albumArtworkImage = [itemArtwork imageWithSize:CGSizeMake(250.0, 250.0)];
    }
    
    if (albumArtworkImage) {
        [[cell imageView] setImage:albumArtworkImage];
    } else { // no album artwork
        [[cell imageView] setImage:[UIImage imageNamed:@"noartwork.png"]];
    }
    [[cell imageView] setBackgroundColor:[UIColor lightGrayColor]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(!(indexPath.row == indexOfCurrentTrack)) {
        indexOfCurrentTrack = indexPath.row;
        [self stopCurrentTrackAndPlaySelection];
    }
}


//*** Button Action Methods (Playback Control) ***//

-(IBAction)backButtonPressed:(UIButton*)sender
{
    if(playlistFound) {
        [self previousTrack];
    } else {
        if([myPlayer currentPlaybackTime] < 2.0) {
            [myPlayer skipToPreviousItem];
        } else {
            [myPlayer skipToBeginning];
        }
    }
}

-(IBAction)forwardButtonPressed:(UIButton*)sender
{
    if(playlistFound) {
        [self nextTrack];
    } else {
        [myPlayer skipToNextItem];
    }
}

-(IBAction)playPauseButtonPressed:(UIButton *)sender
{
    isPlaying = !isPlaying;
    [self updatePlayPauseButtons];
    if(isPlaying) {
        [myPlayer play];
    } else {
        [myPlayer pause];
    }
}

-(void)nextTrack
{
    indexOfCurrentTrack ++;
    if(indexOfCurrentTrack == [songList count])
        indexOfCurrentTrack = 0;
    [self stopCurrentTrackAndPlaySelection];
}

-(void)previousTrack
{
    indexOfCurrentTrack --;
    if(indexOfCurrentTrack == -1)
        indexOfCurrentTrack = [songList count] -1;
    [self stopCurrentTrackAndPlaySelection];
}

//AudioPlayer Switched Tracks
-(void)handleNowPlayingItemChanged:(NSNotification *)notification
{
    //reassign indexOfCurrentTrack
    for(int i = 0; i < [songList count]; i++)
    {
        if([[[myPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyTitle] isEqualToString:[(MPMediaItem *)[songList objectAtIndex:i] valueForProperty:MPMediaItemPropertyTitle]])
        {
            indexOfCurrentTrack = i;
        }
    }
    
    [songsTable reloadData];
    [self updatePlayPauseButtons];
    
    MPMediaItem *song;
    MPMediaItemArtwork *itemArtwork;
    if(playlistFound) {
        [currentlyPlayingArtistMP setText:[NSString stringWithFormat:@"By %@", [(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyArtist]]];
        [currentSongLabelMP setText:[(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyTitle]];
        [currentlyPlayingArtistPP setText:[NSString stringWithFormat:@"By %@", [(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyArtist]]];
        [currentlySongLabelPP setText:[(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyTitle]];
        song = (MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack];
        itemArtwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    } else {
        [currentlyPlayingArtistMP setText:@"Press Play to Shuffle"];
        [currentSongLabelMP setText:@"Shuffle Mode"];
        [currentlyPlayingArtistPP setText:@"Press Play to Shuffle"];
        [currentlySongLabelPP setText:@"Shuffle Mode"];

    }
    
    UIImage *albumArtworkImage = NULL;
    
    if (itemArtwork != nil) {
        albumArtworkImage = [itemArtwork imageWithSize:CGSizeMake(250.0, 250.0)];
    }
    
    if (albumArtworkImage) {
        [currentlyPlayingArtworkPP setImage:albumArtworkImage];
    } else { // no album artwork
        [currentlyPlayingArtworkPP setImage:[UIImage imageNamed:@"noartwork.png"]];
    }
}

-(void)updatePlayPauseButtons
{
    if(isPlaying) {
        [playPauseShapeMP showPauseImage];
        [playPauseShapePP showPauseImage];
    } else {
        [playPauseShapeMP showPlayImage];
        [playPauseShapePP showPlayImage];
    }
}

- (void)stopCurrentTrackAndPlaySelection
{
    [myPlayer stop];
    [myPlayer setNowPlayingItem:(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack]];
    [myPlayer play];
    isPlaying = YES;
}


//*** LocationManager/MapKit Delegation Methods ***/

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation;
    CLLocation *oldLocation;
    newLocation = [locations lastObject];
    oldLocation = [locations objectAtIndex:locations.count-1];
    
    //Zooms mapview at initial location
    if(!hasInitiallyFoundCurrentLocation) {
        
        CLLocationCoordinate2D loc = [newLocation coordinate];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 1500, 1500);
        [worldView setRegion:region animated:YES];
        
        hasInitiallyFoundCurrentLocation = YES;
    }
    
    
    if(recordingRun) {
        
        [routePoints addObject:newLocation];
        
        int numPoints = [routePoints count];
        
        if(numPoints > 1) {
            
            CLLocationDistance meters = [[routePoints objectAtIndex:numPoints-1] distanceFromLocation:[routePoints objectAtIndex:numPoints-2]];
            float miles = meters * 0.000621371;
            runDistance += miles;
            
            [runDistanceLabel setText:[NSString stringWithFormat:@"%.2f miles", runDistance]];
            [self populatePaceLabel:runPaceLabel WithDistance:runDistance AndTime:currentTime];
        }
        
        if (numPoints > 1)
        {
            CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
            for (int i = 0; i < numPoints; i++)
            {
                CLLocation *current = [routePoints objectAtIndex:i];
                coords[i] = current.coordinate;
            }
            
            self.polyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
            free(coords);
            
            [worldView addOverlay:self.polyline];
            [worldView setNeedsDisplay];
        }
    } else {
        
        //Don't worry about it
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView* lineView = [[MKPolylineView alloc] initWithPolyline:self.polyline];
    lineView.fillColor = [UIColor redColor];
    lineView.strokeColor = [UIColor blueColor];
    [lineView setAlpha:0.7];
    lineView.lineCap = kCGLineCapRound;
    lineView.lineWidth = 5;
    return lineView;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(!worldView.userLocationVisible) {
        CLLocationCoordinate2D loc = [userLocation coordinate];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 1500, 1500);
        [worldView setRegion:region animated:YES];
    }
}


//*** PageControl Methods ***//

//Changes current page of pageControl if user swipes sideways
- (void)scrollViewDidScroll:(UIScrollView *)theScrollView {
    
    CGFloat pageWidth = scrollView.bounds.size.width;
    NSInteger pageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = pageNumber;
    
    [songsTable flashScrollIndicators];
}

//UIPageControll method for side swiping
- (IBAction)changePage:(id)sender {
    UIPageControl *pager = sender;
    int currentPage = pager.currentPage;
    CGRect visibleRect = CGRectMake(currentPage*scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    [scrollView scrollRectToVisible:visibleRect animated:YES];
}


//*** Run Recording Methods ***//

//Begins and ends the recording of a Run
-(IBAction)beginAndEndButtonPressed:(UIButton*)sender
{
    recordingRun = !recordingRun;
    
    if(recordingRun) {
        
        [recordingStatusLabel setText:@"Run is recording"];
        
        [beginAndEndButton setTitle:@"STOP RUN" forState:UIControlStateNormal];
        
        runTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
        
    } else {
        
        [recordingStatusLabel setText:@"No Run In Progress"];
        
        //Log the Run object
        recentRun = [[Run alloc] initWithTotalTime:currentTime TotalDistance:runDistance];
        
        NSString *message = [NSString stringWithFormat:@"You just completed a %@ run in %@ with a pace of %@. Would you like to receive these stats in an email?", [recentRun totalDistanceString], [recentRun totalTimeString], [recentRun averagePaceString]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:message delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"OK", nil];
        [alert show];
        
        [beginAndEndButton setTitle:@"GO!" forState:UIControlStateNormal];
        
        [runTimer invalidate];
    }
}

-(void)updateTimer:(NSTimer *)timer
{
    currentTime += 1;
    [self populateTimeLabel:runDurationLabel withTimeInterval:currentTime];
}

-(void)populateTimeLabel:(UILabel *)label withTimeInterval:(NSTimeInterval)timeInterval
{
    uint seconds = fabs(timeInterval);
    uint minutes = seconds / 60;
    uint hours = minutes / 60;
    seconds -= minutes * 60;
    minutes -= hours * 60;
    
    [label setText:[NSString stringWithFormat:@"%@%02u:%02u:%02u", (timeInterval<0?@"-":@""), hours, minutes, seconds]];
}

-(void)populatePaceLabel:(UILabel*)label WithDistance:(float)distance AndTime:(NSTimeInterval)timeInterval
{
    if(timeInterval == 0 || distance == 0) {
        
        [label setText:@"0.00 mins/mile"];
        
    } else {
        
        float seconds = fabs(timeInterval);
        float minutes = seconds/60.0;
        float pace = minutes/distance;
        
        [label setText:[NSString stringWithFormat:@"%.2f mins/mile", pace]];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Could not find location: %@", error);
}


//*** AlertView Delegaton Method (For End Of Run) ***//

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        
        //User decided to send jogging stats in an email
        NSString *message = [NSString stringWithFormat:@"You just completed a %@ run in %@ (h:m:s) with a pace of %@! Thanks for using \"JogLog!\"", [recentRun totalDistanceString], [recentRun totalTimeString], [recentRun averagePaceString]];
        NSString *todayString = [self monthAndDayAndYearFromDate:[NSDate date]];
        NSString *subject = [NSString stringWithFormat:@"Your run on %@", todayString];
        [self sendStatsInEmailWithSubject:subject AndMessage:message];
    }
    
    //Clear the UI of all run info
    [routePoints removeAllObjects];
    [worldView removeOverlays:worldView.overlays];
    
    runDistance = 0;
    [runDistanceLabel setText:[NSString stringWithFormat:@"%.2f miles", runDistance]];
    
    currentTime = 0;
    
    [self populateTimeLabel:runDurationLabel withTimeInterval:0];
    [self populatePaceLabel:runPaceLabel WithDistance:runDistance AndTime:currentTime];
}


//*** Email Composition Methods ***//

-(void)sendStatsInEmailWithSubject:(NSString*)subject AndMessage:(NSString*)message
{
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:subject];
    [controller setMessageBody:message isHTML:NO];
    if (controller) {
        [self presentViewController:controller animated:YES completion:^{}];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"Email Sent!");
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}


//Utility Methods

-(NSString*)monthAndDayAndYearFromDate:(NSDate*)date
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *components = [cal components:units fromDate:date];
    NSInteger startYear = [components year];
    NSInteger startMonth = [components month];
    NSInteger startDay = [components day];
    
    return [NSString stringWithFormat:@"%d/%d/%d", startMonth, startDay, startYear];
}

-(void)roundCorners
{
    runDistanceLabel.layer.cornerRadius = 7;
    runDistanceLabel.layer.masksToBounds = YES;
    
    runPaceLabel.layer.cornerRadius = 7;
    runPaceLabel.layer.masksToBounds = YES;
    
    runDurationLabel.layer.cornerRadius = 7;
    runDurationLabel.layer.masksToBounds = YES;
    
    recordingStatusLabel.layer.cornerRadius = 7;
    recordingStatusLabel.layer.masksToBounds = YES;
    
    beginAndEndButton.layer.cornerRadius = 7;
    beginAndEndButton.layer.masksToBounds = YES;
    beginAndEndButton.layer.borderWidth = 2;
    beginAndEndButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    songInfoViewPP.layer.cornerRadius = 10;
    songInfoViewPP.layer.masksToBounds = YES;
}

-(void)dealloc
{
    [locationManager setDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

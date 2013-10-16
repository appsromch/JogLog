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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self initializeRunningAndUIProperties];
    
    [self initializeLocationProperties];
    
    [self initializePlayerProperties];
    
    [self roundCorners];
    
    self.navigationItem.title = @"JogLog";
}

- (void)scrollViewDidScroll:(UIScrollView *)theScrollView {
    
    CGFloat pageWidth = scrollView.bounds.size.width;
    NSInteger pageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = pageNumber;
    
    [songsTable flashScrollIndicators];
}

- (IBAction)changePage:(id)sender {
    UIPageControl *pager = sender;
    int currentPage = pager.currentPage;
    CGRect visibleRect = CGRectMake(currentPage*scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    [scrollView scrollRectToVisible:visibleRect animated:YES];
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
    
    songInfoView.layer.cornerRadius = 10;
    songInfoView.layer.masksToBounds = YES;
}

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
            //[playPauseButton setImage:[UIImage imageNamed:@"player_pause.png"] forState:UIControlStateNormal];
            [playPauseShape showPauseImage];
            //[playPauseButton2 setImage:[UIImage imageNamed:@"player_pause.png"] forState:UIControlStateNormal];
            [playPauseShape2 showPauseImage];
        } else {
            //[playPauseButton setImage:[UIImage imageNamed:@"player_play.png"] forState:UIControlStateNormal];
            [playPauseShape showPlayImage];
            //[playPauseButton2 setImage:[UIImage imageNamed:@"player_play.png"] forState:UIControlStateNormal];
            [playPauseShape2 showPlayImage];
        }
        
        MPMediaItem *song;
        MPMediaItemArtwork *itemArtwork;
        if(playlistFound) {
            [currentlyPlayingArtist setText:[NSString stringWithFormat:@"By %@", [(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyArtist]]];
            [currentlyPlayingSong setText:[(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyTitle]];
            //DUPLICATE
            [currentlyPlayingArtist2 setText:[NSString stringWithFormat:@"By %@", [(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyArtist]]];
            [currentlyPlayingSong2 setText:[(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyTitle]];
            
            song = (MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack];
            itemArtwork = [song valueForProperty:MPMediaItemPropertyArtwork];
        } else {
            [currentlyPlayingArtist setText:@"Press Play to Shuffle"];
            [currentlyPlayingSong setText:@"Shuffle Mode"];
            //DUPLICATE
            [currentlyPlayingArtist2 setText:@"Press Play to Shuffle"];
            [currentlyPlayingSong2 setText:@"Shuffle Mode"];
        }
        
        UIImage *albumArtworkImage = NULL;
        
        if (itemArtwork != nil) {
            albumArtworkImage = [itemArtwork imageWithSize:CGSizeMake(250.0, 250.0)];
        }
        
        if (albumArtworkImage) {
            [currentlyPlayingArtwork setImage:albumArtworkImage];
        } else { // no album artwork
            [currentlyPlayingArtwork setImage:[UIImage imageNamed:@"noartwork.png"]];
        }
        
    } else {
        
        [currentlyPlayingArtist setText:@"Device Required"];
        [currentlyPlayingSong setText:@"Cannot Play on Simulator"];
        //DUPLICATE
        [currentlyPlayingArtist2 setText:@"Cannot Play on Simulator"];
        [currentlyPlayingSong2 setText:@"Device Required"];
    }

    currentlyPlayingSong.numberOfLines = 1;
    currentlyPlayingSong.shadowOffset = CGSizeMake(0.0, -1.0);
    currentlyPlayingSong.textAlignment = NSTextAlignmentCenter;
    currentlyPlayingSong.textColor = [UIColor whiteColor];
    currentlyPlayingSong.backgroundColor = [UIColor clearColor];
    currentlyPlayingSong.marqueeType = MLContinuous;
    currentlyPlayingSong.fadeLength = 7;
    
    currentlyPlayingSong2.numberOfLines = 1;
    currentlyPlayingSong2.shadowOffset = CGSizeMake(0.0, -1.0);
    currentlyPlayingSong2.textAlignment = NSTextAlignmentCenter;
    currentlyPlayingSong2.textColor = [UIColor whiteColor];
    currentlyPlayingSong2.backgroundColor = [UIColor clearColor];
    currentlyPlayingSong2.marqueeType = MLContinuous;
    currentlyPlayingSong2.fadeLength = 7;
    
    [songsTable setBackgroundColor:[UIColor colorWithRed:0.239 green:0.447 blue:0.643 alpha:1.0]];
}

-(void)initializeRunningAndUIProperties
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
    
    scrollView.pagingEnabled = YES;
    scrollView.scrollEnabled = YES;
    scrollView.delegate = self;
    scrollView.contentSize =  CGSizeMake(scrollView.frame.size.width*2, scrollView.frame.size.height);
    
    //Add shape behind forwardButton, backButton and playButtons (to avoid subclassing UIButton)
    playPauseShape = [[PlayPauseShape alloc] initWithFrame:playPauseButton.frame];
    nextShape = [[NextShape alloc] initWithFrame:forwardButton.frame];
    backShape = [[BackShape alloc] initWithFrame:backButton.frame];
    playPauseShape2 = [[PlayPauseShape alloc] initWithFrame:playPauseButton2.frame];
    [transparentSongInfoView addSubview: playPauseShape];
    [songInfoView addSubview:nextShape];
    [songInfoView addSubview:backShape];
    [songInfoView addSubview:playPauseShape2];
    [transparentSongInfoView bringSubviewToFront:playPauseButton];
    [songInfoView bringSubviewToFront:forwardButton];
    [songInfoView bringSubviewToFront:backButton];
    [songInfoView bringSubviewToFront:playPauseButton2];
    
    
}

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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    
    /*UIImage *songArtwork = [song valueForProperty:MPMediaItemPropertyArtwork];
     songArtwork = [songArtwork resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
     [[cell imageView] setImage:songArtwork];*/
    //[[cell imageView] setImage:[song valueForProperty:MPMediaItemPropertyArtwork]];
    
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

-(void)handleNowPlayingItemChanged:(NSNotification *)notification
{
    //Playing item has changed (or just begun)
    
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
        [currentlyPlayingArtist setText:[NSString stringWithFormat:@"By %@", [(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyArtist]]];
        [currentlyPlayingSong setText:[(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyTitle]];
        //DUPLICATE
        [currentlyPlayingArtist2 setText:[NSString stringWithFormat:@"By %@", [(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyArtist]]];
        [currentlyPlayingSong2 setText:[(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack] valueForProperty:MPMediaItemPropertyTitle]];
        song = (MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack];
        itemArtwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    } else {
        [currentlyPlayingArtist setText:@"Press Play to Shuffle"];
        [currentlyPlayingSong setText:@"Shuffle Mode"];
        //DUPLICATE
        [currentlyPlayingArtist2 setText:@"Press Play to Shuffle"];
        [currentlyPlayingSong2 setText:@"Shuffle Mode"];

    }
    
    UIImage *albumArtworkImage = NULL;
    
    if (itemArtwork != nil) {
        albumArtworkImage = [itemArtwork imageWithSize:CGSizeMake(250.0, 250.0)];
    }
    
    if (albumArtworkImage) {
        [currentlyPlayingArtwork setImage:albumArtworkImage];
    } else { // no album artwork
        [currentlyPlayingArtwork setImage:[UIImage imageNamed:@"noartwork.png"]];
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

-(void)updatePlayPauseButtons
{
    if(isPlaying) {
        [playPauseShape showPauseImage];
        [playPauseShape2 showPauseImage];
    } else {
        [playPauseShape showPlayImage];
        [playPauseShape2 showPlayImage];
    }
}

- (void)stopCurrentTrackAndPlaySelection
{
    [myPlayer stop];
    [myPlayer setNowPlayingItem:(MPMediaItem *)[songList objectAtIndex:indexOfCurrentTrack]];
    [myPlayer play];
    isPlaying = YES;
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
            
            //NSLog(@"Meters = %f, RunDistance = %f", meters, runDistance);
            
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
        
        //self.polyline = [MKPolyline polylineWithCoordinates:nil count:0];
        //[worldView addOverlay:self.polyline];
        //[worldView setNeedsDisplay];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView* lineView = [[MKPolylineView alloc] initWithPolyline:self.polyline];
    lineView.fillColor = [UIColor redColor];
    lineView.strokeColor = [UIColor blueColor];
    [lineView setAlpha:0.6];
    lineView.lineCap = kCGLineCapRound;
    lineView.lineWidth = 4;
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

-(IBAction)playlistButtonPressed:(UIBarButtonItem*)sender
{
    NSLog(@"PlaylistButtonPressed");
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Could not find location: %@", error);
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        
        NSLog(@"Correct Alertview Method");
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

//
//  ListViewController.m
//  KinveySample
//
//  Created by Scott Carter on 11/19/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#import "ListViewController.h"

#import "Project.h"

// Make Swift methods, protocols, variables marked with @objc available here.
#import <KinveySample-Swift.h>

#import "SVProgressHUD.h"

#import "Movie.h"

#import <KinveyKit/KinveyKit.h>


/*
 Description:
 
 
 */

// FIXME: None
// TODO: None
#pragma mark -


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Private Interface
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
@interface ListViewController () <MovieViewControllerDelegate>

// ==========================================================================
// Properties
// ==========================================================================
//
#pragma mark -
#pragma mark Properties

@property (strong, nonatomic) NSMutableArray *movieArr;  // Table reads this array for thumbnails, timestamps

@property (strong, nonatomic) KCSLinkedAppdataStore* updateStore;  // Objects at Kinvey

@end



// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Implementation
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
#pragma mark -
@implementation ListViewController

// ==========================================================================
// Constants and Defines
// ==========================================================================
//
#pragma mark -
#pragma mark Constants and Defines

const CGFloat thumbnailDimension = 100.0;  // Table height for thumbnails.


// ==========================================================================
// Instance variables.  Could also be in interface section.
// ==========================================================================
//
#pragma mark -
#pragma mark Instance variables

// None


// ==========================================================================
// Synthesize public properties
// ==========================================================================
//
#pragma mark -
#pragma mark Synthesize public properties

// None


// ==========================================================================
// Synthesize private properties
// ==========================================================================
//
#pragma mark -
#pragma mark Synthesize private properties

// None


// ==========================================================================
// Getters and Setters
// ==========================================================================
//
#pragma mark -
#pragma mark Getters and Setters

- (NSArray *)movieArr
{
    if(!_movieArr){
        _movieArr = [[NSMutableArray alloc] init];
    }
    
    return _movieArr;
}


// ==========================================================================
// Actions
// ==========================================================================
//
#pragma mark -
#pragma mark Actions


- (void)cameraAction
{
    [self performSegueWithIdentifier:@"createSegue" sender:self];
}


- (void)logoutAction
{
    // Empty our array
    self.movieArr = [[NSMutableArray alloc] init];
    
    
    [[KCSUser activeUser] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}




// ==========================================================================
// Initializations
// ==========================================================================
//
#pragma mark -
#pragma mark Initializations



// We re-use the same MovieViewController for both viewing a movie (saved at Kinvey) as well as selecting/taking
// a new one to save.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"createSegue"]){
        
        MovieViewController *movieViewController = (MovieViewController *)segue.destinationViewController;
        movieViewController.delegate = self;
        movieViewController.createMode = YES;
    }
    else if([[segue identifier] isEqualToString:@"viewSegue"]){
        
        MovieViewController *movieViewController = (MovieViewController *)segue.destinationViewController;
        movieViewController.delegate = self;
        movieViewController.createMode = NO;
        
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        
        // Give the MovieViewController the id of the selected movie.  It will
        // use a delegate call to cause the movie to be fetched from Kinvey.
        NSDictionary *entry = self.movieArr[indexPath.row];
        movieViewController.movieId = (NSNumber *)entry[@"timestamp"];
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Cleanup the tmp directory on each launch.
    //
    // Reference:
    // http://stackoverflow.com/questions/9196443/how-to-remove-tmp-directory-files-of-an-ios-app
    //
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
    
    
    // Clear out the cache on launch.
    [KCSFileStore clearCachedFiles];
    
    KCSCollection* collection = [KCSCollection collectionFromString:@"Movie" ofClass:[Movie class]];

    [KCSCachedStore setDefaultCachePolicy:KCSCachePolicyNone];
    
    self.updateStore = [KCSLinkedAppdataStore storeWithCollection:collection options:nil];
    
    
    // Put up the compose and logout buttons
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(cameraAction)];
    
    
    UIBarButtonItem* logoutButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Logout", @"Logout button") style:UIBarButtonItemStylePlain target:self action:@selector(logoutAction)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    
    // Query for existing records.
    [self updateList];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}




// ==========================================================================
// Protocol methods
// ==========================================================================
//
#pragma mark -
#pragma mark Protocol methods


#pragma mark MovieViewControllerDelegate

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


// After MP4 export and thumbnail generation, the MovieViewController will call this delegate method
// to save to Kinvey.
//
- (void)save:(NSURL *)assetURL
   thumbnail:(UIImage *)image
{
    
    
    // Get a timestamp to id the asset
    NSInteger timestamp = (NSInteger)[[NSDate date] timeIntervalSince1970]; // Unix epoch

    // Reduce the image dimensions and make it square.
    UIImage *squareImage = [self imageWithImage:image maxWidth:thumbnailDimension maxHeight:thumbnailDimension squareImage:YES compensateForRetina:NO];
    
    
    NSDictionary *entry = @{@"image":squareImage, @"timestamp":[NSNumber numberWithInteger:timestamp]};
    
    
    // Add entry to front of the array
    [self.movieArr insertObject:entry atIndex:0]; // For table display
    

    
    // Save movie to Kinvey in the Files collection
    KCSMetadata* metadata = [[KCSMetadata alloc] init]; // By default only user has access
    [metadata setGloballyReadable:YES];
    
    // Derive filename and id from timestamp
    NSString *fileName = [NSString stringWithFormat:@"%ld.mp4",(long)timestamp];
    NSString *fileId = [NSString stringWithFormat:@"%ld",(long)timestamp];
    
    
    [KCSFileStore uploadFile:assetURL options:@{KCSFileFileName : fileName,
                                                KCSFileId: fileId,
                                                KCSFileMimeType : @"video/mp4",
                                                KCSFilePublic: @(NO),
                                                KCSFileACL : metadata}
             completionBlock:^(KCSFile *uploadInfo, NSError *error) {
                 NSLog(@"Upload finished. File id='%@', error='%@'.", [uploadInfo fileId], error);
                 
                 // Completion block not called on main queue, so dispatch.
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self saveMovieForId:fileId timestampNum:[NSNumber numberWithInteger:timestamp] image:squareImage];
                 });
                 
                 
             } progressBlock:nil];
    
}


// Save movie information to Movie collection
//
// Helper to save:thumbnail:
- (void)saveMovieForId:(NSString *)entityId
          timestampNum:(NSNumber *)timestampNum
                 image:(UIImage *)image
{
    
    
    KCSMetadata* metadata = [[KCSMetadata alloc] init]; // By default only user has access
    [metadata setGloballyReadable:YES];
    
    Movie* movie = [[Movie alloc] init];
    movie.entityId = entityId; // Same id as movie stored to Files collection
    movie.timestamp = timestampNum;
    movie.metadata = metadata;
    movie.image = image;
    
    
    
    [self.updateStore saveObject:movie withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (errorOrNil != nil) {
            
            
            //save failed, show an error alert
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Save failed", @"Save Failed")
                                                                message:[errorOrNil localizedFailureReason] //not actually localized
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
            [alertView show];
            
            // Dismiss our MovieViewController
            [self dismissViewControllerAnimated:YES completion:^{
                ;
            }];
            
            
        } else {
            //save was successful
            NSLog(@"Successfully saved movie (id='%@').", [objectsOrNil[0] kinveyObjectId]);
            
            
            // Dismiss our MovieViewController and update table.
            [self dismissViewControllerAnimated:YES completion:^{
                
                [self.tableView reloadData];
                
                // https://github.com/TransitApp/SVProgressHUD
                [SVProgressHUD showSuccessWithStatus:@"Saved to Kinvey!"];
                
            }];
            
        }
    } withProgressBlock:nil];

}


// Fetch a movie from Kinvey using the movieId.  Called by MovieViewController.
- (void)urlToView:(NSNumber *)movieId completion:(void (^)(NSURL *))completion
{
    
    NSInteger timestamp = [movieId integerValue];
    NSString *fileId = [NSString stringWithFormat:@"%ld",(long)timestamp];
    
    [KCSFileStore downloadFile:fileId options:nil completionBlock:^(NSArray *downloadedResources, NSError *error) {
        if (error == nil) {
            KCSFile* file = downloadedResources[0];
            NSURL* fileURL = file.localURL;
            
            // Provide MovieViewController with NSURL for asset.
            completion(fileURL);
            
        } else {
            NSLog(@"Got an error: %@", error);
        }
    } progressBlock:nil];
    
    
}



#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.movieArr count];
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     
     static NSString *cellIdentifier = @"Cell";
 
     // self.cellIdentifier will reference cellIdentifier property in derived class
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
     
     // Using UITableViewCellStyleSubtitle as default.
     if (cell == nil) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
     }

     
     
     NSDictionary *entry = self.movieArr[indexPath.row];
     
     UIImage *cellImage = entry[@"image"];
     cell.imageView.image = cellImage;
     
     
     NSTimeInterval timestamp = (NSTimeInterval)[entry[@"timestamp"] integerValue];
     
     NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
     
     NSTimeInterval since = currentTimestamp - timestamp;
     
     // Borrowed code from Kinvey StatusShare example.
     NSString* dateFormat = @"";
     if (since < 60) {
         dateFormat = @"now";
     } else if (since < 60 * 60) {
         dateFormat = [NSString stringWithFormat:@"%0.fm", since / 60];
     } else if ( since < 60 * 60 * 24) {
         dateFormat = [NSString stringWithFormat:@"%0.fh", since / (60 * 60)];
     } else {
         double days = since / (60 * 60 * 24);
         dateFormat = [NSString stringWithFormat:@"%0.fd", days];
     }
     cell.textLabel.text = dateFormat;
     
     
    
     return cell;
 }


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return thumbnailDimension;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"viewSegue" sender:tableView];
}


// ==========================================================================
// Class methods
// ==========================================================================
//
#pragma mark -
#pragma mark Class methods

// None


// ==========================================================================
// Instance methods
// ==========================================================================
//
#pragma mark -
#pragma mark Instance methods



# pragma mark Image related


// Helper method for imageWithImage:maxWidth:maxHeight:compensateForRetina:
//
//
// References:
//
// Resize UIImage by keeping Aspect ratio and width  (answer by Ryan)
// http://stackoverflow.com/questions/7645454/resize-uiimage-by-keeping-aspect-ratio-and-width
//
//
// Note:
// contentScaleFactor of UIImageView is always 1.0
// Using a custom view inside a view controller also reports a contentScaleFactor of 1.0 unless you
// also implement drawRect: in which case it reports 2.0 for a retina display.
//
// This is apparently consistent with the documentation on contentScaleFactor which includes:
//
// "For views that implement a custom drawRect: method and are associated with a window,
// the default value for this property is the scale factor associated with the screen currently
// displaying the view. For system views and views that are backed by a CAEAGLLayer object for,
// the value of this property may be 1.0 even on high resolution screens."
//
- (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)size
                       rect:(CGRect)rect
        compensateForRetina:(BOOL)compensateForRetina
{
    
    // NLOG("size width=%f height=%f   rect x=%f y=%f width=%f height=%f",size.width, size.height, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
    
    // If we have a retina display, we want a more detailed resolution.
    //
    // Note:
    // The resulting UIImage will have the same size regardless of the scale (newImage.size.width/height) since
    // it is measuring points. In order to show that the image is at a higher resolution, you can examine newImage.scale
    //
    if(compensateForRetina){
        CGFloat scale = [[UIScreen mainScreen] scale];
        UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    }
    
    // Use default scale for UIGraphicsBeginImageContext which is 1.0
    else {
        UIGraphicsBeginImageContext(size);
    }
    
    [image drawInRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // NLOG("image width=%f height=%f  orientation=%d   newImage width=%f height=%f orientation=%d",image.size.width, image.size.height, image.imageOrientation, newImage.size.width, newImage.size.height, newImage.imageOrientation)
    
    return newImage;
}


// If squareImage is NO:
// We look for the greater image dimension (width or height).  We then create a scaleFactor
// by dividing corresponding maxWidth or maxHeight by this dimension.  The goal is to keep the
// aspect ratio and fit longest side into its corresponding max[Width|Height].
//
// If squareImage is YES:
// We look for greatest ratio of max[Width|Height] to image dimension (width or height).  We then
// scale image by that ratio.  If the greatest ratio is with height, then we create a rect where
// the full height is shown and the width has a negative offset so that a portion of width is truncated
// equally.  Vice versa if greatest ratio is with width.
//
- (UIImage *)imageWithImage:(UIImage *)image
                   maxWidth:(CGFloat)maxWidth
                  maxHeight:(CGFloat)maxHeight
                squareImage:(BOOL)squareImage
        compensateForRetina:(BOOL)compensateForRetina
{
    CGFloat origWidth = image.size.width;
    CGFloat origHeight = image.size.height;
    
    double scaleFactor;
    CGFloat newWidth;
    CGFloat newHeight;
    CGRect rect;
    CGSize newSize;
    
    // For a square image, either newWidth or newHeight will exactly equal corresponding
    // maxWidth or maxHeight and the other dimension will be truncated evenly on both sides.
    // That is, the rect which we draw into will contain a negative offset for truncated dimension which puts
    // that dimension centered in newSize dimensions.  It is newSize which we will fit into
    // and determine our ultimate image dimensions after processing.
    //
    // Reference:
    // http://stackoverflow.com/questions/17884555/square-thumbnail-from-uiimagepickerviewcontroller-image
    //
    if(squareImage){
        scaleFactor = MAX(maxWidth/origWidth, maxHeight/origHeight);
        
        // Not as important to round here since it is our newSize (which uses whole numbers) and
        // not rect that determines eventual image dimensions after call to
        // UIGraphicsGetImageFromCurrentImageContext(). Compare to non-square case.
        newWidth = roundf(origWidth * scaleFactor);
        newHeight = roundf(origHeight * scaleFactor);
        
        rect = CGRectMake((maxWidth - newWidth)/2.0f,    // Either x or y will be 0, possibly both.
                          (maxHeight - newHeight)/2.0f,
                          newWidth,
                          newHeight);
        newSize = CGSizeMake(maxWidth, maxHeight);
    }
    
    // For a non-square image, we maintain aspect ratio and fit entire original image
    // into scaled image as we shrink.
    else {
        scaleFactor = (origWidth > origHeight) ? maxWidth / origWidth : maxHeight / origHeight;
        
        // We need to round to nearest whole value.  Otherwise a value here such as 240.000015
        // gets promoted up to 240.500000 after our call to UIGraphicsGetImageFromCurrentImageContext()
        // and eventually interpreted as 241 when a JPEG image is written to disk.
        newWidth = roundf(origWidth * scaleFactor);
        newHeight = roundf(origHeight * scaleFactor);
        
        rect = CGRectMake(0, 0, newWidth, newHeight);
        newSize = CGSizeMake(newWidth, newHeight);
    }
    
    
    
    return [self imageWithImage:image scaledToSize:newSize rect:rect compensateForRetina:compensateForRetina];
    
}


// Perform query to Kinvey to update our table contents.
- (void) updateList
{
    KCSQuery* query = [KCSQuery query];
    KCSQuerySortModifier* sortByTimestamp = [[KCSQuerySortModifier alloc] initWithField:@"timestamp" inDirection:kKCSDescending];
    [query addSortModifier:sortByTimestamp];
    [query setLimitModifer:[[KCSQueryLimitModifier alloc] initWithLimit:10]]; //just get back 10 results
    
    [self.updateStore queryWithQuery:query withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        [self.refreshControl endRefreshing];
        if (objectsOrNil) {
            
            // Empty our array
            self.movieArr = [[NSMutableArray alloc] init];
            
            for (Movie *movie in objectsOrNil) {
                NSDictionary *entry = @{@"image":movie.image, @"timestamp":movie.timestamp};
                
                [self.movieArr addObject:entry];
            }
            
            [self.tableView reloadData];
        }
    } withProgressBlock:nil];
}

// ==========================================================================
// C methods
// ==========================================================================
//


#pragma mark -
#pragma mark C methods





@end















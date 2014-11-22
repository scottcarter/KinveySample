
## About

This project is intended to demonstrate a simple integration with [Kinvey](http://www.kinvey.com)

It embeds the functionality from my [Video Export project](https://github.com/scottcarter/VideoExport) in a mix of Objective-C and Swift code.


Selecting the Compose icon on the right side of the navigation bar allows the user to take a new video or select an existing one from the Camera Roll.  New videos captured with this project are limited to 10 seconds.  After taking or selecting a video, a Save button appears on the toolbar of the movie view controller.   Selecting this button will export the video as MP4 at a reduced bitrate.  A thumbnail of an early frame of the video is extracted.  The video (and a thumbnail) are then saved to the Kinvey backend.

After saving an MP4 video to Kinvey, the user can view the thumbnails of the most recent 10 videos in a table view.  After selecting the thumbnail, the full video is fetched from Kinvey and played.



Caveats:
  * Proper error handling with retries, etc. is not yet implemented.
  * Video caching on the device is not enabled.  A fetch to Kinvey is made on every thumbnail selection.
  * The project is functional, but has had limited testing.
  * There are some warnings, but these are within external libraries.
  
Known Issues:
  * Most videos I tried worked fine, but I ran across one where a thumbnail could not be extracted and crashed (see caveat about error handling).
  * I need to disable the Cancel button until a movie is fully loaded (viewing or saving).  Selecting Cancel during a movie load can cause a crash.


## MP4 details

The following was used for the MP4 export:
 
  1. Dimensions reduced to no greater than 512 x 288 (16:9) or 480 x 360 (4:3)
  2. Rotation (preferred transform) of container set to 0 degrees (CGAffineTransformIdentity).
  3. Video profile level set to AVVideoProfileLevelH264Baseline30 (Baseline@L3.0)
  4. Video bitrate reduced to average of 725,000 bps
  5. MP4 container
  

## Installation

### Pods

Navigate to the folder where you downloaded the project (Ex: KinveySample-master) and execute

pod install

Assumes that CocoaPods is installed on your system.


### Workspace based

When opening the project, be sure to select KinveySample.xcworkspace.


### Kinvey setup

Create a new Kinvey App to accompany this project.  Within the app, navigate to the Dashboard and note the App ID and App Secret. 

Edit AppDelegate.m.  Within application:didFinishLaunchingWithOptions: look for initializeKinveyServiceForAppKey:withAppSecret:usingOptions: and insert your own App Key (App ID) and App Secret.










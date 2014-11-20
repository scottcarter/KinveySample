
## About

This project is intended to demonstrate a simple integration with [Kinvey](http://www.kinvey.com)

It embeds the functionality from my [Video Export project](https://github.com/scottcarter/VideoExport) in a mix of Objective-C and Swift code.

The user can take a video up to 10 seconds in duration which is then exported as MP4 with a reduced bitrate.  A thumbnail of an early frame of the video is extracted.

Both the MP4 video and thumbnail are saved to the Kinvey backend.   The user can view the thumbnails of the most recent 10 videos in a table view.  After selecting the thumbnail, the full video is fetched from Kinvey and played.

The project does not currently demonstrate proper error handling with retries, etc.


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










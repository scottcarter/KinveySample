//
//  Movie.h
//  KinveySample
//
//  Created by Scott Carter on 11/21/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

@interface Movie : NSObject <KCSPersistable>
@property (nonatomic, copy) NSString* entityId; //Kinvey entity _id
@property (nonatomic, copy) NSNumber* timestamp;
@property (nonatomic, copy) UIImage* image;
@property (nonatomic, retain) KCSMetadata* metadata; //Kinvey metadata, optional

@end


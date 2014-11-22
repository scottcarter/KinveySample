//
//  Movie.m
//  KinveySample
//
//  Created by Scott Carter on 11/21/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#import "Movie.h"

@implementation Movie

- (NSDictionary *)hostToKinveyPropertyMapping
{
    return @{
             @"entityId" : KCSEntityKeyId, //the required _id field
             @"timestamp" : @"timestamp",
             @"image" : @"image",
             @"metadata" : KCSEntityKeyMetadata //optional _metadata field
             };
}

+ (NSDictionary *)kinveyPropertyToCollectionMapping
{
    return @{@"image": KCSFileStoreCollectionName};
}

@end
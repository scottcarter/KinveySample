//
//  SignInViewController.m
//  KinveySample
//
//  Created by Scott Carter on 11/16/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#import "SignInViewController.h"

#import "KWSignInViewController.h"
#import "KCSSignInDelegate.h"

#import "Project.h"

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
@interface SignInViewController () <KCSSignInResponder>

// ==========================================================================
// Properties
// ==========================================================================
//
#pragma mark -
#pragma mark Properties

// None

@end



// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Implementation
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
#pragma mark -
@implementation SignInViewController

// ==========================================================================
// Constants and Defines
// ==========================================================================
//
#pragma mark -
#pragma mark Constants and Defines

// None




// ==========================================================================
// Getters and Setters
// ==========================================================================
//
#pragma mark -
#pragma mark Getters and Setters

// None


// ==========================================================================
// Actions
// ==========================================================================
//
#pragma mark -
#pragma mark Actions


- (IBAction)LoginAction:(UIButton *)sender {
    
    FIXME()
    [self performSegueWithIdentifier:@"listSegue" sender:self];
    return;
    
    KWSignInViewController* signInViewController = [[KWSignInViewController alloc] init];
    
    // Create an instance of KCSSignInDelegate to handle the protocol methods for KWSignInViewControllerDelegate
    // which KWSignInViewController uses.
    KCSSignInDelegate* signInDelegate = [[KCSSignInDelegate alloc] init];
    signInDelegate.signInResponder = self;
    
    
    signInViewController.signInDelegate = signInDelegate;
    
    // Show the sign in view controller.
    [signInViewController showModally];
    
}



// ==========================================================================
// Initializations
// ==========================================================================
//
#pragma mark -
#pragma mark Initializations

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [KCSPing pingKinveyWithBlock:^(KCSPingResult *result) {
        if (result.pingWasSuccessful == YES){
            NSLog(@"Kinvey Ping Success with result %@",result);
        } else {
            NSLog(@"Kinvey Ping Failed with result %@",result);
        }
    }];
        
}


// ==========================================================================
// Protocol methods
// ==========================================================================
//
#pragma mark -
#pragma mark Protocol methods

#pragma mark KCSSignInResponder

- (void) userSucessfullySignedIn:(KCSUser*)user
{
    NSLog(@"User successfully signed in: %@", user);
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"listSegue" sender:self];
    }];
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

// None



// ==========================================================================
// C methods
// ==========================================================================
//


#pragma mark -
#pragma mark C methods





@end












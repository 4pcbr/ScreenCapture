//
//  SFTPStorageAgent.m
//  ScreenCapture
//
//  Created by Olegs on 05/10/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "SFTPStorageAgent.h"
#import <NMSSHSession.h>

@implementation SFTPStorageAgent

- (PMKPromise *)storeFile:(NSFileHandleWithName *)inputFileHandleWithName {
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
    
        NSString     *host          = [self->options valueForKey:@"Host"];
        NSString     *user          = [self->options valueForKey:@"User"];
        NSString     *storagePath   = [self->options valueForKey:@"StoragePath"];
        NSString     *webScheme     = [self->options valueForKey:@"WebScheme"];
        NSString     *webHost       = [self->options valueForKey:@"WebHost"];
        NSString     *webPath       = [self->options valueForKey:@"WebPath"];
        
        NMSSHSession *session = [NMSSHSession connectToHost:host withUsername:user];
        
        if ([session isConnected]) {
            [session authenticateByPassword:[self->options valueForKey:@"Password"]];
            if ([session isAuthorized]) {
                NSLog(@"Successfully authorised as %@ on host %@", user, host);
            } else {
                NSLog(@"Failed to authenticate user %@ with password", user);
                self->result    = NULL;
                self->succeeded = NO;
                fulfill(NULL);
            }

            NSString *remoteFileName  = [self generateFilenameYYYYMMDDHHIISS:inputFileHandleWithName];
            NSString *fileDestination = [NSString stringWithFormat:@"%@/%@", storagePath, remoteFileName];
            NSString *fileWebPath     = [NSString stringWithFormat:@"%@/%@", webPath, remoteFileName];
            NSURL    *resultURL       = [[NSURL alloc] initWithScheme:webScheme host:webHost path:fileWebPath];
            
            BOOL success = [session.channel uploadFile:[inputFileHandleWithName fileName] to:fileDestination];
            
            if (success) {
                NSLog(@"%@", resultURL);
                self->result    = [resultURL absoluteString];
                self->succeeded = YES;
            }
            
            fulfill(self->result);
            
            [session disconnect];
        } else {
            NSLog(@"Unable to establish a connection to %@", host);
            self->result    = NULL;
            self->succeeded = NO;
            fulfill(NULL);
        }
    }];
}

@end

//
//  GenericStorageAgent.h
//  ScreenCapture
//
//  Created by Olegs on 05/10/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Processable.h"
#import "Screenshot.h"
#import <AppKit/NSView.h>

@interface GenericStorageAgent : NSObject <Processable> {
@protected
    NSDictionary *options;
    BOOL enabled;
}

- (BOOL)enabled;

- (void)setEnabled:(BOOL)enabled_;

- (id)initAgentWithOptions:(NSDictionary *)options;

- (BOOL)canStoreFile:(Screenshot *)screenshot;

- (PMKPromise *)store:(Screenshot *)screenshot;

- (NSString *)generateFilenameYYYYMMDDHHIISS:(Screenshot *)screenshot;

- (NSString *)getDomain;

@end

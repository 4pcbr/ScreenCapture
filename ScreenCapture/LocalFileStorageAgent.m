//
//  LocalFileStorageAgent.m
//  ScreenCapture
//
//  Created by Olegs on 28/09/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "LocalFileStorageAgent.h"

@implementation LocalFileStorageAgent {
    BOOL enabled;
}

- (BOOL) enabled {
    return self->enabled;
}

- (void)setEnabled:(BOOL)enabled_ {
    self->enabled = enabled_;
}

- (id)initAgentWithOptions:(NSDictionary *)options_ {
    
    if (self = [super init]) {
        self->options = options_;
        [self setEnabled:(BOOL)[options_ valueForKey:@"Enabled"]];
        NSLog(@"%@", self->options);
    }
    
    return self;
}

- (BOOL)canStoreFile:(NSFileHandle *)file {
    return YES;
}

- (PMKPromise *)storeFile:(NSFileHandle *)inputFile {
    NSLog(@"Current settings: %@", self->options);
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSAssert(inputFile != nil, @"Input file handle can not be nil");
        
        NSLog(@"Calling storeFile on LocalFileStorageAgent");
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        
        NSString *destinationFolder = [(NSString *)[self->options valueForKey:@"StorePath"] stringByStandardizingPath];
        
        NSError *createFolderError;
        
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:destinationFolder withIntermediateDirectories:YES attributes:nil error:&createFolderError];
        
        if (!success || createFolderError) {
            NSLog(@"Error creating folder %@", destinationFolder);
        }
        
        NSString *fileName = [[NSString stringWithFormat:@"%@/%@.png",
                              destinationFolder,
                              [dateFormatter stringFromDate:[NSDate date]]
                              ] stringByStandardizingPath];
        
        NSFileHandle *outputFile = [NSFileHandle fileHandleForWritingAtPath:fileName];
        
        NSLog(@"About to create a new file: %@", fileName);
        
        NSString *failedAssertMsg = [NSString stringWithFormat:@"Failed to create the destination file, %@", fileName];
        
        if (outputFile == nil) {
            [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
            outputFile = [NSFileHandle fileHandleForWritingAtPath:fileName];
        }
        
        NSAssert(outputFile != nil, failedAssertMsg);
        
        NSData *buffer;
        
        @try {
            [inputFile seekToFileOffset:0];
            [outputFile seekToFileOffset:0];
            
            while ([(buffer = [inputFile readDataOfLength:1024]) length] > 0) {
                [outputFile writeData:buffer];
            }
            NSLog(@"Done copying the file");
        }
        @catch (NSException *exception) {
            @throw;
        }
        @finally {
            [inputFile seekToFileOffset:0];
            [outputFile closeFile];
            fulfill(NULL);
        }
    }];
}

- (PMKPromise *)proceed:(id)arg {
    return [self storeFile:arg];
}

@end

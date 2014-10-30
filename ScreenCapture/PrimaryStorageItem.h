//
//  PrimaryStorage.h
//  ScreenCapture
//
//  Created by Olegs on 29/10/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RemoteRESTAPIStorageItem;

@interface PrimaryStorageItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) RemoteRESTAPIStorageItem *remote_rest_api_items;

@end

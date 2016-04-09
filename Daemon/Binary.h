//
//  Process.h
//  BlockBlock
//
//  Created by Patrick Wardle on 10/26/14.
//  Copyright (c) 2016 Objective-See. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Binary : NSObject
{

}

/* PROPERTIES */

//binary path
@property (nonatomic, retain)NSString* path;

//binary name
@property (nonatomic, retain)NSString* name;

//flag indicating binary belongs to Apple OS
@property BOOL isApple;

//flag indicating binary was present at baseline
@property BOOL isBaseline;

//flag indicating binary was approved
@property BOOL isApproved;

/* METHODS */

//init w/ an info dictionary
-(id)init:(NSString*)path attributes:(NSDictionary*)attributes;

@end

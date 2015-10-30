//
//  COLExporter.h
//  ColaLib
//
//  Created by Chris on 28/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "COLAudioEnvironment.h"

#define COL_COMPONENTS_KEY                          @"components"
#define COL_COMPONENT_IDENTIFIER_KEY                @"componentIdentifier"
#define COL_COMPONENT_CLASS_KEY                     @"componentClass"
#define COL_COMPONENT_CONNECTION_FROM_KEY           @"connectionFrom"
#define COL_COMPONENT_CONNECTION_TO_KEY             @"connectionTo"

#define COL_CONNECTIONS_KEY                         @"connections"
#define COL_CONNECTOR_COMPONENT_KEY                 @"connectorComponent"
#define COL_CONNECTOR_NAME_KEY                      @"connectorName"

@interface COLExporter : NSObject

+(NSData*)getJSONObjectForEnvironment:(COLAudioEnvironment*)environment;

@end

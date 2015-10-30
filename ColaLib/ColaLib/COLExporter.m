//
//  COLExporter.m
//  ColaLib
//
//  Created by Chris on 28/10/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#import "COLExporter.h"

@implementation COLExporter

+(NSData*)getJSONObjectForEnvironment:(COLAudioEnvironment*)environment{
    
//    NSMutableArray *componentArray = [[NSMutableArray alloc] initWithCapacity:environment.components.count];
//    NSMutableArray *connectionArray = [[NSMutableArray alloc] initWithCapacity:environment.components.count * 2];
//    
//    for (COLComponent *thisComponent in environment.components) {
//        NSString *identifier = thisComponent.identifier;
//        
//        for (COLComponentOutput *thisOutput in thisComponent.outputs) {
//            if (thisOutput.isConnected) {
//                NSDictionary *connectionDictionary = @{
//                                                       COL_COMPONENT_CONNECTION_FROM_KEY : @{
//                                                               COL_CONNECTOR_COMPONENT_KEY : thisComponent.identifier,
//                                                               COL_CONNECTOR_NAME_KEY : thisOutput.name
//                                                               },
//                                                       COL_COMPONENT_CONNECTION_TO_KEY : @{
//                                                               COL_CONNECTOR_COMPONENT_KEY : thisOutput.connectedTo.component ? thisOutput.connectedTo.component.identifier : @"",
//                                                               COL_CONNECTOR_NAME_KEY : thisOutput.connectedTo.name                                                               }
//                                                       };
//                [connectionArray addObject:connectionDictionary];
//            }
//        }
//        
//        [componentArray addObject:@{
//                                    COL_COMPONENT_IDENTIFIER_KEY    : identifier,
//                                    COL_COMPONENT_CLASS_KEY         : NSStringFromClass([thisComponent class])
//                                    }];
//        
//    }
//    
//    NSDictionary *dictionary = @{
//                                COL_COMPONENTS_KEY : [NSArray arrayWithArray:componentArray],
//                                COL_CONNECTIONS_KEY : [NSArray arrayWithArray:connectionArray]
//                                };
//    
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
//    
//    if (error ) {
//        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
//        return nil;
//    } else {
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", jsonString);
//    }
    
    return nil;
}


@end

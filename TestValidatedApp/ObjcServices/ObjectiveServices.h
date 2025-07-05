//
//  MyObjectiveCClass.h
//  TestValidatedApp
//
//  Created by Luong Manh on 2/7/25.
//

#import <Foundation/Foundation.h>

@interface ObjectiveServices: NSObject

- (BOOL) validateUrl: (NSString *) candidate;
- (BOOL) checkExitsVideo: (NSString *) fileName;
@end

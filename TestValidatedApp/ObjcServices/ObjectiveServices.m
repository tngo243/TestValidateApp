//
//  SavedService.m
//  TestValidatedApp
//
//  Created by Luong Manh on 2/7/25.
//

#import "ObjectiveServices.h"

@implementation ObjectiveServices

- (BOOL) validateUrl: (NSString *) candidate {
    NSString *string = @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&amp;=]*)?";
    NSString *urlRegEx = string;
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (BOOL) checkExitsVideo: (NSString *) fileName {
    BOOL isExits = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];

    NSFileManager *manager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *fileEnumerator = [manager enumeratorAtPath:documentsPath];

    for (NSString *filename in fileEnumerator)  {
        if ([fileName isEqualToString:filename]) {
            isExits = YES;
        }
    }
    return isExits;
}
@end

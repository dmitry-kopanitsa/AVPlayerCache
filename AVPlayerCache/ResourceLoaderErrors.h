#import <Foundation/Foundation.h>

static NSString *kResourceLoaderErrorDomain = @"ResourceLoaderError";

typedef enum {
    RLErrorCancel = -1,
    RLErrorWrongURLScheme = -2,
    RLErrorFileReadingFailure = -3,
    RLErrorFileReadingNoData = -4,
    RLErrorFileReadingZeroLengthData = -5,
    RLErrorFileWritingError = -6
}RLErrorCode;
#include <ruby.h>
#import <Foundation/Foundation.h>

@interface Observer : NSObject
{
}

@property (assign) NSString *name;
@property (assign) VALUE handler;

-(void)observe;

@end

VALUE createInstanceFromObserver(Observer *obs);

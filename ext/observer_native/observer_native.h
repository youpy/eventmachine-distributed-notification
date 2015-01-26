#include <ruby.h>
#import <Foundation/Foundation.h>

@interface Observer : NSObject
{
  NSString *name;
  VALUE handler;
}

@property (assign) NSString *name;
@property (assign) VALUE handler;

-(void)observe;
-(void)unobserve;

@end

VALUE createInstanceFromObserver(Observer *obs);
VALUE getRubyValueFromId(id thing);

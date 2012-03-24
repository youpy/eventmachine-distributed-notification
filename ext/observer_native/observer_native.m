#import "observer_native.h"

@interface Observer (Private)
- (void) notify:(NSNotification *)theNotification;
@end

@implementation Observer

@synthesize name;
@synthesize handler;

- (void)dealloc
{
  [self unobserve];
  [name release];
  [super dealloc];
}

- (void)observe
{
  [[NSDistributedNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(notify:)
                   name:(name != nil) ? name : nil
                 object:nil
   ];
}

- (void)unobserve
{
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notify:(NSNotification *)theNotification
{
  VALUE aName = rb_str_new2([[theNotification name] UTF8String]);
  NSDictionary *userInfo = [theNotification userInfo];
  VALUE hash = rb_hash_new();

  for(id key in userInfo) {
    rb_hash_aset(hash,
                 rb_str_new2([[key description] UTF8String]),
                 getRubyValueFromId([userInfo objectForKey:key]));
  }

  rb_funcall(handler, rb_intern("notify"), 2, aName, hash);
}

@end

static VALUE rb_cObserverNative;

struct ObserverObject {
  Observer *obs;
};

Observer *getObserver(VALUE obj) {
  struct ObserverObject *observerObject;

  Data_Get_Struct(obj, struct ObserverObject, observerObject);

  return observerObject->obs;
}

void cObserverNative_free(void *ptr) {
  Observer *obs = (Observer *)(((struct ObserverObject *)ptr)->obs);

  [obs release];

  free(ptr);
}

VALUE getRubyValueFromId(id thing) {
  VALUE result;

  if([thing isKindOfClass:[NSNumber class]]) {
    if(strcmp([thing objCType], @encode(BOOL)) == 0)
      result = thing ? Qtrue : Qfalse;
    else if(strcmp([thing objCType], @encode(int)) == 0)
      result = INT2NUM([thing intValue]);
    else if(strcmp([thing objCType], @encode(unsigned int)) == 0)
      result = INT2NUM([thing unsignedIntValue]);
    else if(strcmp([thing objCType], @encode(long)) == 0)
      result = INT2NUM([thing longValue]);
    else if(strcmp([thing objCType], @encode(float)) == 0)
      result = rb_float_new([thing floatValue]);
    else if(strcmp([thing objCType], @encode(double)) == 0)
      result = rb_float_new([thing doubleValue]);
    else
      result = INT2NUM([thing longLongValue]);
  } else if([thing isKindOfClass:[NSNumber class]]) {
    result = rb_str_new2([thing UTF8String]);
  } else {
    result = rb_str_new2([[thing description] UTF8String]);
  }

  return result;
}

VALUE createInstanceFromObserver(Observer *obs) {
  struct ObserverObject *obj;

  obj = malloc(sizeof(struct ObserverObject));
  obj->obs = obs;

  return Data_Wrap_Struct(rb_cObserverNative, 0, cObserverNative_free, obj);
}

static VALUE cObserverNative_new(int argc, VALUE *argv, VALUE klass)
{
  VALUE name, handler, obj;
  Observer *obs;

  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  rb_scan_args(argc, argv, "2", &name, &handler);

  obs = [[Observer alloc] init];
  obj = createInstanceFromObserver(obs);

  if(RTEST(name)) {
    [obs setName:[[NSString stringWithUTF8String:StringValuePtr(name)] retain]];
  }

  [obs setHandler:handler];

  [pool release];

  return obj;
}

static VALUE cObserverNative_run(int argc, VALUE *argv, VALUE self)
{
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];

  return Qnil;
}

static VALUE cObserverNative_run_forever(int argc, VALUE *argv, VALUE self)
{
  [[NSRunLoop currentRunLoop] run];

  return Qnil;
}

static VALUE cObserverNative_observe(int argc, VALUE *argv, VALUE self)
{
  Observer *obs = getObserver(self);

  [obs observe];

  return Qnil;
}

static VALUE cObserverNative_unobserve(int argc, VALUE *argv, VALUE self)
{
  Observer *obs = getObserver(self);

  [obs unobserve];

  return Qnil;
}

void Init_observer_native(void){
  VALUE rb_mEventMachine, rb_mDistributedNotification;

  rb_mEventMachine = rb_define_module("EventMachine");
  rb_mDistributedNotification = rb_define_module_under(rb_mEventMachine, "DistributedNotification");
  rb_cObserverNative = rb_define_class_under(rb_mDistributedNotification, "ObserverNative", rb_cObject);
  rb_define_singleton_method(rb_cObserverNative, "new", cObserverNative_new, -1);
  rb_define_method(rb_cObserverNative, "run", cObserverNative_run, -1);
  rb_define_method(rb_cObserverNative, "run_forever", cObserverNative_run_forever, -1);
  rb_define_method(rb_cObserverNative, "observe", cObserverNative_observe, -1);
  rb_define_method(rb_cObserverNative, "unobserve", cObserverNative_unobserve, -1);
}

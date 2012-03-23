#import "observer_native.h"

@interface Observer (Private)
- (void) notify:(NSNotification *)theNotification;
@end

@implementation Observer

@synthesize name;
@synthesize handler;

- (void)dealloc
{
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
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

- (void)notify:(NSNotification *)theNotification
{
  VALUE aName = rb_str_new2([[theNotification name] UTF8String]);
  NSDictionary *userInfo = [theNotification userInfo];
  VALUE hash = rb_hash_new();

  for(id key in userInfo) {
    rb_hash_aset(hash, rb_str_new2([[key description] UTF8String]), rb_str_new2([[[userInfo objectForKey:key] description] UTF8String]));
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
  [obs observe];

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

void Init_observer_native(void){
  VALUE rb_mEventMachine, rb_mDistributedNotification;

  rb_mEventMachine = rb_define_module("EventMachine");
  rb_mDistributedNotification = rb_define_module_under(rb_mEventMachine, "DistributedNotification");
  rb_cObserverNative = rb_define_class_under(rb_mDistributedNotification, "ObserverNative", rb_cObject);
  rb_define_singleton_method(rb_cObserverNative, "new", cObserverNative_new, -1);
  rb_define_method(rb_cObserverNative, "run", cObserverNative_run, -1);
  rb_define_method(rb_cObserverNative, "run_forever", cObserverNative_run_forever, -1);
}

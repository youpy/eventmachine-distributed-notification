#import "poster_native.h"

static VALUE rb_cPosterNative;

struct PosterObject {
};

void cPosterNative_free(void *ptr) {
  free(ptr);
}

VALUE createInstance() {
  struct PosterObject *obj;

  obj = malloc(sizeof(struct PosterObject));

  return Data_Wrap_Struct(rb_cPosterNative, 0, cPosterNative_free, obj);
}

static VALUE cPosterNative_new(int argc, VALUE *argv, VALUE klass)
{
  return createInstance();
}

static VALUE cPosterNative_post(int argc, VALUE *argv, VALUE self)
{
  VALUE name, data;
  NSDictionary *userInfo;
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  rb_scan_args(argc, argv, "2", &name, &data);

  userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:StringValuePtr(data)] forKey:@"data"];

  [[NSDistributedNotificationCenter defaultCenter]
    postNotificationName:[NSString stringWithUTF8String:StringValuePtr(name)]
                  object:nil
                userInfo:userInfo
      deliverImmediately:YES];

  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

  [pool release];

  return Qnil;
}

void Init_poster_native(void){
  VALUE rb_mEventMachine, rb_mDistributedNotification;

  rb_mEventMachine = rb_define_module("EventMachine");
  rb_mDistributedNotification = rb_define_module_under(rb_mEventMachine, "DistributedNotification");
  rb_cPosterNative = rb_define_class_under(rb_mDistributedNotification, "PosterNative", rb_cObject);
  rb_define_singleton_method(rb_cPosterNative, "new", cPosterNative_new, -1);
  rb_define_method(rb_cPosterNative, "post", cPosterNative_post, -1);
}

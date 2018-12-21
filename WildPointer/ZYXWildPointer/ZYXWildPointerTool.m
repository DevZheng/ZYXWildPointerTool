//
//  ZYXWildPointerTool.m
//  WildPointer
//
//  Created by Zheng,Yuxin on 2018/12/20.
//  Copyright © 2018 Zheng,Yuxin. All rights reserved.
//

//#import "ZYXWildPointerTool.h"

#import <Foundation/Foundation.h>
#import <malloc/malloc.h>
#import "fishhook.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import "ZYXQueue.h"

@interface ZYXWDCatcher : NSProxy

@property (nonatomic, assign) Class originClass;

@end

@implementation ZYXWDCatcher

#define ZYXThrowExpection [self throwExcept]

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    ZYXThrowExpection;
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    ZYXThrowExpection;
    return [super forwardInvocation:invocation];
}

- (void)throwExcept {
    @throw [NSException exceptionWithName:NSObjectInaccessibleException reason:[NSString stringWithFormat:@"当前对象已经成为僵尸对象: %@", _originClass]  userInfo:nil];
}
@end

#define kQueueMaxUnFreeSize 1024 * 1024 * 50

size_t zyx_catch_size;
void (*zyx_origin_free)(void *);
CFMutableSetRef zyx_classSet;

static Class zyx_catch_cls;

static ZYXQueue queue;

void safe_free(void *p) {
    size_t size = malloc_size(p);

    if (size > zyx_catch_size) {
        id obj = (id)p;
        Class cls = object_getClass(obj);
        
        if (cls && CFSetContainsValue(zyx_classSet, cls)) { // 当前对象是一个 oc 类的实例
            
            memset(obj, 0x55, size);
            memcpy(obj, &zyx_catch_cls, sizeof(void *));

            ZYXWDCatcher *catcher = (ZYXWDCatcher *)obj;
            catcher.originClass = cls;
            
        } else {
            memset(obj, 0x55, size);
        }
    } else {
        memset(p, 0x55, size);
    }

    zyxQueue_add_unfree_ptr(&queue, p);
    
//    zyx_origin_free(p);
}

void save_origin_symbols() {
    
    zyxQueue_init(&queue, kQueueMaxUnFreeSize);
    
    zyx_origin_free = (void(*)(void*))dlsym(RTLD_DEFAULT, "free");
    zyx_catch_size = class_getInstanceSize([ZYXWDCatcher class]);
    zyx_catch_cls = objc_getClass("ZYXWDCatcher");
    
    unsigned int outCount = 0;
    Class *classes = objc_copyClassList(&outCount);

    zyx_classSet = CFSetCreateMutable(NULL, 0, NULL);
    
    for (int i = 0; i < outCount; i ++) {
        CFSetSetValue(zyx_classSet, classes[i]);
    }
    
    free(classes);
    classes = NULL;
}

void begin_check_wild_pointer() {
    
    save_origin_symbols();
    
    struct rebinding r = {"free", safe_free};
    struct rebinding rs[1] = {r};
    
    rebind_symbols(rs, 1);
}

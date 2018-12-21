//
//  ZYXQueue.h
//  WildPointer
//
//  Created by Zheng,Yuxin on 2018/12/21.
//  Copyright © 2018 Zheng,Yuxin. All rights reserved.
//

#ifndef ZYXQueue_h
#define ZYXQueue_h


#include <pthread/pthread.h>

typedef struct _ZYXQueueElement {
    struct _ZYXQueueElement *next;
    void *ptr;
} ZYXQueueElement;

typedef struct _ZYXQueue {
    
    ZYXQueueElement *header;
    ZYXQueueElement *last;
    
    ZYXQueueElement *reuseHeader;
    ZYXQueueElement *reuseLast;
    
    size_t sizeOfUnfreeMemory;
    size_t maxSizeOfUnfreeMemory;
    
    int countOfUnfreePtr;
    
    pthread_mutex_t lock;
    
} ZYXQueue;

int zyxQueue_init(ZYXQueue *queue, size_t maxSize);

int zyxQueue_add_unfree_ptr(ZYXQueue *queue, void *p);

#endif /* ZYXQueue_h */

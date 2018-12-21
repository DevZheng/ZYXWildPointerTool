//
//  ZYXQueue.c
//  WildPointer
//
//  Created by Zheng,Yuxin on 2018/12/21.
//  Copyright © 2018 Zheng,Yuxin. All rights reserved.
//

#include "ZYXQueue.h"
#include <malloc/malloc.h>
#include <stdlib.h>
#include <stdio.h>

// 清除部分内存
void _zyxQueue_free_memory() {
    
}

int _zyxQueue_element_init(ZYXQueueElement *element) {
    if (element == NULL) {
        return -1;
    }

    element -> next = NULL;
    element -> ptr = NULL;

    return 0;
}

ZYXQueueElement *_zyxQueue_get_reuseElement(ZYXQueue *queue) {
    
    ZYXQueueElement *ele = queue -> reuseHeader;
    
    if (ele == NULL) {
        ele = (ZYXQueueElement *)malloc(sizeof(struct _ZYXQueueElement));
    } else {
        ZYXQueueElement *nhead = ele -> next;
        queue -> reuseHeader = nhead;
        ele -> next = NULL;
        
        if (queue -> reuseHeader == NULL) {
            queue -> reuseLast = NULL;
        }
    }

    _zyxQueue_element_init(ele);
    
    return ele;
}

int zyxQueue_init(ZYXQueue *queue, size_t maxSize) {
    
    if (!queue) {
        return 0;
    }
    
    queue -> header = NULL;
    queue -> last = NULL;
    queue -> reuseHeader = NULL;
    queue -> reuseLast = NULL;
    
    queue -> maxSizeOfUnfreeMemory = maxSize;
    queue -> countOfUnfreePtr = 0;
    queue -> sizeOfUnfreeMemory = 0;
    
    int res = pthread_mutex_init(&(queue -> lock), NULL);
    
    return res;
}

int zyxQueue_add_unfree_ptr(ZYXQueue *queue, void *p) {
    
    pthread_mutex_lock(&queue->lock);
    // 判断加上是否超过最大的限制
    size_t sizeP = malloc_size(p);
    if (queue -> sizeOfUnfreeMemory + sizeP > queue -> maxSizeOfUnfreeMemory) {
        _zyxQueue_free_memory();
    }
    
    // 查找有无缓存之前分配的内存对象, 没有的话新建对象
    ZYXQueueElement *element = _zyxQueue_get_reuseElement(queue);
    
    if (queue -> header == NULL) {
        queue -> header = element;
        queue -> last = element;
    } else {
        ZYXQueueElement *oldLast = queue -> last;
        oldLast -> next = element;
        queue -> last = element;
    }
    
    queue -> countOfUnfreePtr += 1;
    queue -> sizeOfUnfreeMemory += sizeP;
    
//    printf("_______countOfUnfreePtr %d", queue->countOfUnfreePtr);
    
    pthread_mutex_unlock(&queue->lock);
    
    return 0;
}




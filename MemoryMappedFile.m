//
//  MemoryMappedFile.m
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 21/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MemoryMappedFile.h"
#import <sys/mman.h>

@implementation MemoryMappedFile

- (id)initWithFileHandle:(NSFileHandle *)fileHandle offset:(off_t)offset length:(size_t)length
{
    self = [super init];
    if (self) {
        int fd = [fileHandle fileDescriptor];
        _len = length;
        _addr = mmap(0, _len, PROT_READ|PROT_WRITE, MAP_FILE, fd, offset);
        _fileHandle = [fileHandle retain];
    } 
    return self;
}

- (void)dealloc {
    [self unmap];
    if (_fileHandle) {
        [_fileHandle release];
        _fileHandle = nil;
    }
    [super dealloc];
}

- (void)finalize {
    [self unmap];
    [super finalize];
}

- (int)unmap {
    if (_addr) {
        int k = munmap(_addr, _len);
        _addr = NULL;
        return k;
    } else {
        return 0;
    }
}


- (NSData *)data {
    return [NSData dataWithBytesNoCopy:_addr length:_len freeWhenDone:NO];
}



- (const void *)bytes {
    return _addr;
}
- (void)getBytes:(void *)buffer length:(NSUInteger)length {
    // TODO: range check
    memcpy(buffer, _addr, length);
}
- (void)getBytes:(void *)buffer range:(NSRange)range {
    // TODO: range check
    memcpy(buffer, _addr+range.location, range.length);
}
- (NSData *)subdataWithRange:(NSRange)range {
    // TODO: range check
    return [NSData dataWithBytesNoCopy:_addr+range.location length:range.length freeWhenDone:NO];
}
- (size_t)length {
    return _len;
}

- (void *)mutableBytes {
    return _addr;
}
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)bytes {
    // TODO: range check
    memcpy(_addr+range.location, bytes, range.length);
}
- (void)resetBytesInRange:(NSRange)range {
    // TODO: range check
    memset(_addr+range.location, 0, range.length);
}

@end

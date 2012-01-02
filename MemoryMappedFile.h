//
//  MemoryMappedFile.h
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 21/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MemoryBlock <NSObject>
- (const void *)bytes;
- (void)getBytes:(void *)buffer length:(NSUInteger)length;
- (void)getBytes:(void *)buffer range:(NSRange)range;
- (NSData *)subdataWithRange:(NSRange)range;
- (size_t)length;
@end

@protocol WritableMemoryBlock <MemoryBlock>
- (void *)mutableBytes;
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)bytes;
- (void)resetBytesInRange:(NSRange)range;
@end


@interface MemoryMappedFile : NSObject {
    NSFileHandle *_fileHandle;
    void *_addr;
    size_t _len;
}

- (id)initWithFileHandle:(NSFileHandle *)fileHandle offset:(off_t)offset length:(size_t)length;
- (int)unmap;

- (NSData *)data;

- (const void *)bytes;
- (void)getBytes:(void *)buffer length:(NSUInteger)length;
- (void)getBytes:(void *)buffer range:(NSRange)range;
- (NSData *)subdataWithRange:(NSRange)range;
- (size_t)length;

- (void *)mutableBytes;
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)bytes;
- (void)resetBytesInRange:(NSRange)range;

@end

//
//  FolderInfo.m
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 11/05/14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FolderInfo.h"

#import <assert.h>


static NSString *KTErrorDomain = @"KTErrorDomain";
enum {
    KT_INVALID_CHAR_ERROR,
    KT_TOO_LONG_ERROR,
    KT_OUT_OF_RANGE
};

static NSString *getStringFromDataWithEncoding(NSData *data, NSRange range, NSStringEncoding encoding) {
    char *buffer = malloc(range.length+1);
    if (!buffer) return nil;
    [data getBytes:buffer range:range];
    buffer[range.length] = '\0';
    NSString *s = [NSString stringWithCString:buffer encoding:encoding];
    free(buffer);
    return s;
}
static void setStringFromDataWithEncoding(NSMutableData *data, NSRange range, NSString *value, NSStringEncoding encoding) {
    NSMutableData *vdata = [[value dataUsingEncoding:encoding] mutableCopy];
    [vdata setLength:range.length];
    [data replaceBytesInRange:range withBytes:[vdata bytes]];
    [vdata release];
}

static NSString *getStringFromDataWithCFEncoding(NSData *data, NSRange range, CFStringEncoding encoding) {
    return getStringFromDataWithEncoding(data, range, CFStringConvertEncodingToNSStringEncoding(encoding));
}

static uint8_t getUInt8FromData(NSData *data, NSRange range) {
    assert(range.length == 1);
    uint8_t value = 0;
    [data getBytes:&value range:range];
    return value;
}
static void setUInt8FromData(NSMutableData *data, NSRange range, uint8_t value) {
    assert(range.length == 1);
    [data replaceBytesInRange:range withBytes:&value];
}

static uint16_t getUInt16FromData(NSData *data, NSRange range) {
    assert(range.length == 2);
    uint16_t value = 0;
    [data getBytes:&value range:range];
    return CFSwapInt16BigToHost(value);
}
static void setUInt16FromData(NSMutableData *data, NSRange range, uint16_t value) {
    assert(range.length == 2);
    value = CFSwapInt16BigToHost(value);
    [data replaceBytesInRange:range withBytes:&value];
}
static uint32_t getUInt32FromData(NSData *data, NSRange range) {
    assert(range.length == 4);
    uint32_t value = 0;
    [data getBytes:&value range:range];
    return CFSwapInt32BigToHost(value);
}
static void setUInt32FromData(NSMutableData *data, NSRange range, uint32_t value) {
    assert(range.length == 4);
    value = CFSwapInt32BigToHost(value);
    [data replaceBytesInRange:range withBytes:&value];
}

static NSDate *getDateFromData(NSData *data, NSRange range) {
    assert(range.length == 20);
    NSString *dateString = getStringFromDataWithEncoding(data, range, NSASCIIStringEncoding);
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    return [formatter dateFromString:dateString];
} 
static void setDateFromData(NSMutableData *data, NSRange range, NSDate *date) {
    assert(range.length == 20);
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:date];
    setStringFromDataWithEncoding(data, range, dateString, NSASCIIStringEncoding);
}


static BOOL validateFixedString(id *ioValue, NSError **outError, NSStringEncoding encoding, size_t maxLength) {
    if (![(NSString *)*ioValue canBeConvertedToEncoding:encoding]) {
        if (outError) {
            NSString *errorString = NSLocalizedString(@"Specified string contains some characters that cannot be expressed in the encoding", @"");
            NSDictionary *userInfoDict =
            [NSDictionary dictionaryWithObject:errorString
                                        forKey:NSLocalizedDescriptionKey];
            *outError = [NSError errorWithDomain:KTErrorDomain
                                            code:KT_INVALID_CHAR_ERROR
                                        userInfo:userInfoDict];
        }
        return NO;
    }
    if ([(NSString *)*ioValue lengthOfBytesUsingEncoding:encoding] >= maxLength) {
        if (outError) {
            NSString *errorString = NSLocalizedString(@"Specified string too long", @"");
            NSDictionary *userInfoDict =
            [NSDictionary dictionaryWithObject:errorString
                                        forKey:NSLocalizedDescriptionKey];
            *outError = [NSError errorWithDomain:KTErrorDomain
                                            code:KT_TOO_LONG_ERROR
                                        userInfo:userInfoDict];
        }
        return NO;
    }
    return YES;
}


#define EMPTY()
#define CONCAT(x,y) CONCAT2(x,y)
#define CONCAT2(x,y) x##y
#define STRINGIZE(x) STRINGIZE2(x)
#define STRINGIZE2(x) #x
#define DEFINE_STRING_ACCESSOR_BASE(name,Name,location,length,encoding,before,after) \
- (NSString *)name { \
return getStringFromDataWithEncoding(_tableFileData, NSMakeRange(location, length), encoding); \
} \
- (void)set ## Name:(NSString *)value { \
if (value == nil) value = @""; \
before() \
[self willChangeValueForKey:@"" STRINGIZE(name)]; \
setStringFromDataWithEncoding(_tableFileData, NSMakeRange(location, length), value, encoding); \
[self didChangeValueForKey:@"" STRINGIZE(name)]; \
after() \
} \
- (BOOL)validate##Name:(id *)strValue error:(NSError **)outError { \
return validateFixedString(strValue, outError, encoding, length); \
} \
/**/
#define DEFINE_STRING_ACCESSOR(name,Name,location,length,encoding) \
    DEFINE_STRING_ACCESSOR_BASE(name,Name,location,length,encoding,EMPTY,EMPTY)



@implementation KTRoot

@synthesize rootPath=_rootPath, children=_children,
            tableDirectoryPath=_tableDirectoryPath;

- initWithRootPath:(NSString *)rootPath error:(NSError **)outError {
    self = [super init];
    if (self) {
        BOOL isDirectory = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *tableDirectoryPath
            = [[[rootPath stringByAppendingPathComponent:@"PRIVATE"]
                          stringByAppendingPathComponent:@"DOCOMO"]
                          stringByAppendingPathComponent:@"TABLE"];
        self.tableDirectoryPath = tableDirectoryPath;
        if (![fileManager fileExistsAtPath:tableDirectoryPath isDirectory:&isDirectory]) {
            NSLog(@"Rejecting because the directory %@ didn't exist...", tableDirectoryPath);
            if (outError) {
                *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                code:NSFileReadCorruptFileError
                                            userInfo:[NSDictionary dictionary]];
            }
            [self release];
            return nil;
        }
        if (!isDirectory) {
            NSLog(@"Rejecting because %@ wasn't a directory...", tableDirectoryPath);
            if (outError) {
                *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                code:NSFileReadCorruptFileError
                                            userInfo:[NSDictionary dictionary]];
            }
            [self release];
            return nil;
        }
        self.rootPath = rootPath;
        NSMutableArray *f = [NSMutableArray arrayWithCapacity:10];
#define CAT(name,folderPat,tblPat,fpat,ulfn) \
            [f addObject:[[[KTFolderCategory alloc] \
                            initWithName:name \
                            folderPattern:folderPat \
                            tableFilePattern:tblPat \
                            filePattern:fpat \
                            useLongFileName:ulfn \
                            root:self] autorelease]]
        CAT(@"DCIM",     @"DCIM\\%3dSHARP",                   @"%03dSHARP.TBL",@"DVC0%04d",NO);
        CAT(@"DOCUMENT", @"PRIVATE\\DOCOMO\\DOCUMENT\\PUD%03d", @"PUD%03d.TBL",nil,YES);
        CAT(@"MMFILE",   @"PRIVATE\\DOCOMO\\MMFILE\\MUD%03d",   @"MUD%03d.TBL", @"MMF%04d",NO);
        CAT(@"RINGER",   @"PRIVATE\\DOCOMO\\RINGER\\RUD%03d",   @"RUD%03d.TBL", @"RNG%04d",NO);
        CAT(@"STILL",    @"PRIVATE\\DOCOMO\\STILL\\SUD%03d",    @"SUD%03d.TBL", @"STIL%04d",NO);
        CAT(@"DECO_A_T", @"PRIVATE\\DOCOMO\\DECO_A_T\\DTUD%03d",@"DTUD%03d.TBL",@"DEAT%04d",NO);
        CAT(@"DECOIMG",  @"PRIVATE\\DOCOMO\\DECOIMG\\DUD%03d",  @"DUD%03d.TBL", @"DIMG%04d",NO);
        CAT(@"LCSCLIENT",@"PRIVATE\\DOCOMO\\LCSCLIENT\\LSC%03d",@"LSC%03d.TBL", @"LSCDC%03d",NO);
        CAT(@"OTHER",    @"PRIVATE\\DOCOMO\\OTHER\\OUD%03d",    @"OUD%03d.TBL", @"OTHER%03d",NO);
        CAT(@"SD_VIDEO", @"PRIVATE\\DOCOMO\\SD_VIDEO\\PRL%03d", @"PRL%03d.TBL", @"MOL%04d",NO); // ??
        CAT(@"TORUCA",   @"PRIVATE\\DOCOMO\\TORUCA\\TRC%03d",   @"TRC%03d.TBL", @"TORUC%03d",NO);
#undef CAT
        self.children = f;
    }
    return self;
}

- (void)dealloc {
    [self setRootPath:nil];
    [self setChildren:nil];
    [super dealloc];
}

- (BOOL)isLeaf {
    return NO;
}

@end

@implementation KTFolderCategory

@synthesize root = _root, children = _children, name = _name,
            localizedName = _localizedName, folderPattern = _folderPattern,
            tableFilePattern = _tableFilePattern, filePattern = _filePattern,
            tableDirectoryPath = _tableDirectoryPath,
            useLongFileName=_useLongFileName;

- initWithName:(NSString *)name
        folderPattern:(NSString *)folderPattern
        tableFilePattern:(NSString *)tableFilePattern
        filePattern:(NSString *)filePattern
        useLongFileName:(BOOL)lf
        root:(KTRoot *)root {
    self = [super init];
    if (self) {
        self.root = root;
        self.name = name;
        self.localizedName = NSLocalizedString(name, @"");
        self.folderPattern = folderPattern;
        self.tableFilePattern = tableFilePattern;
        self.filePattern = filePattern;
        self.useLongFileName = lf;
        NSString *tableDirectoryPath
            = [root.tableDirectoryPath stringByAppendingPathComponent:name];
        self.tableDirectoryPath = tableDirectoryPath;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSMutableArray *folders = [NSMutableArray array];
        for (NSString *filename in [fileManager enumeratorAtPath:tableDirectoryPath]) {
            //NSLog(@"Found file %@", filename);
            int len = 0,r;
            if ((r=sscanf([filename UTF8String], [tableFilePattern UTF8String], &len)) != 1) {
                NSLog(@"sscanf fail %d", r);
                continue;
            }
            //if (strlen([filename UTF8String]) != len) {
            //    NSLog(@"length %d", len);
            //    continue;
            //}
            NSString *tablePath = [tableDirectoryPath stringByAppendingPathComponent:filename];
            [folders addObject:[[[KTFolderInfo alloc] initWithTablePath:tablePath parent:self] autorelease]];
        }
        self.children = folders;
    }
    return self;
}
 
- (void)dealloc {
    [self setChildren:nil];
    [self setName:nil];
    [self setFolderPattern:nil];
    [self setTableDirectoryPath:nil];
    [super dealloc];
}

- (BOOL)addFolder:(NSString *)name {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tableFilePath, *folderPath;
    {
        int i = 1;
        do {
            tableFilePath = [self.tableDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:self.tableFilePattern, i]];
            folderPath = [NSString stringWithFormat:self.folderPattern, i];
            ++i;
        } while ([fileManager fileExistsAtPath:tableFilePath]); // should check for the folder's existence?
    }
    KTFolderInfo *info = [[KTFolderInfo alloc] initWithNewFolderAtPath:folderPath
                                                           displayName:name
                                                         tableFilePath:tableFilePath
                                                                parent:self];
    if (!info) {
        return NO;
    }
    [info updateTable];
    self.children = [self.children arrayByAddingObject:[info autorelease]];
    return YES;
}

- (BOOL)isLeaf {
    return NO;
}

- (NSDictionary *)browserValue {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.localizedName, @"name", nil];
}

- (NSString *)description {
    return self.name;
}

@end


@interface KTFolderInfo ()
- (void)loadTableFile;
@end

@implementation KTFolderInfo

@synthesize parent=_parent, children=_children, folderPath=_folderPath,
            tablePath=_tablePath, tableFileHandle=_tableFileHandle;

- initWithTablePath:(NSString *)tablePath parent:(KTFolderCategory *)parent {
    self = [super init];
    if (self) {
        self.parent = parent;
        self.tablePath = tablePath;
        _tableFileHandle = [[NSFileHandle fileHandleForUpdatingAtPath:self.tablePath] retain];
        if (!_tableFileHandle) {
            [self release];
            return nil;
        }
        _tableFileData = [[_tableFileHandle readDataOfLength:512] mutableCopy];
        [self loadTableFile];
        //NSLog(@"KTFolderInfo -init %p", self);
    }
    return self;
}

- initWithNewFolderAtPath:(NSString *)folderPath
              displayName:(NSString *)displayName
            tableFilePath:(NSString *)tablePath
                   parent:(KTFolderCategory *)parent {
    self = [super init];
    if (self) {
        self.parent = parent;
        self.tablePath = tablePath;
        _tableFileData = [[NSMutableData new] initWithLength:512];
        {
            unsigned char *bytes = [_tableFileData mutableBytes];
            bytes[0] = 0x01;
            bytes[1] = 0x00;
            bytes[256] = 0x00;
            bytes[257] = 0x11;
        }
        self.displayName = displayName;
        self.folderPath = folderPath;
        self.children = [NSMutableArray array];
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *folderAbsPath = [self absolutePath];
            if (![fileManager fileExistsAtPath:folderAbsPath]) {
                NSError *error = nil;
                if (![fileManager createDirectoryAtPath:folderAbsPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                    // TODO: handle error
                    NSLog(@"Could not create directory:%@",error);
                    [self release];
                    return nil;
                }
            }
            if (![fileManager createFileAtPath:tablePath
                                      contents:[NSData data]
                                    attributes:nil]) {
                NSLog(@"Could not create table file:%@",tablePath);
                [self release];
                return nil;
            }
        }
        _tableFileHandle = [[NSFileHandle fileHandleForWritingAtPath:tablePath] retain];
        if (!_tableFileHandle) {
            [self release];
            NSLog(@"Could not open table file:%@",tablePath);
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    [self setChildren:nil];
    [self setTablePath:nil];
    if (_tableFileHandle) {
        [_tableFileHandle closeFile];
        [_tableFileHandle release];
        _tableFileHandle = nil;
    }
    if (_tableFileData) {
        [_tableFileData release];
        _tableFileData = nil;
    }
    //NSLog(@"KTFolderInfo -dealloc %p", self);
    [super dealloc];
}

- (NSString *)absolutePath {
    NSArray *components = [self.folderPath componentsSeparatedByString:@"\\"];
    //NSLog(@"KTFolderInfo absolutePath %@ %@", self.folderPath, components);
    return [self.parent.root.rootPath stringByAppendingPathComponent:[NSString pathWithComponents:components]];
}
- (void)loadTableFile {
    uint16_t number_of_files = getUInt16FromData(_tableFileData, NSMakeRange(342,2));
    {
        NSMutableArray *files = [NSMutableArray array];
        for (uint16_t i = 0; i < number_of_files; ++i) {
            off_t offset = 512+i*256;
            [_tableFileHandle seekToFileOffset:offset];
            NSData *data = [_tableFileHandle readDataOfLength:256];
            KTFileInfo *info = [[KTFileInfo alloc] initWithData:data
                                                         parent:self];
            [files addObject:[info autorelease]];
        }
        self.children = files;
    }
}

- (BOOL)checkTable {
    const unsigned char *bytes = [_tableFileData bytes];
    BOOL correctsignature
        = bytes[0] == 0x01
       && bytes[1] == 0x00
       && bytes[256] == 0x00
       && bytes[257] == 0x11;
    return correctsignature;
}

- (void)updateTable {
    if (_filesUpdated) {
        setUInt16FromData(_tableFileData, NSMakeRange(342, 2), [self.children count]);
    }
    [_tableFileHandle seekToFileOffset:0];
    [_tableFileHandle writeData:_tableFileData];
    if (_filesUpdated) {
        for (KTFileInfo *info in self.children) {
            [info updateTable];
        }
        [_tableFileHandle truncateFileAtOffset:512+[self.children count]*256];
        _filesUpdated = NO;
    }
}

- (off_t)offsetForFileInfo:(KTFileInfo *)file {
    NSUInteger idx = [self.children indexOfObject:file];
    if (idx == NSNotFound) {
        NSLog(@"KTFolderInfo(%p,%@) -offsetForFileInfo:%p,%@ file not found", self, self, file, file);
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"The file information passed to KTFolderInfo -offsetForFileInfo: is not a child of this folder"
                               userInfo:nil] raise];
    }
    return 512+idx*256;
}

- (BOOL)fileNameAlreadyUsed:(NSString *)fileName {
    fileName = [fileName stringByDeletingPathExtension];
    for (KTFileInfo *info in self.children) {
        if ([fileName caseInsensitiveCompare:[[info fileName] stringByDeletingPathExtension]] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

- (KTFileInfo *)addFile:(NSString *)path { // TODO: replaceExistingItem:(BOOL)
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName;
    if (self.parent.useLongFileName) {
        fileName = [path lastPathComponent];
        if ([self fileNameAlreadyUsed:fileName]) {
            NSString *basename = [fileName stringByDeletingPathExtension];
            NSString *extension = [fileName pathExtension];
            int i = 1;
            do {
                fileName = [NSString stringWithFormat:@"%@(%d).%@", basename, i, extension];
                ++i;
            } while ([self fileNameAlreadyUsed:fileName]);
        }
    } else {
        int i = 1;
        NSString *extension = [path pathExtension];
        do {
            fileName = [[NSString stringWithFormat:self.parent.filePattern, i] stringByAppendingPathExtension:extension];
            ++i;
        } while ([self fileNameAlreadyUsed:fileName]);
        
    }
    NSString *destPath = [[self absolutePath] stringByAppendingPathComponent:fileName];
    NSError *error = nil;
    if (![fileManager copyItemAtPath:path toPath:destPath error:&error]) {
        return nil;
    }
    KTFileInfo *info = [[KTFileInfo alloc] initWithFileName:fileName originalPath:path parent:self];
    self.children = [self.children arrayByAddingObject:info];
    _filesUpdated = YES;
    [self updateTable];
    return [info autorelease];
}

- (BOOL)removeFile:(KTFileInfo *)file {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![self.children containsObject:file]) {
        return NO;
    }
    if (![fileManager removeItemAtPath:[file absolutePath] error:&error]) {
        return NO;
    }
    self.children = [self.children filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL (id evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != file;
    }]];
    _filesUpdated = YES;
    [self updateTable];
    return YES;
}


- (void)openFolder {
    [[NSWorkspace sharedWorkspace] openFile:[self absolutePath]];
}


// Properties

DEFINE_STRING_ACCESSOR(folderPath, FolderPath, 2, 254, NSASCIIStringEncoding)
DEFINE_STRING_ACCESSOR(deviceName, DeviceName, 384, 32, NSASCIIStringEncoding)
DEFINE_STRING_ACCESSOR_BASE(displayName, DisplayName, 258, 64, NSShiftJISStringEncoding,
                            [self willChangeValueForKey:@"browserValue"]; EMPTY,
                            [self didChangeValueForKey:@"browserValue"]; EMPTY)

- (NSDate *)mtime {
    return getDateFromData(_tableFileData, NSMakeRange(322, 20));
}
- (void)setMtime:(NSDate *)mtime {
    setDateFromData(_tableFileData, NSMakeRange(322, 20), mtime);
}

#define DEFINE_UINT32_ACCESSOR(name,Name,location,length) \
- (NSUInteger)name { \
    return getUInt32FromData(_tableFileData, NSMakeRange(location, length)); \
} \
- (void)set ## Name:(NSUInteger)value { \
    [self willChangeValueForKey:@"" STRINGIZE(name)]; \
    setUInt32FromData(_tableFileData, NSMakeRange(location, length), value); \
    [self didChangeValueForKey:@"" STRINGIZE(name)]; \
}
DEFINE_UINT32_ACCESSOR(unknownValue1,UnknownValue1,416,4)
DEFINE_UINT32_ACCESSOR(unknownValue2,UnknownValue2,420,4)
DEFINE_UINT32_ACCESSOR(unknownValue3,UnknownValue3,424,4)
DEFINE_UINT32_ACCESSOR(unknownValue4,UnknownValue4,428,4)
#undef DEFINE_UINT32_ACCESSOR

- (BOOL)isLeaf {
    return NO;
}

- (NSDictionary *)browserValue {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.displayName, @"name", nil];
}

@end

@implementation KTFileInfo

@synthesize fileName=_fileName, fileSize=_fileSize, parent=_parent;

- (id)initWithData:(NSData *)data parent:(KTFolderInfo *)parent {
    self = [super init];
    if (self) {
        self.parent = parent;
        _tableFileData = [data mutableCopy];
        self.fileSize = getUInt32FromData(data, NSMakeRange(100,4));
        NSString *fileBaseName = getStringFromDataWithEncoding(data, NSMakeRange(3,8), NSASCIIStringEncoding);
        NSString *fileExtension = getStringFromDataWithEncoding(data, NSMakeRange(11,3), NSASCIIStringEncoding);
        if (parent.parent.useLongFileName) {
            self.fileName = getStringFromDataWithEncoding(data, NSMakeRange(160, 64), NSShiftJISStringEncoding);
        } else {
            self.fileName = [NSString stringWithFormat:@"%@.%@", fileBaseName, fileExtension];
        }
    }
    return self;
}

- initWithFileName:(NSString *)fileName originalPath:(NSString *)path parent:(KTFolderInfo *)parent {
    self = [super init];
    if (self) {
        self.parent = parent;
        _tableFileData = [[NSMutableData new] initWithLength:256];
        {
            unsigned char *bytes = [_tableFileData mutableBytes];
            bytes[0] = 0x01;
            bytes[1] = 0x00;
            bytes[2] = 0x01;
            bytes[14] = 0x00;
            bytes[15] = 0x11;
        }
        self.displayName = [path lastPathComponent];
        self.fileName = fileName;
        NSString *fileExtension = [fileName pathExtension];
        setStringFromDataWithEncoding(_tableFileData, NSMakeRange(11,3), fileExtension, NSASCIIStringEncoding);
        if (parent.parent.useLongFileName) {
            setStringFromDataWithEncoding(_tableFileData, NSMakeRange(160, 64), self.fileName, NSShiftJISStringEncoding);
        } else {
            NSString *fileBaseName = [fileName stringByDeletingPathExtension];
            setStringFromDataWithEncoding(_tableFileData, NSMakeRange(3,8), fileBaseName, NSASCIIStringEncoding);
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:path error:nil];
        self.mtime = [fileAttr objectForKey:NSFileModificationDate];
        unsigned long long fileSize = [[fileAttr objectForKey:NSFileSize] unsignedLongLongValue];
        if (fileSize >= 1ll<<32) {
            // file too large
            [self release];
            return nil;
        }
        self.fileSize = fileSize;
        self.deviceName = @"";
        self.comment = @"";
        self.rating = 3;
        self.viewCount = 0;
    }
    return self;
}

- (void)dealloc {
    [self setFileName:nil];
    if (_tableFileData) {
        [_tableFileData release];
        _tableFileData = nil;
    }
    [super dealloc];
}

- (NSString *)absolutePath {
    return [[self.parent absolutePath] stringByAppendingPathComponent:self.fileName];
}

- (NSImage *)fileIcon {
    return [[NSWorkspace sharedWorkspace] iconForFile:[self absolutePath]];
}

- (BOOL)checkTable {
    const unsigned char *bytes = [_tableFileData bytes];
    BOOL correctsignature
        = bytes[0] == 0x01
       && bytes[1] == 0x00
       && bytes[2] == 0x01
       && bytes[14] == 0x00
       && bytes[15] == 0x11;
    return correctsignature;
}

- (void)updateTable {
    [self.parent.tableFileHandle seekToFileOffset:[self.parent offsetForFileInfo:self]];
    [self.parent.tableFileHandle writeData:_tableFileData];
}

- (void)openFile {
    [[NSWorkspace sharedWorkspace] openFile:[self absolutePath]];
}


// Properties
DEFINE_STRING_ACCESSOR(deviceName, DeviceName, 128, 32, NSASCIIStringEncoding)
DEFINE_STRING_ACCESSOR_BASE(displayName, DisplayName, 16, 64, NSShiftJISStringEncoding,
                            [self willChangeValueForKey:@"browserValue"]; EMPTY,
                            [self didChangeValueForKey:@"browserValue"]; EMPTY)
DEFINE_STRING_ACCESSOR(comment, Comment, self.parent.parent.useLongFileName ? 160+64 : 160, 29, NSShiftJISStringEncoding)

- (NSDate *)mtime {
    return getDateFromData(_tableFileData, NSMakeRange(80, 20));
}
- (void)setMtime:(NSDate *)mtime {
    [self willChangeValueForKey:@"mtime"];
    setDateFromData(_tableFileData, NSMakeRange(80, 20), mtime);
    [self didChangeValueForKey:@"mtime"];
}

- (int)rating {
    return getUInt8FromData(_tableFileData, NSMakeRange(self.parent.parent.useLongFileName ? 189+64 : 189,1));
}
- (void)setRating:(int)rating {
    if (rating < 1) rating = 1;
    if (rating > 6) rating = 6;
    [self willChangeValueForKey:@"rating"];
    setUInt8FromData(_tableFileData, NSMakeRange(self.parent.parent.useLongFileName ? 189+64 : 189,1), rating);
    [self didChangeValueForKey:@"rating"];
}
- (BOOL)validateRating:(id *)ioValue error:(NSError **)outError {
    if (*ioValue == nil) {
        return YES;
    } else if ([*ioValue intValue] < 1 || [*ioValue intValue] > 6) {
        if (outError) {
            NSString *errorString = @"Value out of range";
            NSDictionary *userInfoDict =
                [NSDictionary dictionaryWithObject:errorString
                                            forKey:NSLocalizedDescriptionKey];
            *outError = [NSError errorWithDomain:KTErrorDomain
                                            code:KT_OUT_OF_RANGE
                                        userInfo:userInfoDict];
        }
        return NO;
    }
    return YES;
}


- (int)viewCount {
    return getUInt16FromData(_tableFileData, NSMakeRange(self.parent.parent.useLongFileName ? 190+64 : 190,2));
}
- (void)setViewCount:(int)viewCount {
    if (viewCount < 0) viewCount = 0;
    if (viewCount > 999) viewCount = 999;
    [self willChangeValueForKey:@"viewCount"];
    setUInt16FromData(_tableFileData, NSMakeRange(self.parent.parent.useLongFileName ? 190+64 : 190,2), viewCount);
    [self didChangeValueForKey:@"viewCount"];
}

- (BOOL)validateViewCount:(id *)ioValue error:(NSError **)outError {
    if (*ioValue == nil) {
        return YES;
    } else if ([*ioValue intValue] < 0 || [*ioValue intValue] > 999) {
        if (outError) {
            NSString *errorString = @"Value out of range";
            NSDictionary *userInfoDict =
                [NSDictionary dictionaryWithObject:errorString
                                            forKey:NSLocalizedDescriptionKey];
            *outError = [NSError errorWithDomain:KTErrorDomain
                                            code:KT_OUT_OF_RANGE
                                        userInfo:userInfoDict];
        }
        return NO;
    }
    return YES;
}

- (BOOL)isLeaf {
    return YES;
}

- (NSDictionary *)browserValue {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.displayName, @"name", [self fileIcon], @"icon", nil];
}


@end


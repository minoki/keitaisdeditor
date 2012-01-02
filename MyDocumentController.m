//
//  MyDocumentController.m
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 18/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDocumentController.h"


@implementation MyDocumentController

- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)types {
    [openPanel setCanChooseDirectories:YES];
    return [super runModalOpenPanel:openPanel forTypes:types];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self openDocument:self];
}

- (void)removeDocument:(NSDocument *)document {
    NSLog(@"MyDocumentController -removeDocument:%p", document);
    [super removeDocument:document];
}

@end

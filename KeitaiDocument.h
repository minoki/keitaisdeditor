//
//  KeitaiDocument.h
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 17/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KTRoot;
@class FolderInfoPanelController, FileInfoPanelController;

@interface KeitaiDocument : NSDocument {
    IBOutlet FolderInfoPanelController *folderInfoPanel;
    IBOutlet FileInfoPanelController *fileInfoPanel;
}

@property(retain) KTRoot *root;

- (IBAction)newFolder:(id)sender;
- (IBAction)removeFolder:(id)sender;
- (IBAction)addFile:(id)sender;
- (IBAction)removeFile:(id)sender;

@end

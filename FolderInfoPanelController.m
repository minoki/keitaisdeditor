//
//  FolderInfoPanelController.m
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 20/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FolderInfoPanelController.h"
#import "FolderInfo.h"

@implementation FolderInfoPanelController

@synthesize selectedFolderInfo;

- (void)showFolderInfoPanel:(KTFolderInfo *)folderInfo {
    //NSLog(@"showFolderInfoPanel:");
    self.selectedFolderInfo = folderInfo;
    [rightPane addSubview:panel];
    [panel setFrame:[rightPane bounds]];
}
- (void)hideFolderInfoPanel {
    if ([panel superview] == rightPane) {
        [panel removeFromSuperview];
    }
    self.selectedFolderInfo = nil;
}


- (IBAction)revertToSaved:(id)sender {
}
- (IBAction)applyChanges:(id)sender {
    if (self.selectedFolderInfo != nil) {
        [self.selectedFolderInfo updateTable];
    }
}
- (IBAction)open:(id)sender {
    if (self.selectedFolderInfo != nil) {
        [self.selectedFolderInfo openFolder];
    }
}

@end


@implementation FileInfoPanelController

@synthesize selectedFileInfo;

- (void)showFileInfoPanel:(KTFileInfo *)fileInfo {
    //NSLog(@"showFileInfoPanel:");
    self.selectedFileInfo = fileInfo;
    [rightPane addSubview:panel];
    [panel setFrame:[rightPane bounds]];
}
- (void)hideFileInfoPanel {
    if ([panel superview] == rightPane) {
        [panel removeFromSuperview];
    }
    self.selectedFileInfo = nil;
}


- (IBAction)revertToSaved:(id)sender {
}
- (IBAction)applyChanges:(id)sender {
    if (self.selectedFileInfo != nil) {
        [self.selectedFileInfo updateTable];
    }
}
- (IBAction)open:(id)sender {
    if (self.selectedFileInfo != nil) {
        [self.selectedFileInfo openFile];
    }
}

@end

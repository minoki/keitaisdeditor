//
//  FolderInfoPanelController.m
//  keitaisdeditor
//
//  Created by 荒田 実樹 on 20/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FolderInfoPanelController.h"
#import "FolderInfo.h"
#import "KeitaiDocument.h"

@implementation FolderInfoPanelController

@synthesize selectedFolderInfo;

- (void)awakeFromNib {
    [document addObserver:self
               forKeyPath:@"selectedItem"
                  options:NSKeyValueObservingOptionNew
                          |NSKeyValueObservingOptionOld
                          |NSKeyValueObservingOptionInitial
                  context:NULL];
}

- (void)dealloc {
    [document removeObserver:self forKeyPath:@"selectedItem"];
    [super dealloc];
}

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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"selectedItem"]) {
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if ([oldValue isKindOfClass:[KTFolderInfo class]]) {
            [self hideFolderInfoPanel];
        }
        if ([newValue isKindOfClass:[KTFolderInfo class]]) {
            [self showFolderInfoPanel:newValue];
        }
    }
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

- (void)awakeFromNib {
    [document addObserver:self
               forKeyPath:@"selectedItem"
                  options:NSKeyValueObservingOptionNew
                          |NSKeyValueObservingOptionOld
                          |NSKeyValueObservingOptionInitial
                  context:NULL];
}

- (void)dealloc {
    [document removeObserver:self forKeyPath:@"selectedItem"];
    [super dealloc];
}


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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"selectedItem"]) {
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if ([oldValue isKindOfClass:[KTFileInfo class]]) {
            [self hideFileInfoPanel];
        }
        if ([newValue isKindOfClass:[KTFileInfo class]]) {
            [self showFileInfoPanel:newValue];
        }
    }
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

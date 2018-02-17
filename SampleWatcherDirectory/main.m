//
//  main.m
//  SampleWatcherDirectory
//
//  Created by Roberto Abreu on 2/16/18.
//  Copyright © 2018 homeappzz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/event.h>

void handleErrorWithMessage(const char *message, int kq);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
        if (argc <= 1) {
            NSLog(@"Needs to set directory or files to monitor");
        }
        
        int kq = kqueue();
        if (kq == -1) {
            handleErrorWithMessage("Error to create kqueue", kq);
        }
        
        for (int i = 1; i < argc; i++) {
            const char *directoryOrFileName = argv[i];
            
            int fileDescriptor = open(directoryOrFileName, O_RDONLY);
            if (fileDescriptor == -1) {
                NSLog(@"Failed to open file or directory %s", directoryOrFileName);
                continue;
            }
            
            struct kevent event;
            EV_SET(&event, fileDescriptor, EVFILT_VNODE, EV_ADD | EV_ENABLE | EV_CLEAR, NOTE_WRITE, 0, (void *)directoryOrFileName);
            
            if (kevent(kq, &event, 1, NULL, 0, NULL) == -1) {
                NSLog(@"Failure to add kevent for file or directory %s", directoryOrFileName);
                continue;
            }
            NSLog(@"Start watching %s", directoryOrFileName);
        }
        
        for (;;) {
            struct kevent event;
            if (kevent(kq, NULL, 0, &event, 1, NULL) == -1) {
                handleErrorWithMessage("An error has ocurred while processing event", kq);
            }
            NSLog(@"File or directory %s has changed", (char *)event.udata);
        }
    }
    
    return 0;
}

void handleErrorWithMessage(const char *message, int kq) {
    close(kq);
    NSLog(@"%s", message);
    exit(EXIT_FAILURE);
}

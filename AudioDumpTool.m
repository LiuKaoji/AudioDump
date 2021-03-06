//
//  AudioDumpTool.m
//  AudioDumpTool
//
//  Created by kaoji on 2021/1/29.
//  Copyright © 2021 Kaoji. All rights reserved.
//


#import "AudioDumpTool.h"

static AudioDumpTool *_instance;

@interface AudioDumpTool (){
    FILE *_captureAudioDumpFile; // 保存采集的音频数据
    FILE *_mixAudioDumpFile;// SDK混音处理后的数据
    BOOL _isStart;
}
@end

@implementation AudioDumpTool

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[AudioDumpTool alloc] initPrivate];
    });
    return _instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (nil != self) {
    
        _isStart = NO;
    }
    return self;
}

- (void)start{
    
    if (_isStart) {
        return;
    }
    
    char *captureFileName = "capture_dump.pcm";
    NSString* systemDocumentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* filePath = [NSString stringWithFormat:@"%@/%s", systemDocumentPath, captureFileName];
    _captureAudioDumpFile = fopen([filePath UTF8String], "wb");
    
    char *mixFileName = "process_dump.pcm";
    systemDocumentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    filePath = [NSString stringWithFormat:@"%@/%s", systemDocumentPath, mixFileName];
    _mixAudioDumpFile = fopen([filePath UTF8String], "wb");
    
    _isStart = YES;
}

- (void)stop{
    
    if (!_isStart) {
        return;
    }
    
    _isStart = NO;
    
    fclose(_captureAudioDumpFile);
    fclose(_mixAudioDumpFile);
}

/// 采集到的数据
- (void)dumpCaptureData:(TRTCAudioFrame *)frame{
    if (!_isStart) {
        return;
    }
    fwrite(frame.data.bytes, 1, frame.data.length, _captureAudioDumpFile);
}

/// SDK处理后的数据
- (void)dumpProcessedData:(TRTCAudioFrame *)frame{
    if (!_isStart) {
        return;
    }
    fwrite(frame.data.bytes, 1, frame.data.length, _mixAudioDumpFile);
}

@end

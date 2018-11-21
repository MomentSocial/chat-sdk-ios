//
//  BAudioMessageCell.h
//  Pods
//
//  Created by Simon Smiley-Andrews on 06/08/2015.
//
//

#import <ChatSDK/BMessageCell.h>

#define bAudioMessageCell @"AudioMessageCell"

typedef enum {
    bAudioTypePlaying,
    bAudioTypePaused,
    bAudioTypeStopped,
    bAudioTypeInactive,
} bAudioType;

// TODO: Check which of these are needed when we merge in
@interface BAudioMessageCell : BMessageCell {
    
    UIButton * _playButton;
    UIImageView * _soundWaveImageView;
    UILabel * _audioLengthLabel;
    UILabel * _currentTimeLabel;

    NSTimer * _audioTimer;
    NSInteger _audioTime;
    
    bAudioType _audioType;
    BOOL _playing;
    BOOL _isMine;
}

@property (nonatomic, readwrite) UIImageView * imageView;

@end



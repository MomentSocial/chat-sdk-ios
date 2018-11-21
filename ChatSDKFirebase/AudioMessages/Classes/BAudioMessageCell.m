//
//  BAudioMessageCell.m
//  Pods
//
//  Created by Simon Smiley-Andrews on 06/08/2015.
//
//

#import "BAudioMessageCell.h"

#import <ChatSDK/Core.h>
#import <ChatSDK/UI.h>

@implementation BAudioMessageCell

@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        imageView = [[UIImageView alloc] init];
        imageView.layer.cornerRadius = 10;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = NO;
        
        // TODO: Is this necessary?
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self.bubbleImageView addSubview:imageView];
    }
    return self;
}

-(void) setMessage: (id<PElmMessage>) message withColorWeight: (float) colorWeight {
    [super setMessage:message withColorWeight: colorWeight];
    
    // When we load the cells they are not playing
    _audioType = bAudioTypeStopped;
    
    _isMine = [message.userModel isEqual:NM.currentUser];
    
    [self refreshCell];
}

- (void)refreshCell {
    
    // If _playButton hasn't been added
    if (![_playButton superview]) {
        
        _playButton = [[UIButton alloc] init];
        _playButton.backgroundColor = [UIColor lightGrayColor];
        _playButton.layer.cornerRadius = 10;
        
        [_playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bubbleImageView addSubview:_playButton];
        
        _playButton.keepHeight.equal = 50;
        _playButton.keepWidth.equal = 50;
        _playButton.keepBottomInset.equal = 3;
        _playButton.keepLeftInset.equal = _isMine ? 3 : 8;
    }
    
    // Make sure user interaction is always enabled
    _playButton.userInteractionEnabled = YES;
    
    // If we have a resource path it means we have already downloaded the audio
    [_playButton setBackgroundImage:[NSBundle uiImageNamed:@"icn_play.png"] forState:UIControlStateNormal];
    
    // We have access to the audio url here
    NSString * totalSeconds = [self.message.textString componentsSeparatedByString:@","].lastObject;
    
    // Get the time in the format m:ss
    CGFloat totalMinutes = totalSeconds.floatValue / 60;
    CGFloat remainingSeconds = totalSeconds.integerValue % 60;
    
    if (![_audioLengthLabel superview]) {
        
        _audioLengthLabel = [[UILabel alloc] init];
        _audioLengthLabel.textColor = [UIColor blackColor];
        _audioLengthLabel.textAlignment = NSTextAlignmentRight;
        [_audioLengthLabel setFont:[UIFont systemFontOfSize:12]];
        
        [self.bubbleImageView addSubview:_audioLengthLabel];
        
        _audioLengthLabel.keepHeight.equal = 15;
        _audioLengthLabel.keepWidth.equal = 50;
        _audioLengthLabel.keepBottomInset.equal = 3;
        _audioLengthLabel.keepRightInset.equal = _isMine ? 15 : 7;
    }
    
    _audioLengthLabel.text = [NSString stringWithFormat:@"%.0f:%02.0f", totalMinutes, remainingSeconds];
    
    if (![_currentTimeLabel superview]) {
        
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.text = @"0:00";
        _currentTimeLabel.textColor = [UIColor blackColor];
        _currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        [_currentTimeLabel setFont:[UIFont systemFontOfSize:12]];
        
        [self.bubbleImageView addSubview:_currentTimeLabel];
        
        _currentTimeLabel.keepHeight.equal = 15;
        _currentTimeLabel.keepWidth.equal = 50;
        _currentTimeLabel.keepBottomInset.equal = 3;
        _currentTimeLabel.keepLeftInset.equal = _isMine ? 56 : 61;
    }
    
    if (![_soundWaveImageView superview]) {
        
        _soundWaveImageView = [[UIImageView alloc] initWithImage:[NSBundle uiImageNamed:@"sound-wave.png"]];
        _soundWaveImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.bubbleImageView addSubview:_soundWaveImageView];
        
        _soundWaveImageView.keepHeight.equal = 50;
        _soundWaveImageView.keepBottomInset.equal = 3;
        _soundWaveImageView.keepLeftOffsetTo(_playButton).equal = 3;
        _soundWaveImageView.keepRightInset.equal = 3;
    }
    
    //    [self.bubbleImageView bringSubviewToFront:_audioLengthLabel];
    //    [self.bubbleImageView bringSubviewToFront:_currentTimeLabel];
    
    _audioLengthLabel.hidden = ![self.message.delivered boolValue];
    _currentTimeLabel.hidden = ![self.message.delivered boolValue];
    
    self.bubbleImageView.alpha = [self.message.delivered boolValue] ? 1 : 0.75;
    
    // When a message is recieved we increase the messages tab number
    [[NSNotificationCenter defaultCenter] addObserverForName:bStopAudioNotification object:Nil queue:Nil usingBlock:^(NSNotification * notification) {
        
        [_playButton setBackgroundImage:[NSBundle uiImageNamed:@"icn_play.png"] forState:UIControlStateNormal];
        _audioType = bAudioTypeStopped;
        _playing = NO;
        
        [self resetTimer];
    }];
}

// When we press play first we check if the audio is playing - if it is we pause it
// If it isn't playing it either means the audio has stopped or it is paused
// If it is stopped it means we want to stop the audio as obviously another cell has been pressed
// If it is paused we only pause the audio as we might want to continue
- (void)playButtonPressed {
    // Only enable the play button if the audio message has been delivered
    if ([self.message.delivered boolValue]) {
        
        // If the audio is currently playing
        if (_audioType == bAudioTypePlaying) {
            
            [[BAudioManager sharedManager] pauseAudio];
            [_playButton setBackgroundImage:[NSBundle uiImageNamed:@"icn_play.png"] forState:UIControlStateNormal];
            _audioType = bAudioTypePaused;
            
            [self stopTimer];
        }
        else {
            
            if (_audioType == bAudioTypeStopped) {
                [[BAudioManager sharedManager] stopAudio];
            }
            
            [_playButton setBackgroundImage:[NSBundle uiImageNamed:@"icn_pause.png"] forState:UIControlStateNormal];
            
            NSString * audioURL = [self.message.textString componentsSeparatedByString:@","].firstObject;
            [[BAudioManager sharedManager] playAudioWithURL:audioURL percent:0];
            
            _audioType = bAudioTypePlaying;
            
            [self startTimer];
        }
    }
}

-(UIView *) cellContentView {
    return imageView;
}

- (void)startTimer {
    
    _audioTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(increaseTime:) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    
    [_audioTimer invalidate];
}

-(void) increaseTime:(NSTimer *)timer {
    
    NSInteger time = [[BAudioManager sharedManager] getTotalTimeInSeconds]; //TODO: check this or this getCurrentTimeInSeconds
    
    CGFloat totalMinutes = time / 60;
    CGFloat remainingSeconds = time % 60;
    
    _currentTimeLabel.text = [NSString stringWithFormat:@"%.0f:%02.0f", totalMinutes, remainingSeconds];
}

- (void)resetTimer {
    [_audioTimer invalidate];
    _currentTimeLabel.text = @"0:00";
}

@end

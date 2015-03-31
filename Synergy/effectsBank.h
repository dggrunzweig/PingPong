//
//  effectsBank.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "echoEffect.h"
#import "reverbEffect.h"
#import "lfo.h"
#import "filter.h"
#import "EffectBankSettingManager.h"

enum effectTypes
{
    kSequencerModule = 0,
    kFunctionGenerator = 1,
    kFilterModule = 2,
    kEchoEffect = 3,
    kPhaserEffect = 4,
    kReverbEffect = 5,
} ;

@interface effectsBank : NSObject
{
    EffectBankSettingManager mManager;
    echoEffect echo;
    reverbEffect reverb;
    filter filterModule;
    
    float * mFloatMonoBuffer;
    float * mFloatStereoBuffer;
    int mNumFrames;
    int mNumChannels;
    int mCurrentPreset;
    
    AudioBufferList mIncomingAudio;
}



+ (id)sharedEffectsBank;

- (void) initialize:(UInt32)numFrames withSampleRate:(UInt32)sampleRate numChannels:(UInt32)channels;
- (void) appendBufferDataToABL:(NSData*)data;
- (void) sendSignalThroughBank:(SInt16*)buffer;



@end

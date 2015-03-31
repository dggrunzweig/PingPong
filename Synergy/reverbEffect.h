//
//  reverbEffect.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#ifndef __UWantBProducer__reverbEffect__
#define __UWantBProducer__reverbEffect__

#include <stdio.h>
#include "echoEffect.h"
enum {
    kReverbEffectDecayTime = 0,
    kReverbEffectMix = 1,
    kReverbEffectFeedback = 2,
} reverbEffectParas;

class reverbEffect
{
    echoEffect mEcho;
    int mSampleRate;
    int mReverbTimeSamples;
    int mNumFrames;
public:
    void initialize(int sampleRate, int numFrames, int reverbTimeMS, float mix);
    void applyEffect(float * buffer);
    void setEffectParameter(UInt32 parameter, float value);

};

#endif /* defined(__UWantBProducer__reverbEffect__) */

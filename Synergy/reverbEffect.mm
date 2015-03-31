//
//  reverbEffect.cpp
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#include "reverbEffect.h"


void reverbEffect::initialize(int sampleRate, int numFrames, int reverbTimeMS, float mix)
{
    mSampleRate =sampleRate;
    mNumFrames = numFrames;
    mReverbTimeSamples = ((float)reverbTimeMS/1000.0f) * sampleRate;
    mEcho.initialize(numFrames, reverbTimeMS, .85, sampleRate);
}
void reverbEffect::applyEffect(float * buffer)
{
    mEcho.applyEffect(buffer);
}


void reverbEffect::setEffectParameter(UInt32 parameter, float value)
{
    if (parameter == kReverbEffectDecayTime)
    {
        mEcho.setEffectParameters(kEchoEffectTimeInMS, value);
    }
    else if (parameter == kReverbEffectFeedback)
    {
        mEcho.setEffectParameters(kEchoEffectFeedback, value);
    }
    else if (parameter == kReverbEffectMix)
    {
        mEcho.setEffectParameters(kEchoEffectMix, value);
    }
}

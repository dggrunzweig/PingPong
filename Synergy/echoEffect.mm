//
//  delayEffect.cpp
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#include "echoEffect.h"


void echoEffect::initialize(int numFrames, int timeinMS, float feedback, int sampleRate)
{
    mSampleRate = sampleRate;
    mNumFrames = numFrames;
    mMaxDelayLength = 1000;; //one second
    mTimeinSamples = ((float)timeinMS/1000.0) * sampleRate;
    mFeedback = feedback > 1? 1: feedback;
    mDelayBuffer = (float*)malloc((numFrames+((float)mMaxDelayLength/1000.0f * mSampleRate))*sizeof(float));
    memset(mDelayBuffer, 0, numFrames+((float)mMaxDelayLength/1000.0f * mSampleRate));
    mReadIndex = 0;
    mNumFrames = numFrames;
}

void echoEffect::applyEffect(float * buffer)
{
    float dryMix = 1-mWetDryMix;
    //grab the last buffer mNumFrames of the LIFO buffer
    int j = 0;
    for (int i = 0; i < mNumFrames; i++)
    {
        j = (mReadIndex+i) % (mNumFrames+mTimeinSamples);
        mDelayBuffer[(j+mTimeinSamples) % (mNumFrames+mTimeinSamples)] = mFeedback*buffer[i];
        buffer[i] = buffer[i]*dryMix+mDelayBuffer[j]*mWetDryMix;
    }
    if (mReadIndex+mNumFrames > INT_MAX)
    {
        mReadIndex = mReadIndex - INT_MAX;
    }
    mReadIndex = mReadIndex+mNumFrames;
}

void echoEffect::getEffectParameter(int effectParameterID, float value)
{
    
    
}

void echoEffect::setEffectParameters(UInt32 parameter, float value)
{
    if (parameter == kEchoEffectTimeInMS)
    {
//        float tempBuffer[mNumFrames+mTimeinSamples];
//        cblas_scopy(mNumFrames+mTimeinSamples, mDelayBuffer, 1, tempBuffer, 1);
        mTimeinSamples = (mMaxDelayLength*value)/1000.0 * mSampleRate;
        float winsize = 4;
        vDSP_vswsum(mDelayBuffer, 1, mDelayBuffer, 1, mMaxDelayLength+mNumFrames, winsize);
        vDSP_vsdiv(mDelayBuffer, 1, &winsize, mDelayBuffer, 1, mNumFrames+mMaxDelayLength);
        
//        float min = old < mNumFrames+mTimeinSamples? old:  mNumFrames+mTimeinSamples;
//        for (int i = 0; i < min; i++)
//        {
//            mDelayBuffer[(i+mReadIndex) % (mNumFrames+mTimeinSamples)] = tempBuffer[(i+mReadIndex) % old];
//        }
//        
    } else if (parameter == kEchoEffectFeedback)
    {
        mFeedback = value;
    } else if (parameter == kEchoEffectMix)
    {
        mWetDryMix = value;
    }
    
}



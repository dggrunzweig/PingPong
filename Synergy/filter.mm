//
//  filter.cpp
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#include "filter.h"

void filter::initialize(int numFrames, int sampleRate, int cutoffFrequency, bool LFOon)
{
    mNumFrames = numFrames;
    mSampleRate = sampleRate;
    mCutOffFrequency = cutoffFrequency;
    mLFO.initialize(1, 1, sampleRate, numFrames);
    mLFOon = LFOon;
    modulationBuffer = (float*)malloc(sizeof(float)*numFrames);
    isLowPass = true;
    biquadFilter.initialize(numFrames);
    mResonance = 1;
    biquadFilter.createFilter(cutoffFrequency, sampleRate, mResonance, 0.0, 0.0, 10, kBiQuadLowPassFilter, kUseButtersworthFilter);
}

void filter::setLFOStatus(float modDepth, float modRate, bool On)
{
    mLFO.mModDepth = modDepth;
    mLFO.mModRate = modRate;
    mLFOon = On;
}

void filter::setEffectParameter(UInt32 parameter, float value)
{
    if (parameter == kSetCutOffFrequency)
    {
        mCutOffFrequency = value*500+50;
        if (isLowPass)
            biquadFilter.createFilter(mCutOffFrequency, mSampleRate, mResonance, 0.0, 0.0, 10, kBiQuadLowPassFilter, kUseButtersworthFilter);
        else
            biquadFilter.createFilter(mCutOffFrequency, mSampleRate, mResonance, 0.0, 0.0, 10, kBiQuadHighPassFilter, kUseButtersworthFilter);
    }
    else if (parameter == kSetFilterType)
    {
        if (value == kUseHighPass)
        {
            isLowPass = false;
            biquadFilter.isLowPass = false;
            biquadFilter.createFilter(mCutOffFrequency, mSampleRate, mResonance, 0.0, 0.0, 10, kBiQuadHighPassFilter, kUseButtersworthFilter);
        }
        else if (value == kUseLowPass)
        {
            biquadFilter.isLowPass = true;
            isLowPass = true;
            biquadFilter.createFilter(mCutOffFrequency, mSampleRate, mResonance, 0.0, 0.0, 10, kBiQuadLowPassFilter, kUseButtersworthFilter);

        }
    }
    else if (parameter == kSetResonanceFrequency)
    {
        mResonance = (9*value)+1;
        if (isLowPass)
            biquadFilter.createFilter(mCutOffFrequency, mSampleRate, mResonance, 0.0, 0.0, 10, kBiQuadLowPassFilter, kUseButtersworthFilter);
        else
            biquadFilter.createFilter(mCutOffFrequency, mSampleRate, mResonance, 0.0, 0.0, 10, kBiQuadHighPassFilter, kUseButtersworthFilter);
    }
    else if (parameter == kSetLFORate)
    {
        setLFOStatus(50.0, 25*value, YES);
    }
    else
    {
        NSLog(@"Unrecognized parameter");
    }
}

void filter::getEffectParameter(int effectParameterID, float value)
{
    
}


void filter::applyEffect(float * buffer)
{
    if (mLFOon)
    {
        mLFO.getModulationBuffer(modulationBuffer);
        //freq cutoff serves as center point
        biquadFilter.filterWithLFO(buffer, modulationBuffer, mNumFrames);
    } else {
        //only use freq cut off
        biquadFilter.filterBuffer(buffer, mNumFrames);

    }
}
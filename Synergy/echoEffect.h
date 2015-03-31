//
//  delayEffect.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#ifndef __UWantBProducer__delayEffect__
#define __UWantBProducer__delayEffect__

#include <stdio.h>
#import "effectSuperClass.h"

enum echoEffectParameters
{
    kEchoEffectFeedback = 0, //a float value equal to the feedback amount between 0 and 1;
    kEchoEffectTimeInMS = 1, //A int value equal to the time in milliseconds
    kEchoEffectMix = 2,
};

class echoEffect: public effectSuperClass
{
private:
    int mTimeinSamples; //the time in samples of the delay
    float mFeedback; //between 0 and 1, represents how much each repeat is multiplied by, greater than 1 creates feedback
    float * mDelayBuffer;
    float * mtempOutputBuffer;
    int mNumFrames;
    int mReadIndex;
    int mSampleRate;
    int mMaxDelayLength;
public:
    
    void initialize(int numFrames, int timeinMS, float feedback, int sampleRate);
    void applyEffect(float * buffer);
    void setEffectParameters(UInt32 parameter, float value);
    void getEffectParameter(int effectParameterID, float value);

};

#endif /* defined(__UWantBProducer__delayEffect__) */

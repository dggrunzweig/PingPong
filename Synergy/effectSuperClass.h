//
//  Header.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/3/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#ifndef UWantBProducer_Header_h
#define UWantBProducer_Header_h

#import <Accelerate/Accelerate.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>



class effectSuperClass
{
public:
    float mWetDryMix; // between 0 and 1, represents the mix of the effect
    void setWetDryMix(float mix){ mWetDryMix = mix; };
};

#endif

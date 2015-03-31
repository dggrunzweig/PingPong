//
//  EffectBankSettingManager.h
//  UWantBProducer
//
//  Created by David Grunzweig on 2/10/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#ifndef __UWantBProducer__EffectBankSettingManager__
#define __UWantBProducer__EffectBankSettingManager__

#include <stdio.h>
#import <Foundation/Foundation.h>

enum effectBankSettings
{
    kEffectBankDubstepPreset = 0,
    kEffectBankAcidPreset = 1,
    kEffectBankTrancePreset = 2,
    kEffectBankSubbass = 3,
    kEffectBankFreeMode = 4,
};
class EffectBankSettingManager
{
private:
    float ** presets;
    float * currentSettings;
    int mCurrentPreset;
public:
    void loadPreset(int preset);
    void initialize();
    BOOL checkSettingOfCurrentPreset(int effectID, int effectParameter, float value);
    float getCurrentSetting(int effectID, int effectParameter);
    void resetCurrentSettings();
};

#endif /* defined(__UWantBProducer__EffectBankSettingManager__) */

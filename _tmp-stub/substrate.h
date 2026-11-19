// 桩：CydiaSubstrate 接口。
#pragma once
#import <Foundation/Foundation.h>

void MSHookMessageEx(Class cls, SEL sel, IMP imp, IMP *result);
void MSHookFunction(void *symbol, void *replace, void **result);

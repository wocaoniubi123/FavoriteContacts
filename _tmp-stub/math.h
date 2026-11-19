#pragma once
#define HUGE_VALF __builtin_huge_valf()
#define HUGE_VAL __builtin_huge_val()
#define INFINITY __builtin_inff()
#define NAN __builtin_nanf("")
static inline float roundf(float x) { return __builtin_roundf(x); }
static inline double round(double x) { return __builtin_round(x); }
static inline float fabsf(float x) { return __builtin_fabsf(x); }
static inline double fabs(double x) { return __builtin_fabs(x); }
static inline float floorf(float x) { return __builtin_floorf(x); }
static inline float ceilf(float x) { return __builtin_ceilf(x); }

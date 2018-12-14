#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GTCGCommonMacro.h"
#import "GTCommonMacro.h"
#import "GTFunctionCommonMacro.h"
#import "GTMacros.h"
#import "GTSystemCommonMacro.h"

FOUNDATION_EXPORT double GTMacrosVersionNumber;
FOUNDATION_EXPORT const unsigned char GTMacrosVersionString[];


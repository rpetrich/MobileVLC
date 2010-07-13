//
//  MobileVLC.h
//  MobileVLC
//
//  Created by Romain Goyet on 13/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#ifdef DEBUG
#define MVLCLog(format, ...) NSLog(format, ## __VA_ARGS__)
#define MVLCAssert(format, ...) NSAssert(format, ## __VA_ARGS__)
#define MVLCIgnoreUnusedParameter(parameter) (void)parameter;
#else
#define MVLCLog(format, ...)
#define MVLCAssert(format, ...)
#define MVLCIgnoreUnusedParameter(parameter)
#endif

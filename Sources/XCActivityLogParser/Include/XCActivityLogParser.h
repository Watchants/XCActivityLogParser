//
//  XCActivityLogParser.h
//  XCActivityLogParser
//
//  Created by tiger on 9/19/20.
//

#ifndef XCACTIVITYLOG_H
#define XCACTIVITYLOG_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <stdbool.h>

#include "XCActivityLogToken.h"

typedef struct XCActivityLogParser {
    const void * lexer;
    const void * iterator;
};

typedef const struct XCActivityLogParser * XCActivityLogParserRef;

extern XCActivityLogParserRef XCActivityLogParserCreate(const char * filepath);

extern void XCActivityLogParserRelease(XCActivityLogParserRef thisRef);

extern bool XCActivityLogParserSLF0(XCActivityLogParserRef thisRef);

extern XCActivityLogTokenRef XCActivityLogParserNextToken(XCActivityLogParserRef thisRef);

extern void XCActivityLogParserTokenRelease(XCActivityLogTokenRef thisRef);

#ifdef __cplusplus
}
#endif

#endif /* XCACTIVITYLOG_H */

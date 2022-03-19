//
//  XCActivityLogParser.cc
//  XCActivityLogParser
//
//  Created by tiger on 9/19/20.
//

#include "XCActivityLogParser.h"
#include "XCActivityLogLexer.h"

XCActivityLogParserRef XCActivityLogParserCreate(const char * filepath) {
    struct XCActivityLogParser * ref = (struct XCActivityLogParser *)malloc(sizeof(struct XCActivityLogParser));
    Watchants::XCActivityLogLexer *lexer = new Watchants::XCActivityLogLexer(filepath);
    ref->iterator = lexer->iterator();
    ref->lexer = lexer;
    return ref;
}

void XCActivityLogParserRelease(XCActivityLogParserRef thisRef) {
    struct XCActivityLogParser * ref = (struct XCActivityLogParser *)thisRef;
    if (ref != NULL) {
        if (ref->iterator) {
            delete (Watchants::XCActivityLogIterator *)ref->iterator;
            ref->iterator = NULL;
        }
        if (ref->lexer) {
            delete (Watchants::XCActivityLogLexer *)ref->lexer;
            ref->lexer = NULL;
        }
        free(ref);
    }
}

bool XCActivityLogParserSLF0(XCActivityLogParserRef thisRef) {
    Watchants::XCActivityLogIterator *iterator = (Watchants::XCActivityLogIterator *)thisRef->iterator;
    if (iterator != NULL) {
        return iterator->scanSLF0Head();
    } else {
        return false;
    }
}

XCActivityLogTokenRef XCActivityLogParserNextToken(XCActivityLogParserRef thisRef) {
    Watchants::XCActivityLogIterator *iterator = (Watchants::XCActivityLogIterator *)thisRef->iterator;
    return iterator->next();
}

void XCActivityLogParserTokenRelease(XCActivityLogTokenRef thisRef) {
    XCActivityLogTokenRelease(thisRef);
}

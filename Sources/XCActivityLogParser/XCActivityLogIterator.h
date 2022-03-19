//
//  XCActivityLogIterator.h
//  XCActivityLogParser
//
//  Created by tiger on 9/19/20.
//

#ifndef XCLOGPARSERITERATOR_H
#define XCLOGPARSERITERATOR_H

#include <cstdlib>

#include "XCActivityLogToken.h"
#include "XCActivityLogScanner.h"

namespace Watchants {

    struct XCActivityLogIteratorPayload {
        size_t location;
        size_t length;
    };

    struct XCActivityLogIteratorDelimiters {
        size_t location;
        size_t length;
        size_t advance;
    };

    class XCActivityLogIterator {
    private:
        XCActivityLogScanner *scanner;
        XCActivityLogIteratorPayload *payload;
        XCActivityLogIteratorDelimiters *delimiters;
    public:
        XCActivityLogIterator(XCActivityLogScanner *scanner);
        ~XCActivityLogIterator();
    private:
        bool scanPayload();
        bool scanDelimiters();
    public:
        bool scanSLF0Head();
        XCActivityLogTokenRef next();
    };

}

#endif //XCLOGPARSERITERATOR_H

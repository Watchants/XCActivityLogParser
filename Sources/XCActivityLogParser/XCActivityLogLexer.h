//
//  XCActivityLogLexer.h
//  XCActivityLogParser
//
//  Created by tiger on 9/19/20.
//

#ifndef XCLOGPARSER_H
#define XCLOGPARSER_H

#include <cstdlib>

#include "XCActivityLogScanner.h"
#include "XCActivityLogIterator.h"

namespace Watchants {

    class XCActivityLogLexer {
    private:
        int fd;
        size_t size;
        uint8_t *mem;
        XCActivityLogScanner *scanner;
    public:
        XCActivityLogLexer(const char * filepath);
        ~XCActivityLogLexer();
    public:
        XCActivityLogIterator * iterator();
    };
}

#endif //XCLOGPARSER_H

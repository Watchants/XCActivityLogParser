//
//  XCActivityLogScanner.h
//  XCActivityLogParser
//
//  Created by tiger on 9/19/20.
//

#ifndef XCLOGPARSERSCANNER_H
#define XCLOGPARSERSCANNER_H

#include <cstdlib>

namespace Watchants {

    class XCActivityLogScanner {
    public:
        const uint8_t * string;
        size_t advance;
        size_t size;
    public:
        XCActivityLogScanner(const uint8_t * string, size_t size);
        ~XCActivityLogScanner();
    public:
        bool scanString(const uint8_t * keys, size_t size);
        bool scanCharacters(const uint8_t * keys, size_t size, size_t * location, size_t * length);
    };

}

#endif //XCLOGPARSERSCANNER_H

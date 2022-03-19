//
//  XCActivityLogScanner.cc
//  XCActivityLogParser
//
//  Created by tiger on 9/19/20.
//

#include "XCActivityLogScanner.h"

#include <cstring>

namespace Watchants {

    XCActivityLogScanner::XCActivityLogScanner(const uint8_t * string, size_t size) {
        this->string = string;
        this->advance = 0;
        this->size = size;
    }

    XCActivityLogScanner::~XCActivityLogScanner() {

    }

    bool XCActivityLogScanner::scanString(const uint8_t * keys, size_t size) {
        if (this->advance + size >= this->size) return false;
        int result = strncmp((const char *)(this->string + this->advance), (const char *)keys, size);
        if (result == 0) {
            this->advance += size;
            return true;
        } else {
            return false;
        }
    }

    bool XCActivityLogScanner::scanCharacters(const uint8_t * keys, size_t size, size_t * location, size_t * length) {
        size_t count = 0;
        size_t advance = this->advance;
        for (;advance < this->size; advance ++) {
            uint8_t byte = this->string[advance];
            if (byte < size && keys[byte] == 1) {
                count ++;
            } else {
                break;
            }
        }
        if (count > 0) {
            *length = count;
            *location = this->advance;
            this->advance += count;
            return true;
        } else {
            *length = 0;
            *location = 0;
            return false;
        }
    }
}

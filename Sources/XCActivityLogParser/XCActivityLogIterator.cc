//
//  XCActivityLogIterator.cc
//  XCActivityLogParser
//
//  Created by tiger on 9/19/20.
//

#include "XCActivityLogIterator.h"

#include <cstring>

#include "XCActivityLogToken.h"

namespace Watchants {

    XCActivityLogIterator::XCActivityLogIterator(XCActivityLogScanner *scanner) {
        this->scanner = scanner;
        this->payload = new XCActivityLogIteratorPayload();
        this->delimiters = new XCActivityLogIteratorDelimiters();
    }

    XCActivityLogIterator::~XCActivityLogIterator() {
        delete this->payload;
        delete this->delimiters;
    }

    XCActivityLogTokenRef XCActivityLogIterator::next() {
        if (this->delimiters->advance >= this->delimiters->length) {
            this->scanPayload();
            if (!this->scanDelimiters()) {
                return XCActivityLogTokenCreate(this->scanner, "", '\0');
            }
        }
        char payload[this->payload->length + 1];
        memcpy(payload, this->scanner->string + this->payload->location, this->payload->length);
        payload[this->payload->length] = '\0';
        char delimiter = this->scanner->string[this->delimiters->location + this->delimiters->advance];
        this->delimiters->advance += 1;
        return XCActivityLogTokenCreate(this->scanner, payload, delimiter);
    }

    bool XCActivityLogIterator::scanSLF0Head() {
        return this->scanner->scanString(XCActivityLogSLF0Type, XCActivityLogSLF0TypeSize);
    }

    bool XCActivityLogIterator::scanPayload() {
        size_t location;
        size_t length;
        bool result = this->scanner->scanCharacters(XCActivityLogNumerics, XCActivityLogNumericsSize, &location, &length);
        this->payload->location = location;
        this->payload->length = length;
        return result;
    }

    bool XCActivityLogIterator::scanDelimiters() {
        size_t location;
        size_t length;
        bool result = this->scanner->scanCharacters(XCActivityLogDelimiters, XCActivityLogDelimitersSize, &location, &length);
        if (!result) {
            this->delimiters->location = 0;
            this->delimiters->length = 0;
            this->delimiters->advance = 0;
        } else {
            if (length > 0 && this->scanner->string[location] == '"') {
                this->scanner->advance -= (length - 1);
                this->delimiters->location = location;
                this->delimiters->length = 1;
                this->delimiters->advance = 0;
            } else {
                this->delimiters->location = location;
                this->delimiters->length = length;
                this->delimiters->advance = 0;
            }
        }
        return result;
    }
}

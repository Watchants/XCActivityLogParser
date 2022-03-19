//
//  XCActivityLogToken.cc
//  XCActivityLogParser
//
//  Created by tiger on 9/19/20.
//

#include "XCActivityLogToken.h"

#include <string.h>

#include "XCActivityLogScanner.h"

// { 'S', 'L', 'F', '0' }
const uint8_t XCActivityLogSLF0Type[4] = {
        83, 76, 70, 48
};
const size_t XCActivityLogSLF0TypeSize = 4;

// { '#', '%', '@', '"', '^', '-', '('  }
const uint8_t XCActivityLogDelimiters[95] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1, 1, 0, 1, 0, 0,
        1, 0, 0, 0, 0, 1, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 1
};
const size_t XCActivityLogDelimitersSize = 95;

// { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' }
const uint8_t XCActivityLogNumerics[103] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 1, 1,
        1, 1, 1
};
const size_t XCActivityLogNumericsSize = 103;

double XCActivityLogTokenUint64ToDouble(uint64_t number) {
    union Uint64DoubleUnion {
        double d;
        uint64_t i;
        uint8_t bytes[8];
    };
    union Uint64DoubleUnion union1;
    union Uint64DoubleUnion union2;
    union1.i = number;
    union2.bytes[7] = union1.bytes[0];
    union2.bytes[6] = union1.bytes[1];
    union2.bytes[5] = union1.bytes[2];
    union2.bytes[4] = union1.bytes[3];
    union2.bytes[3] = union1.bytes[4];
    union2.bytes[2] = union1.bytes[5];
    union2.bytes[1] = union1.bytes[6];
    union2.bytes[0] = union1.bytes[7];
    return union2.d;
}

XCActivityLogTokenRef XCActivityLogTokenCreate(const void * scannerRef, const char * payload, char delimiter) {
    Watchants::XCActivityLogScanner *scanner = (Watchants::XCActivityLogScanner *)scannerRef;
    XCActivityLogToken * ref = (XCActivityLogToken *)malloc(sizeof(XCActivityLogToken));
    ref->payload = payload;
    ref->delimiter = delimiter;
    ref->number = 0;
    ref->floatingPoint = 0;
    ref->text = NULL;
    switch (delimiter) {
        case '#':
            ref->type = XCActivityLogTokenInteger;
            ref->number = strtoull(payload, NULL, 10);
            break;
        case '%': {
            ref->type = XCActivityLogTokenClassName;
            ref->number = atoi(payload);
            char * text = (char *)malloc(sizeof(char) * (ref->number + 1));
            memcpy(text, scanner->string + scanner->advance, ref->number);
            text[ref->number] = '\0';
            scanner->advance += ref->number;
            ref->text = text;
            break;
        }
        case '@':
            ref->type = XCActivityLogTokenClassInstance;
            ref->number = atoi(payload);
            break;
        case '"': {
            ref->type = XCActivityLogTokenString;
            ref->number = atoi(payload);
            char * text = (char *)malloc(sizeof(char) * (ref->number + 1));
            memcpy(text, scanner->string + scanner->advance, ref->number);
            text[ref->number] = '\0';
            scanner->advance += ref->number;
            ref->text = text;
            break;
        }
        case '^':
            ref->type = XCActivityLogTokenFloatingPoint;
            ref->number = strtoull(payload, NULL, 16);
            ref->floatingPoint = XCActivityLogTokenUint64ToDouble(ref->number);
            break;
        case '-':
            ref->type = XCActivityLogTokenNil;
            break;
        case '(':
            ref->type = XCActivityLogTokenArray;
            ref->number = atoi(payload);
            break;
        default:
            ref->type = XCActivityLogTokenEnded;
            break;
    }
    return ref;
}

void XCActivityLogTokenRelease(XCActivityLogTokenRef thisRef) {
    XCActivityLogToken * ref = (XCActivityLogToken *)thisRef;
    if (ref != NULL) {
        if (ref->text != NULL) {
            free((void *)ref->text);
            ref->text = NULL;
        }
        free(ref);
    }
}

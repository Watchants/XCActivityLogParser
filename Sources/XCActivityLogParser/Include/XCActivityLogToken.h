//
//  XCActivityLogToken.h
//  XCActivityLogParser
//
//  Created by tiger on 9/19/20.
//

#ifndef XCACTIVITYLOGITEM_H
#define XCACTIVITYLOGITEM_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <stdbool.h>

/// The rest is a collection of data with these types
/// Encoding
/// value (optional) + type delimiter + value (optional)
///
/// Integer
/// Type Delimiter: #
/// Example: 10#
/// Tip: 64 unsigned integer
///
/// Double
/// Type Delimiter: ^
/// Example: ac576d51616dc241^
/// Tip: Hexadecimal
/// Tip: Usually is a timeIntervalSinceReferenceDate
///
/// Nil
/// Type Delimiter: -
/// Example: -
/// Tip: No Left nor Right hand side value
///
/// String
/// Type Delimiter: "
/// Example: 39"Xcode.IDEActivityLogDomainType.BuildLog
/// Tip: Left hand value is the number of chars in the String
/// Example: 6"Notice--
/// Tip: This example shows a String: Notice followed by two Nil(-)
///
/// Array
/// Type Delimiter: (
/// Example: 2(
/// Tip: The Left hand value is the number of items in the Array
///
/// Class Name
/// Type Delimiter: %
/// Example: 21%IDEActivityLogSection
/// Tip: The Left hand value is the number of chars in the Class name
/// A specific Class name appears only once in the log.
/// You need to keep track of all the Class names you'll found and store
/// them with the index in which you found them.
///
/// Class instance
/// Type Delimiter: @
/// Example: 1@
/// Tip: The Left hand value is the index of the Class name of this instance type.
/// There could be several Class instances in a log.
/// All the values after a Class reference may be attributes
/// of the class instance.

/// { 'S', 'L', 'F', '0' }
extern const uint8_t XCActivityLogSLF0Type[4];
extern const size_t XCActivityLogSLF0TypeSize;

/// { '#', '%', '@', '"', '^', '-', '('  }
extern const uint8_t XCActivityLogDelimiters[95];
extern const size_t XCActivityLogDelimitersSize;

/// { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' }
extern const uint8_t XCActivityLogNumerics[103];
extern const size_t XCActivityLogNumericsSize;

typedef enum XCActivityLogTokenType {
    XCActivityLogTokenEnded = 0,
    XCActivityLogTokenInteger = 1,
    XCActivityLogTokenFloatingPoint = 2,
    XCActivityLogTokenNil = 3,
    XCActivityLogTokenString = 4,
    XCActivityLogTokenArray = 5,
    XCActivityLogTokenClassName = 6,
    XCActivityLogTokenClassInstance = 7
} XCActivityLogTokenType;

typedef struct XCActivityLogToken {
    const char * payload;
    char delimiter;
    XCActivityLogTokenType type;
    uint64_t number;
    double floatingPoint;
    const char * text;
} XCActivityLogToken;

typedef const XCActivityLogToken * XCActivityLogTokenRef;

extern XCActivityLogTokenRef XCActivityLogTokenCreate(const void * scannerRef, const char * payload, char delimiter);

extern void XCActivityLogTokenRelease(XCActivityLogTokenRef thisRef);

#ifdef __cplusplus
}
#endif

#endif /* XCACTIVITYLOGITEM_H */

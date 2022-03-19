//
//  XCActivityLogParser.cc
//  XCActivityLogParser
//
//  Created by tiger on 9/19/20.
//

import Foundation

import Gzip
import XCActivityLogParser

public final class XCActivityLogParser {
    
    var isCommandLineLog: Bool = false
    
    public init() { }
    
    public func parseInPath(_ filepath: String) throws -> IDEActivityLog {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        return try autoreleasepool {
            try Data(contentsOf: .init(fileURLWithPath: filepath)).gunzipped().write(to: url)
            let iterator = Iterator(url.path)
            try iterator.slf()
            return try parseIDEActiviyLogFromTokens(iterator: iterator)
        }
    }
}

extension XCActivityLogParser {
    
    private func parseIDEActiviyLogFromTokens(iterator: Iterator) throws -> IDEActivityLog {
        return IDEActivityLog(version: Int8(try parseAsInt(token: iterator.next())),
                              mainSection: try parseLogSection(iterator: iterator))
    }
    
    private func parseDVTTextDocumentLocation(iterator: Iterator) throws -> DVTTextDocumentLocation {
        return DVTTextDocumentLocation(documentURLString: try parseAsString(token: iterator.next()),
                                       timestamp: try parseAsDouble(token: iterator.next()),
                                       startingLineNumber: try parseAsInt(token: iterator.next()),
                                       startingColumnNumber: try parseAsInt(token: iterator.next()),
                                       endingLineNumber: try parseAsInt(token: iterator.next()),
                                       endingColumnNumber: try parseAsInt(token: iterator.next()),
                                       characterRangeEnd: try parseAsInt(token: iterator.next()),
                                       characterRangeStart: try parseAsInt(token: iterator.next()),
                                       locationEncoding: try parseAsInt(token: iterator.next()))
    }

    private func parseDVTDocumentLocation(iterator: Iterator) throws -> DVTDocumentLocation {
        return DVTDocumentLocation(documentURLString: try parseAsString(token: iterator.next()),
                                       timestamp: try parseAsDouble(token: iterator.next()))
    }

    private func parseIDEActivityLogMessage(iterator: Iterator) throws -> IDEActivityLogMessage {
        return IDEActivityLogMessage(title: try parseAsString(token: iterator.next()),
                                     shortTitle: try parseAsString(token: iterator.next()),
                                     timeEmitted: try Double(parseAsInt(token: iterator.next())),
                                     rangeEndInSectionText: try parseAsInt(token: iterator.next()),
                                     rangeStartInSectionText: try parseAsInt(token: iterator.next()),
                                     subMessages: try parseMessages(iterator: iterator),
                                     severity: Int(try parseAsInt(token: iterator.next())),
                                     type: try parseAsString(token: iterator.next()),
                                     location: try parseDocumentLocation(iterator: iterator),
                                     categoryIdent: try parseAsString(token: iterator.next()),
                                     secondaryLocations: try parseDocumentLocations(iterator: iterator),
                                     additionalDescription: try parseAsString(token: iterator.next()))
    }

    private func parseIDEActivityLogSection(iterator: Iterator) throws -> IDEActivityLogSection {
        return IDEActivityLogSection(sectionType: Int8(try parseAsInt(token: iterator.next())),
                                     domainType: try parseAsString(token: iterator.next()),
                                     title: try parseAsString(token: iterator.next()),
                                     signature: try parseAsString(token: iterator.next()),
                                     timeStartedRecording: try parseAsDouble(token: iterator.next()),
                                     timeStoppedRecording: try parseAsDouble(token: iterator.next()),
                                     subSections: try parseIDEActivityLogSections(iterator: iterator),
                                     text: try parseAsString(token: iterator.next()),
                                     messages: try parseMessages(iterator: iterator),
                                     wasCancelled: try parseBoolean(token: iterator.next()),
                                     isQuiet: try parseBoolean(token: iterator.next()),
                                     wasFetchedFromCache: try parseBoolean(token: iterator.next()),
                                     subtitle: try parseAsString(token: iterator.next()),
                                     location: try parseDocumentLocation(iterator: iterator),
                                     commandDetailDesc: try parseAsString(token: iterator.next()),
                                     uniqueIdentifier: try parseAsString(token: iterator.next()),
                                     localizedResultString: try parseAsString(token: iterator.next()),
                                     xcbuildSignature: try parseAsString(token: iterator.next()),
                                     unknown: isCommandLineLog ? Int(try parseAsInt(token: iterator.next())) : 0)
    }

    private func parseIDEActivityLogUnitTestSection(iterator: Iterator) throws -> IDEActivityLogUnitTestSection {
            return IDEActivityLogUnitTestSection(sectionType: Int8(try parseAsInt(token: iterator.next())),
                                         domainType: try parseAsString(token: iterator.next()),
                                         title: try parseAsString(token: iterator.next()),
                                         signature: try parseAsString(token: iterator.next()),
                                         timeStartedRecording: try parseAsDouble(token: iterator.next()),
                                         timeStoppedRecording: try parseAsDouble(token: iterator.next()),
                                         subSections: try parseIDEActivityLogSections(iterator: iterator),
                                         text: try parseAsString(token: iterator.next()),
                                         messages: try parseMessages(iterator: iterator),
                                         wasCancelled: try parseBoolean(token: iterator.next()),
                                         isQuiet: try parseBoolean(token: iterator.next()),
                                         wasFetchedFromCache: try parseBoolean(token: iterator.next()),
                                         subtitle: try parseAsString(token: iterator.next()),
                                         location: try parseDocumentLocation(iterator: iterator),
                                         commandDetailDesc: try parseAsString(token: iterator.next()),
                                         uniqueIdentifier: try parseAsString(token: iterator.next()),
                                         localizedResultString: try parseAsString(token: iterator.next()),
                                         xcbuildSignature: try parseAsString(token: iterator.next()),
                                         unknown: isCommandLineLog ? Int(try parseAsInt(token: iterator.next())) : 0,
                                         testsPassedString: try parseAsString(token: iterator.next()),
                                         durationString: try parseAsString(token: iterator.next()),
                                         summaryString: try parseAsString(token: iterator.next()),
                                         suiteName: try parseAsString(token: iterator.next()),
                                         testName: try parseAsString(token: iterator.next()),
                                         performanceTestOutputString: try parseAsString(token: iterator.next()))
    }

    private func parseDBGConsoleLog(iterator: Iterator) throws -> DBGConsoleLog {
            return DBGConsoleLog(sectionType: Int8(try parseAsInt(token: iterator.next())),
                                                 domainType: try parseAsString(token: iterator.next()),
                                                 title: try parseAsString(token: iterator.next()),
                                                 signature: try parseAsString(token: iterator.next()),
                                                 timeStartedRecording: try parseAsDouble(token: iterator.next()),
                                                 timeStoppedRecording: try parseAsDouble(token: iterator.next()),
                                                 subSections: try parseIDEActivityLogSections(iterator: iterator),
                                                 text: try parseAsString(token: iterator.next()),
                                                 messages: try parseMessages(iterator: iterator),
                                                 wasCancelled: try parseBoolean(token: iterator.next()),
                                                 isQuiet: try parseBoolean(token: iterator.next()),
                                                 wasFetchedFromCache: try parseBoolean(token: iterator.next()),
                                                 subtitle: try parseAsString(token: iterator.next()),
                                                 location: try parseDocumentLocation(iterator: iterator),
                                                 commandDetailDesc: try parseAsString(token: iterator.next()),
                                                 uniqueIdentifier: try parseAsString(token: iterator.next()),
                                                 localizedResultString: try parseAsString(token: iterator.next()),
                                                 xcbuildSignature: try parseAsString(token: iterator.next()),
                                                 // swiftlint:disable:next line_length
                                                 unknown: isCommandLineLog ? Int(try parseAsInt(token: iterator.next())) : 0,
                                                 logConsoleItems: try parseIDEConsoleItems(iterator: iterator)
                                                 )
    }

    private func parseIDEActivityLogAnalyzerResultMessage(iterator: Iterator) throws -> IDEActivityLogAnalyzerResultMessage {
        return IDEActivityLogAnalyzerResultMessage(
                                     title: try parseAsString(token: iterator.next()),
                                     shortTitle: try parseAsString(token: iterator.next()),
                                     timeEmitted: try Double(parseAsInt(token: iterator.next())),
                                     rangeEndInSectionText: try parseAsInt(token: iterator.next()),
                                     rangeStartInSectionText: try parseAsInt(token: iterator.next()),
                                     subMessages: try parseMessages(iterator: iterator),
                                     severity: Int(try parseAsInt(token: iterator.next())),
                                     type: try parseAsString(token: iterator.next()),
                                     location: try parseDocumentLocation(iterator: iterator),
                                     categoryIdent: try parseAsString(token: iterator.next()),
                                     secondaryLocations: try parseDocumentLocations(iterator: iterator),
                                     additionalDescription: try parseAsString(token: iterator.next()),
                                     resultType: try parseAsString(token: iterator.next()),
                                     keyEventIndex: try parseAsInt(token: iterator.next()))
    }

    private func parseIDEActivityLogAnalyzerEventStepMessage(iterator: Iterator) throws -> IDEActivityLogAnalyzerEventStepMessage {
        return IDEActivityLogAnalyzerEventStepMessage(
                                     title: try parseAsString(token: iterator.next()),
                                     shortTitle: try parseAsString(token: iterator.next()),
                                     timeEmitted: try Double(parseAsInt(token: iterator.next())),
                                     rangeEndInSectionText: try parseAsInt(token: iterator.next()),
                                     rangeStartInSectionText: try parseAsInt(token: iterator.next()),
                                     subMessages: try parseMessages(iterator: iterator),
                                     severity: Int(try parseAsInt(token: iterator.next())),
                                     type: try parseAsString(token: iterator.next()),
                                     location: try parseDocumentLocation(iterator: iterator),
                                     categoryIdent: try parseAsString(token: iterator.next()),
                                     secondaryLocations: try parseDocumentLocations(iterator: iterator),
                                     additionalDescription: try parseAsString(token: iterator.next()),
                                     parentIndex: try parseAsInt(token: iterator.next()),
                                     description: try parseAsString(token: iterator.next()),
                                     callDepth: try parseAsInt(token: iterator.next()))
    }

    private func parseIDEActivityLogAnalyzerControlFlowStepMessage(iterator: Iterator) throws -> IDEActivityLogAnalyzerControlFlowStepMessage {
        return IDEActivityLogAnalyzerControlFlowStepMessage(
                                     title: try parseAsString(token: iterator.next()),
                                     shortTitle: try parseAsString(token: iterator.next()),
                                     timeEmitted: try Double(parseAsInt(token: iterator.next())),
                                     rangeEndInSectionText: try parseAsInt(token: iterator.next()),
                                     rangeStartInSectionText: try parseAsInt(token: iterator.next()),
                                     subMessages: try parseMessages(iterator: iterator),
                                     severity: Int(try parseAsInt(token: iterator.next())),
                                     type: try parseAsString(token: iterator.next()),
                                     location: try parseDocumentLocation(iterator: iterator),
                                     categoryIdent: try parseAsString(token: iterator.next()),
                                     secondaryLocations: try parseDocumentLocations(iterator: iterator),
                                     additionalDescription: try parseAsString(token: iterator.next()),
                                     parentIndex: try parseAsInt(token: iterator.next()),
                                     endLocation: try parseDocumentLocation(iterator: iterator),
                                     edges: try parseStepEdges(iterator: iterator))
    }

    private func parseIDEActivityLogAnalyzerControlFlowStepEdge(iterator: Iterator) throws -> IDEActivityLogAnalyzerControlFlowStepEdge {
        return IDEActivityLogAnalyzerControlFlowStepEdge(
                                     startLocation: try parseDocumentLocation(iterator: iterator),
                                     endLocation: try parseDocumentLocation(iterator: iterator))
    }
    
}

extension XCActivityLogParser {
    
    private func parseMessages(iterator: Iterator) throws -> [IDEActivityLogMessage] {
        let token = try iterator.next()
        switch token {
        case .null: return []
        case .array(let count):
            return try count.map {
                try parseLogMessage(iterator: iterator)
            }
        default:
            throw Error.parseError("Unexpected token parsing array of IDEActivityLogMessage \(token)")
        }
    }

    private func parseDocumentLocations(iterator: Iterator) throws -> [DVTDocumentLocation] {
        let token = try iterator.next()
        switch token {
        case .null: return []
        case .array(let count):
            return try count.map {
                try parseDocumentLocation(iterator: iterator)
            }
        default:
            throw Error.parseError("Unexpected token parsing array of DocumentLocation \(token)")
        }
    }

    private func parseDocumentLocation(iterator: Iterator) throws -> DVTDocumentLocation {
        let token = try iterator.next()
        if case .null = token {
            return DVTDocumentLocation(documentURLString: "", timestamp: 0.0)
        }
        guard case .classInstance(let className) = token else {
            throw Error.parseError("Unexpected token found parsing DocumentLocation \(token)")
        }
        if className == String(describing: DVTTextDocumentLocation.self) {
            return try parseDVTTextDocumentLocation(iterator: iterator)
        } else if className == String(describing: DVTDocumentLocation.self)  || className == "Xcode3ProjectDocumentLocation" || className == "IDELogDocumentLocation" {
            return try parseDVTDocumentLocation(iterator: iterator)
        } else if className == String(describing: IBDocumentMemberLocation.self) {
            return try parseIBDocumentMemberLocation(iterator: iterator)
        }
        throw Error.parseError("Unexpected className found parsing DocumentLocation \(className)")
    }

    private func parseLogMessage(iterator: Iterator) throws -> IDEActivityLogMessage {
        let token = try iterator.next()
        guard case .classInstance(let className) = token else {
            throw Error.parseError("Unexpected token found parsing IDEActivityLogMessage \(token)")
        }
        if className == String(describing: IDEActivityLogMessage.self) || className == "IDEClangDiagnosticActivityLogMessage" || className == "IDEDiagnosticActivityLogMessage" {
            return try parseIDEActivityLogMessage(iterator: iterator)
        }
        if className ==  String(describing: IDEActivityLogAnalyzerResultMessage.self) {
            return try parseIDEActivityLogAnalyzerResultMessage(iterator: iterator)
        }
        if className ==  String(describing: IDEActivityLogAnalyzerControlFlowStepMessage.self) {
            return try parseIDEActivityLogAnalyzerControlFlowStepMessage(iterator: iterator)
        }
        if className == String(describing: IDEActivityLogAnalyzerEventStepMessage.self) {
            return try parseIDEActivityLogAnalyzerEventStepMessage(iterator: iterator)
        }
        throw Error.parseError("Unexpected className found parsing IDEActivityLogMessage \(className)")
    }

    private func parseLogSection(iterator: Iterator) throws -> IDEActivityLogSection {
        var token = try iterator.next()
        if case .integer = token {
            isCommandLineLog = true
            token = try iterator.next()
        }
        guard case .classInstance(let className) = token else {
            throw Error.parseError("Unexpected token found parsing IDEActivityLogSection \(token)")
        }
        if className == String(describing: IDEActivityLogSection.self) {
            return try parseIDEActivityLogSection(iterator: iterator)
        }
        if className == "IDECommandLineBuildLog" || className == "IDEActivityLogMajorGroupSection" || className == "IDEActivityLogCommandInvocationSection" {
            return try parseIDEActivityLogSection(iterator: iterator)
        }
        if className == "IDEActivityLogUnitTestSection" {
            return try parseIDEActivityLogUnitTestSection(iterator: iterator)
        }
        if className == String(describing: DBGConsoleLog.self) {
            return try parseDBGConsoleLog(iterator: iterator)
        }
        throw Error.parseError("Unexpected className found parsing IDEActivityLogSection \(className)")
    }

    private func parseIDEActivityLogSections(iterator: Iterator) throws -> [IDEActivityLogSection] {
        let token = try iterator.next()
        switch token {
        case .null: return []
        case .array(let count):
            return try count.map {
                try parseLogSection(iterator: iterator)
            }
        default:
            throw Error.parseError("Unexpected token parsing array of IDEActivityLogSection \(token)")
        }
    }

    private func parseIDEConsoleItem(iterator: Iterator) throws -> IDEConsoleItem? {
        let token = try iterator.next()
        if case .null = token {
            return nil
        }
        guard case .classInstance(let className) = token else {
            throw Error.parseError("Unexpected token found parsing IDEConsoleItem \(token)")
        }
        if className == String(describing: IDEConsoleItem.self) {
            return IDEConsoleItem(adaptorType: try parseAsInt(token: iterator.next()),
                                  content: try parseAsString(token: iterator.next()),
                                  kind: try parseAsInt(token: iterator.next()),
                                  timestamp: try parseAsDouble(token: iterator.next()))
        }
        throw Error.parseError("Unexpected className found parsing IDEConsoleItem \(className)")
    }

    private func parseIDEConsoleItems(iterator: Iterator) throws -> [IDEConsoleItem] {
        let token = try iterator.next()
        switch token {
        case .null: return []
        case .array(let count):
            return try count.map {
                try parseIDEConsoleItem(iterator: iterator)
            }.compactMap { $0 }
        default:
            throw Error.parseError("Unexpected token parsing array of IDEConsoleItem \(token)")
        }
    }

    private func parseStepEdge(iterator: Iterator) throws -> IDEActivityLogAnalyzerControlFlowStepEdge {
        let token = try iterator.next()
        guard case .classInstance(let className) = token else {
            throw Error.parseError("Unexpected token found parsing IDEActivityLogAnalyzerControlFlowStepEdge \(token)")
        }
        if className == String(describing: IDEActivityLogAnalyzerControlFlowStepEdge.self) {
            return try parseIDEActivityLogAnalyzerControlFlowStepEdge(iterator: iterator)
        }
        throw Error.parseError("Unexpected className found parsing IDEActivityLogAnalyzerControlFlowStepEdge \(className)")
    }

    private func parseStepEdges(iterator: Iterator) throws -> [IDEActivityLogAnalyzerControlFlowStepEdge] {
        let token = try iterator.next()
        switch token {
        case .null: return []
        case .array(let count):
            return try count.map {
                try parseStepEdge(iterator: iterator)
            }
        default:
            throw Error.parseError("Unexpected token parsing array of IDEActivityLogAnalyzerControlFlowStepEdge \(token)")
        }
    }

    private func parseIBDocumentMemberLocation(iterator: Iterator) throws -> IBDocumentMemberLocation {
        return IBDocumentMemberLocation(documentURLString: try parseAsString(token: iterator.next()),
                                        timestamp: try parseAsDouble(token: iterator.next()),
                                        memberIdentifier: try parseIBMemberID(iterator: iterator),
                                        attributeSearchLocation: try parseIBAttributeSearchLocation(iterator: iterator))
    }

    private func parseIBMemberID(iterator: Iterator) throws -> IBMemberID {
        let token = try iterator.next()
        guard case .classInstance(let className) = token else {
            throw Error.parseError("Unexpected token found parsing IBMemberID \(token)")
        }

        if className == String(describing: IBMemberID.self) {
            return IBMemberID(memberIdentifier: try parseAsString(token: iterator.next()))
        }
        throw Error.parseError("Unexpected className found parsing IBMemberID \(className)")
    }

    private func parseIBAttributeSearchLocation(iterator: Iterator) throws -> IBAttributeSearchLocation? {
        let token = try iterator.next()
        if case .null = token {
            return nil
        }
        throw Error.parseError("Unexpected Token parsing IBAttributeSearchLocation: \(token)")
    }
}

extension XCActivityLogParser {
    
    private func parseAsString(token: Token?) throws -> String {
        guard let token = token else {
            throw Error.parseError("Unexpected EOF parsing String")
        }
        switch token {
        case .string(let string):
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        case .null:
            return ""
        default:
            throw Error.parseError("Unexpected token parsing String: \(token)")
        }
    }

    private func parseAsInt(token: Token?) throws -> UInt64 {
        guard let token = token else {
            throw Error.parseError("Unexpected EOF parsing Int")
        }
        if case .integer(let value) = token {
            return value
        }
        throw Error.parseError("Unexpected token parsing Int: \(token))")
    }

    private func parseAsDouble(token: Token?) throws -> Double {
        guard let token = token else {
            throw Error.parseError("Unexpected EOF parsing Double")
        }
        if case .floatingPoint(let value) = token {
            return value
        }
        throw Error.parseError("Unexpected token parsing Double: \(token)")
    }

    private func parseBoolean(token: Token?) throws -> Bool {
        guard let token = token else {
            throw Error.parseError("Unexpected EOF parsing Bool")
        }
        if case .integer(let value) = token {
            if value > 1 {
                throw Error.parseError("Unexpected value parsing Bool: \(value)")
            }
            return value == 1
        }
        throw Error.parseError("Unexpected token parsing Bool: \(token)")
    }

}

extension XCActivityLogParser {
    
    private enum Token {
        case notSLF0
        case pointeeNil
        case integer(UInt64)
        case floatingPoint(Double)
        case null
        case string(String)
        case array(UInt64)
        case className(String)
        case classInstance(String)
    }
    
    private final class Iterator {
        
        var classes: [String]
        
        let file: String
        
        let parser: XCActivityLogParserRef
        
        init(_ filepath: String) {
            file = filepath
            parser = XCActivityLogParserCreate(filepath)
            classes = Array<String>()
        }
        
        deinit {
            XCActivityLogParserRelease(parser)
        }
        
        func slf() throws {
            if !XCActivityLogParserSLF0(parser) {
                throw Error.invalidHeader(file)
            }
        }
        
        func next() throws -> Token {
            let token = XCActivityLogParserNextToken(parser)
            defer { XCActivityLogParserTokenRelease(token) }
            guard let token = token?.pointee else {
                return .pointeeNil
            }
            
            switch token.type {
            case XCActivityLogTokenEnded:
                throw Error.parseError("Unexpected EOF parsing")
            case XCActivityLogTokenInteger:
                return .integer(token.number)
            case XCActivityLogTokenFloatingPoint:
                return .floatingPoint(token.floatingPoint)
            case XCActivityLogTokenNil:
                return .null
            case XCActivityLogTokenString:
                return .string(String(cString: token.text))
            case XCActivityLogTokenArray:
                return .array(token.number)
            case XCActivityLogTokenClassName:
                classes.append(String(cString: token.text))
                return try next()
            case XCActivityLogTokenClassInstance:
                return .classInstance(classes[Int(token.number - 1)])
            default:
                throw Error.parseError("Unexpected unknown parsing")
            }
        }
    }
}

extension XCActivityLogParser {
    
    public enum Error: Swift.Error {
        case invalidHeader(String)
        case invalidLine(String)
        case errorCreatingReport(String)
        case wrongLogManifestFile(String, String)
        case parseError(String)
        case readingFile(String)
    }
}

fileprivate extension UInt64 {
    
    func map<T>(_ transform: () throws -> T) rethrows -> [T] {
        return try (0..<self).map { _ in
            try transform()
        }
    }
}

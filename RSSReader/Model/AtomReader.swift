//
//  AtomReader.swift
//  RSSReader
//  
//  Created by kunikuni03 on 2022/02/06
//  
//

import Foundation

class AtomReader: NSObject {
    private var parser: XMLParser!
    private var parseData = AtomFeedModel()
    private var tagName = ""
    
    private enum parseState {
        case feed
        case entry
    }
    private var state = parseState.feed

    init(data: Data) {
        self.parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
    }
    
    // Parse XML data
    func parse() -> AtomFeedModel {
        // parse data initialize
        parseData = AtomFeedModel()

        guard parser.parse() else {
            print("Parse XML file error. Perser is not defined.")
            return AtomFeedModel()
        }
        return parseData
    }
}

extension AtomReader: XMLParserDelegate {
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("Start to parse for Atom file.")
        // initialize parse data
        parseData = AtomFeedModel()
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("End to parse for Atom file.")
        print(parseData)
    }
    
    // When parsing the start tag.
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("When parsing the start tagName: \(elementName)")
        tagName = elementName
        
        if tagName == "feed" {
            state = parseState.feed
        } else if tagName == "entry" {
            state = parseState.entry
        }
        
        if tagName == "link" {
            switch state {
            case .feed:
                parseData.link = attributeDict["href"] ?? ""
            case .entry:
                parseData.entry.link = attributeDict["href"] ?? ""
            }
        }
    }
    
    // When parsing the element.
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("When parsing the element: \(string)")
        if !string.contains("\n") {
            setElementValue(state: state, tagName: tagName, value: string)
        }
    }
    
    private func setElementValue(state: parseState, tagName: String, value: String) {
        switch state {
        case .feed:
            setFeedValue(tagName: tagName, value: value)
        case .entry:
            setEntryValue(tagName: tagName, value: value)
        }
    }
    
    private func setFeedValue(tagName: String, value: String) {
        switch tagName {
        case "title":
            parseData.title = value
        case "subtitle":
            parseData.subtitle = value
        case "link":
            // The link tag has no value
            break
        case "updated":
            parseData.updated = value
        default:
            break
        }
    }
    
    private func setEntryValue(tagName: String, value: String) {
        switch tagName {
        case "title":
            parseData.entry.title = value
        case "updated":
            parseData.entry.updated = value
        case "link":
            // The link tag has no value
            break
        case "content":
            parseData.entry.content = value
        default:
            break
        }
    }
}

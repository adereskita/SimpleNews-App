//
//  SearchNewsModel.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import Foundation

// MARK: - SearchNews
struct SearchNews: Codable {
    let status, copyright: String?
    let response: SearchResponse?
    
    enum CodingKeys: String, CodingKey {
        case status, copyright, response
    }
}

// MARK: - Response
struct SearchResponse: Codable {
    let docs: [SearchDoc]?
    let meta: Meta?
    
    enum CodingKeys: String, CodingKey {
        case docs, meta
    }
}

// MARK: - Doc
struct SearchDoc: Codable {
    let abstract: String?
    let webURL: String?
    let snippet, leadParagraph: String?
    let source: String?
    let multimedia: [Multimedia]?
    let headline: Headline?
    let keywords: [Keyword]?
    let pubDate: String?
    let documentType: String?
    let newsDesk, sectionName: String?
    let byline: Byline?
    let typeOfMaterial: String?
    let id: String?
    let wordCount: Int?
    let uri, printSection, printPage, subsectionName: String?

    enum CodingKeys: String, CodingKey {
        case abstract
        case webURL = "web_url"
        case snippet
        case leadParagraph = "lead_paragraph"
        case source, multimedia, headline, keywords
        case pubDate = "pub_date"
        case documentType = "document_type"
        case newsDesk = "news_desk"
        case sectionName = "section_name"
        case byline
        case typeOfMaterial = "type_of_material"
        case id = "_id"
        case wordCount = "word_count"
        case uri
        case printSection = "print_section"
        case printPage = "print_page"
        case subsectionName = "subsection_name"
    }
}

// MARK: - Byline
struct Byline: Codable {
    let original: String?
    let person: [Person]?
}

// MARK: - Person
struct Person: Codable {
    let firstname: String?
    let middlename: String?
    let lastname: String?
    let role: String?
    let organization: String?
    let rank: Int?
}

// MARK: - Headline
struct Headline: Codable {
    let main: String?
    let printHeadline: String?

    enum CodingKeys: String, CodingKey {
        case main
        case printHeadline = "print_headline"
    }
}

// MARK: - Keyword
struct Keyword: Codable {
    let name: String?
    let value: String?
    let rank: Int?
    let major: String?
}

// MARK: - Multimedia
struct Multimedia: Codable {
    let rank: Int?
    let subtype: String?
    let type: String?
    let url: String?
    let height, width: Int?
    let legacy: Legacy?
    let subType, cropName: String?

    enum CodingKeys: String, CodingKey {
        case rank, subtype, type, url, height, legacy, width, subType
        case cropName = "crop_name"
    }
}

// MARK: - Legacy
struct Legacy: Codable {
    let xlarge: String?
    let xlargewidth, xlargeheight: Int?
    let thumbnail: String?
    let thumbnailwidth, thumbnailheight, widewidth, wideheight: Int?
    let wide: String?
}

// MARK: - Meta
struct Meta: Codable {
    let hits, offset, time: Int?
}

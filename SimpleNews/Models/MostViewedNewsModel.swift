//
//  MostViewedNewsModel.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import Foundation

// MARK: - MostViewedNews
struct MostViewedNews: Codable {
    let status, copyright: String?
    let numResults: Int?
    let results: [MostViewedResult]?

    enum CodingKeys: String, CodingKey {
        case status, copyright
        case numResults = "num_results"
        case results
    }
}

// MARK: - Result
struct MostViewedResult: Codable {
    let uri: String?
    let url: String?
    let id, assetID: Int?
    let source: String?
    let publishedDate: String?
    let updated: String?
    let section: String?
    let subsection: String?
    let nytdsection, adxKeywords: String?
    let byline: String?
    let type: String?
    let title, abstract: String?
    let desFacet, orgFacet, perFacet, geoFacet: [String]?
    let media: [Media]?
    let etaID: Int?

    enum CodingKeys: String, CodingKey {
        case uri, url, id
        case assetID = "asset_id"
        case source
        case publishedDate = "published_date"
        case updated, section, subsection, nytdsection
        case adxKeywords = "adx_keywords"
        case byline, type, title, abstract
        case desFacet = "des_facet"
        case orgFacet = "org_facet"
        case perFacet = "per_facet"
        case geoFacet = "geo_facet"
        case media
        case etaID = "eta_id"
    }
}

// MARK: - Media
struct Media: Codable {
    let type: String?
    let subtype: String?
    let caption, copyright: String?
    let approvedForSyndication: Int?
    let mediaMetadata: [MediaMeta]?

    enum CodingKeys: String, CodingKey {
        case type, subtype, caption, copyright
        case approvedForSyndication = "approved_for_syndication"
        case mediaMetadata = "media-metadata"
    }
}

// MARK: - MediaMetadatum
struct MediaMeta: Codable {
    let url: String?
    let format: String?
    let height, width: Int?
    
    enum CodingKeys: String, CodingKey {
        case url, format, height, width
    }
}

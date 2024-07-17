//
//  Copyright © Marc Rollin.
//

import Foundation

public enum ArchiveNodeCategory: String, Sendable, Comparable, Codable {
    case app
    case appExtension
    case assetCatalog
    case binary
    case bundle
    case content
    case data
    case folder
    case font
    case framework
    case localization
    case model

    private var sortKey: Int {
      switch self {
        case .app:
          return 001
        case .appExtension:
          return 010
        case .assetCatalog:
          return 040
        case .binary:
          return 000
        case .bundle:
          return 030
        case .content:
          return 500
        case .data:
          return 600
        case .folder:
          return 100
        case .font:
          return 400
        case .framework:
          return 020
        case .localization:
          return 200
        case .model:
          return 300
      }
    }

    // MARK: Lifecycle

    init(contentType: ContentType?, resourceType: URLFileResourceType?) {
        self = switch contentType {
        case .asset?:
            .assetCatalog
        case .binary?:
            .binary
        case .binarySection?:
            .binary
        case .package(let packageExtension)?:
            switch packageExtension {
            case .app: .app
            case .appex: .appExtension
            case .bundle: .bundle
            case .car: .assetCatalog
            case .framework: .framework
            case .lproj: .localization
            case .mlmodelc, .momd: .model
            }
        case .universal(let utType)?:
            if utType.isSubtype(of: .content) { .content }
            else if utType.isSubtype(of: .data) { .data }
            else if utType.isSubtype(of: .font) { .font }
            else { .data }
        case nil:
            resourceType == .directory ? .folder : .data
        }
    }

    // MARK: Public

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.sortKey < rhs.sortKey
    }
}

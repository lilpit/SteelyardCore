//
//  Copyright © Marc Rollin.
//

import Foundation
import Platform

public struct ArchiveApp: Sendable, Identifiable, Codable {
    // MARK: Lifecycle

     init?(_ node: ArchiveNode, allowedNodeCategories: Set<ArchiveNodeCategory>? = nil) {
        guard case .app(let infoPlist) = node.metadata
        else {
            return nil
        }
        let scales = ["@3x", "@2x", ""]

        url = node.url
        icon = if let iconNames = infoPlist.icons?.primaryIcon?.iconFiles {
            iconNames.lazy
                .flatMap { iconName in
                    scales.map { scale in
                        node.url.appendingPathComponent("\(iconName)\(scale).png")
                    }
                }
                .first { FileManager.default.fileExists(atPath: $0.path) }
                .flatMap { try? Data(contentsOf: $0) }
        } else if let iconFile = infoPlist.iconFile {
            try? Data(
                contentsOf: url.appending(component: "Contents")
                    .appending(component: "Resources")
                    .appending(component: "\(iconFile).icns")
            )
        } else {
            nil
        }
        platforms = infoPlist.supportedPlatforms.compactMap(Platform.init)
        name = infoPlist.displayName ?? infoPlist.name
        version = "\(infoPlist.shortVersion) (\(infoPlist.version))"

       if let allowedNodeCategories {
         if let filteredNode = node.filteredByCategories(allowedCategories: allowedNodeCategories) {
           self.node = filteredNode
         } else {
           return nil
         }
       } else {
         self.node = node
       }
    }

    // MARK: Public

    public enum Platform: String, Sendable, Codable {
        case ipad = "iPadOS"
        case iphone = "iPhoneOS"
        case mac = "MacOSX"
        case tv = "TVOS"
        case watch = "WatchOS"
    }

    public let url: URL
    @NotCoded public var icon: Data?
    public let platforms: [Platform]
    public let name: String
    public let version: String
    public let node: ArchiveNode

    public var id: URL {
        url
    }
}

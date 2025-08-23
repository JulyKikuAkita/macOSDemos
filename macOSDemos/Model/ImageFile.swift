//
//  ImageFile.swift
//  macOSDemos
//

import SwiftUI

struct ImageFile: Identifiable, Hashable, Transferable {
    var id: String = UUID().uuidString
    var title: String
    var image: NSImage?

    /// drag image as title text (for demo purpose)
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.title) // export as plain text
    }

//    /// drag image content as PNG
//    static var transferRepresentation: some TransferRepresentation {
//        DataRepresentation(exportedContentType: .png) { file in
//            guard let image = file.image,
//                  let tiff = image.tiffRepresentation,
//                  let bitmap = NSBitmapImageRep(data: tiff),
//                  let png = bitmap.representation(using: .png, properties: [:])
//            else {
//                throw NSError(domain: "ImageFile", code: -1)
//            }
//            return png
//        }
//    }
}

var sampleItems: [ImageFile] = [
    .init(title: "paragliding", image: NSImage(named: "IMG_3001")),
    .init(title: "haha", image: NSImage(named: "IMG_3002")),
    .init(title: "kiku", image: NSImage(named: "IMG_3003")),
    .init(title: "dog1", image: NSImage(named: "IMG_3004")),
    .init(title: "dog2", image: NSImage(named: "IMG_3005")),
    .init(title: "Democracy", image: NSImage(named: "IMG_3006")),
    .init(title: "noWay", image: NSImage(named: "IMG_3007")),
    .init(title: "yellowRob", image: NSImage(named: "IMG_3008")),
    .init(title: "Fox", image: NSImage(named: "fox")),
]

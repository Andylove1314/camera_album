import UIKit
import Photos

class Album {

    let collection: PHAssetCollection
    let mediaType: PHAssetMediaType
    var items: [Image] = []

    // MARK: - Initialization

    init(collection: PHAssetCollection, mediaType: PHAssetMediaType) {
        self.collection = collection
        self.mediaType = mediaType
    }

    func reload() {
        items = []
        
        let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: Utils.fetchOptions(mediaType: mediaType))
        itemsFetchResult.enumerateObjects({ (asset, count, stop) in
            if asset.mediaType == .image {
                self.items.append(Image(asset: asset))
            } else if asset.mediaType == .video {
                self.items.append(Video(asset: asset))
            }
        })
        self.items.reverse()
    }
}


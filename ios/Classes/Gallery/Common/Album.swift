import UIKit
import Photos

class Album {

    let collection: PHAssetCollection
    var items: [Image] = []

    // MARK: - Initialization

    init(collection: PHAssetCollection) {
        self.collection = collection
    }

    func fetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return options
    }
    
    func reload() {
        items = []
        
        let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions())
        itemsFetchResult.enumerateObjects({ (asset, count, stop) in
            if asset.mediaType == .image {
                self.items.append(Image(asset: asset))
            }
        })
    }
}


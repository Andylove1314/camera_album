import UIKit
import Photos

extension Array {

  mutating func g_moveToFirst(_ index: Int) {
    guard index != 0 && index < count else { return }

    let item = self[index]
    remove(at: index)
    insert(item, at: 0)
  }
}

class ImagesLibrary {

  var mediaType: PHAssetMediaType
  var albums: [Album] = []
  var albumsFetchResults = [PHFetchResult<PHAssetCollection>]()

  // MARK: - Initialization

  init(mediaType: PHAssetMediaType) {
     self.mediaType = mediaType
  }

  // MARK: - Logic

  func reload(_ completion: @escaping () -> Void) {
    DispatchQueue.global().async {
      self.reloadSync()
      DispatchQueue.main.async {
        completion()
      }
    }
  }

  fileprivate func reloadSync() {
    let types: [PHAssetCollectionType] = [.smartAlbum, .album]
    let videoTypes: [PHAssetCollectionSubtype] = [.smartAlbumVideos]

    if mediaType == .video {
//        let options = PHFetchOptions()
//        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        albumsFetchResults = videoTypes.map {
            return PHAssetCollection.fetchAssetCollections(with: .album, subtype: $0, options: nil)
        }
    } else {
        albumsFetchResults = types.map {
          return PHAssetCollection.fetchAssetCollections(with: $0, subtype: .any, options: nil)
        }
    }
    albums = []

    for result in albumsFetchResults {
      result.enumerateObjects({ (collection, _, _) in
        let album = Album(collection: collection)
        album.reload()

        if !album.items.isEmpty {
          self.albums.append(album)
        }
      })
    }

    // Move Camera Roll first
    if let index = albums.firstIndex(where: { $0.collection.assetCollectionSubtype == . smartAlbumUserLibrary }) {
      albums.g_moveToFirst(index)
    }
  }
}

import UIKit
import Photos

/// Wrap a PHAsset
public class Image: Equatable {

  public let asset: PHAsset

  // MARK: - Initialization
  
  init(asset: PHAsset) {
    self.asset = asset
  }
    
   static func initWith(identifier: String) -> Image? {
    if let asset = Utils.phAssetWith(identifier: identifier) {
           return Image(asset: asset)
       }
       return nil
   }
    
}

// MARK: - UIImage

extension Image {

    /// Resolve UIImage synchronously
    ///
    /// - Parameter size: The target size
    /// - Returns: The resolved UIImage, otherwise nil
    public func resolveTargetSize(_ size: CGSize?, completion: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
      let options = PHImageRequestOptions()
      options.isNetworkAccessAllowed = true
      options.resizeMode = .fast
      options.deliveryMode = .highQualityFormat

      let targetSize = size ?? CGSize(
        width: asset.pixelWidth,
        height: asset.pixelHeight
      )

      PHImageManager.default().requestImage(
        for: asset,
        targetSize: targetSize,
        contentMode: .default,
        options: options) { (image, info) in
          completion(image, info)
      }
    }

  /// Resolve UIImage synchronously
  ///
  /// - Parameter size: The target size
  /// - Returns: The resolved UIImage, otherwise nil
  public func resolve(completion: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
    return resolveTargetSize(nil, completion: completion)
  }

    /// Resolve mageData synchronously
    ///
    /// - Parameter size: The target size
    /// - Returns: The resolved Data, otherwise nil
    public func resolveImageData(completion: @escaping (Data?, [AnyHashable : Any]?) -> Void) {
      let options = PHImageRequestOptions()
      options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
            // TODO: - iOS 11 HEIF/HEIC图片转JPG
            // https://www.jianshu.com/p/a63c7d5d98a9
            if let imageData = imageData {
                if imageData.imageFormat == .HEIC || imageData.imageFormat == .HEIF {
                    if let ciImage = CIImage(data: imageData) {
                        let context = CIContext()
                        if let colorSpace = ciImage.colorSpace {
                            if #available(iOS 10.0, *) {
                                let data = context.jpegRepresentation(of: ciImage, colorSpace: colorSpace)
                                completion(data, info)
                            } else {
                                /*heic文件是目前苹果公司专门制作出来的一种图片格式们目前只适合苹果用户专用，和我们熟知的JPEG、PNG等同类，HEIC是一种图像格式，由苹果公司在近几年推出，iOS11、MacOS High Sierra（10.13）以及更新的版本支持该图片格式。并不是所有的iOS设备都默认支持HEIC图像格式，只有使用A9芯片及以上的设备才可以，比如搭载最新的A11仿生的芯片的iPhone X、iPhone8、iPhone8 Plus会默认使用HEIC图像格式。

                                作者：规规这小子真帅
                                链接：https://www.zhihu.com/question/266966789/answer/356730794
                                来源：知乎
                                著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。*/
                            }
                        }
                    }
                } else {
                    completion(imageData, info)
                }
            }
        }
    }

  /// Resolve an array of Image
  ///
  /// - Parameters:
  ///   - images: The array of Image
  ///   - size: The target size for all images
  ///   - completion: Called when operations completion
  public static func resolve(images: [Image], completion: @escaping ([UIImage?]) -> Void) {
    let dispatchGroup = DispatchGroup()
    var convertedImages = [Int: UIImage]()

    for (index, image) in images.enumerated() {
      dispatchGroup.enter()

      image.resolve(completion: { resolvedImage, _ in
        if let resolvedImage = resolvedImage {
          convertedImages[index] = resolvedImage
        }

        dispatchGroup.leave()
      })
    }

    dispatchGroup.notify(queue: .main, execute: {
      let sortedImages = convertedImages
        .sorted(by: { $0.key < $1.key })
        .map({ $0.value })
      completion(sortedImages)
    })
  }
}

// MARK: - Equatable

public func == (lhs: Image, rhs: Image) -> Bool {
  return lhs.asset == rhs.asset
}

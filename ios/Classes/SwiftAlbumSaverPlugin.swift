import Flutter
import UIKit
import MobileCoreServices
import Photos

public class SwiftAlbumSaverPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "album_saver", binaryMessenger: registrar.messenger())
    let instance = SwiftAlbumSaverPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

 public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
    case "saveToAlbum":
      let arguments = call.arguments as! Dictionary<String, Any>
      let filePath = arguments["filePath"] as! String
      let albumName = arguments["albumName"] as! String
      self.saveToAlbum(filePath: filePath, albumName: albumName,result: result)
    case "createAlbum":
      let arguments = call.arguments as! Dictionary<String, Any>
      let albumName = arguments["albumName"] as! String
      self.createAlbum(albumName: albumName, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func saveToAlbum(filePath: String, albumName: String, result: @escaping FlutterResult){        
    AlbumSaver(folderName: albumName).save(filePath: filePath)
    result(true)
  }

  private func createAlbum(albumName: String, result: @escaping FlutterResult){        
    AlbumSaver(folderName: albumName).createAlbumIfNeeded(completion: result)
    result(true)
  }

}

// ref https://stackoverflow.com/questions/28708846/how-to-save-image-to-custom-album
class AlbumSaver: NSObject {
  var albumName: String
  private var assetCollection: PHAssetCollection!

  init(folderName: String) {
    self.albumName = folderName
    super.init()
    if let assetCollection = fetchAssetCollectionForAlbum() {
      self.assetCollection = assetCollection
      return
    }
  }
    
  private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
    if PHPhotoLibrary.authorizationStatus() == .notDetermined {
      PHPhotoLibrary.requestAuthorization({ (status) in
        self.checkAuthorizationWithHandler(completion: completion)
      })
    }
    else if PHPhotoLibrary.authorizationStatus() == .authorized {
      self.createAlbumIfNeeded { (success) in
        if success {
          completion(true)
        } else {
          completion(false)
        }

      }

    }
    else {
      completion(false)
    }
  }

  func createAlbumIfNeeded(completion: @escaping ((_ success: Bool) -> Void)) {
    if let assetCollection = fetchAssetCollectionForAlbum() {
      // Album already exists
      self.assetCollection = assetCollection
      completion(true)
    } else {
      PHPhotoLibrary.shared().performChanges({
        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)   // create an asset collection with the album name
      }) { success, error in
        if success {
          self.assetCollection = self.fetchAssetCollectionForAlbum()
          completion(true)
        } else {
          // Unable to create album
          completion(false)
        }
      }
    }
  }

  private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", self.albumName)
    let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

    if let _: AnyObject = collection.firstObject {
      return collection.firstObject
    }
    return nil
  }

  func save(filePath: String) {
    self.checkAuthorizationWithHandler { (success) in
      if success, self.assetCollection != nil {
        PHPhotoLibrary.shared().performChanges({
          let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: filePath))
          let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
          if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest.addAssets(enumeration)
          }

        }, completionHandler: { (success, error) in
          if success {
            print("Successfully saved image to Camera Roll.")
          } else {
            print("Error writing to image library: \(error!.localizedDescription)")
          }
        })
      }
    }
  }
}

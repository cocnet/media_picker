//
//  DataCenter.swift
//  multi_image_picker
//
//  Created by johnson_zhong on 2021/10/29.
//

import Photos
import Foundation

public final class DataCenter: NSObject {
    @objc public static let shared = DataCenter()
    
    var assetStore = AssetStore()
    var settings = Settings()
    var defaultSelectMedia : String = ""
    var defaultSelectMediaAlbumId : Int = 0
    @objc public var fetchOptions : PHFetchOptions? = nil
    var mediaShowTypes : [PHAssetMediaType] = [PHAssetMediaType.image, PHAssetMediaType.video] {
        didSet {
            if mediaShowTypes.contains(PHAssetMediaType.image), mediaShowTypes.contains(PHAssetMediaType.video) {
                fetchOptions = PHFetchOptions()
                fetchOptions?.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            }else if mediaShowTypes.contains(PHAssetMediaType.image) {
                fetchOptions = PHFetchOptions()
                fetchOptions?.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                fetchOptions?.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            }else if mediaShowTypes.contains(PHAssetMediaType.video) {
                fetchOptions = PHFetchOptions()
                fetchOptions?.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
                fetchOptions?.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            }
        }
    }
    var selectionClosure: ((_ asset: PHAsset) -> Void)?
    var deselectionClosure: ((_ asset: PHAsset) -> Void)?
    var cancelClosure: ((_ assets: [Dictionary<String, String>], _ thumb : Bool) -> Void)?
    var finishClosure: ((_ assets: NSDictionary, _ success : Bool, _ error : NSError) -> Void)?
    var selectLimitReachedClosure: ((_ selectionLimit: Int) -> Void)?
    
    @objc public lazy var fetchResults: [PHAssetCollection] = { () -> [PHAssetCollection] in
        return fetchPhotoAlbum()
    }()
    
    @objc func resetAllData() {
        assetStore = AssetStore()
        settings = Settings()
        defaultSelectMedia = ""
        mediaShowTypes = [PHAssetMediaType.image, PHAssetMediaType.video]
        selectionClosure = nil
        deselectionClosure = nil
        cancelClosure = nil
        finishClosure = nil
        selectLimitReachedClosure = nil
    }
    
    @objc func refreshFetchResults() {
        fetchResults = fetchPhotoAlbum()
    }
    
    @objc public func fetchPhotoAlbum() -> Array<PHAssetCollection> {
        var results =  Array<PHAssetCollection>()
        let cameraRollResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        
        //最多的那个文件夹排第一
        var maxCount = 0
        var maxCountCollection : PHAssetCollection?
        for i in 0 ..< cameraRollResult.count {
            let collection = cameraRollResult.object(at: i)
            
            if (!(collection is PHAssetCollection)) {continue}
            if collection.assetCollectionSubtype == PHAssetCollectionSubtype.smartAlbumAllHidden {continue}
            
            let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            if assets.count > 0 {
                results.append(collection)
            }
            if maxCount < assets.count {
                maxCount = assets.count
                maxCountCollection = collection
            }
        }
        
        if maxCountCollection != nil, let index = results.firstIndex(of: maxCountCollection!) {
            let moveCollection = results.remove(at: index)
            results.insert(moveCollection, at: 0)
        }
        
//        增加其他类型的文件分类
        let albumResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        for i in 0 ..< albumResult.count {
            let collection = albumResult.object(at: i)
            
            if (!(collection is PHAssetCollection)) {continue}
            if collection.assetCollectionSubtype == PHAssetCollectionSubtype.smartAlbumAllHidden {continue}
        
            let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            if assets.count > 0 {
                results.append(collection)
            }
        }
        return results
    }
    
    
    public func fetchPhotoAlbumInfoList() -> [NSDictionary] {
        var result : [NSDictionary] = []
        let albums = fetchResults
        for i in stride(from: 0, through: albums.count - 1, by: 1) {
            let collection = albums[i]
            let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            guard let asset = assets.firstObject else { continue }
            let dictionary = NSMutableDictionary()
            dictionary.setValue(i, forKey: "albumId")
            dictionary.setValue(collection.localizedTitle, forKey: "albumName")
            dictionary.setValue(assets.count, forKey: "count")
            dictionary.setValue(asset.localIdentifier, forKey: "thumbIdentifier")
            dictionary.setValue(asset.pixelWidth, forKey: "thumbWidth")
            dictionary.setValue(asset.pixelHeight, forKey: "thumbHeigth")
            result.append(dictionary)
        }
        return result
    }
    
    public func getThumbnailSize(originSize: CGSize) -> CGSize {
        let thumbnailWidth : CGFloat = (UIScreen.main.bounds.size.width) / 3 * UIScreen.main.scale
        let pixelScale = CGFloat(originSize.width)/CGFloat(originSize.height)
        let thumbnailSize = CGSize(width: thumbnailWidth, height: thumbnailWidth/pixelScale)
        
        return thumbnailSize
    }
    
    func indexAndAssetsOfMainAlbum() -> (Int, PHFetchResult<PHAsset>)?  {
        if fetchResults.count > defaultSelectMediaAlbumId {
            let album = fetchResults[defaultSelectMediaAlbumId]
            let assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
            var index = 0
            if defaultSelectMedia.isEmpty {
                if let asset = assetStore.assets.first {
                    index = assets.index(of: asset)
                }
            }else {
                for i in 0 ..< assets.count {
                    let asset = assets.object(at: i)
                    if asset.localIdentifier == defaultSelectMedia {
                        index = i
                        break
                    }
                }
            }
            return (index, assets)
        }
        return nil
    }
    
    @objc func updateSelectMedias(selectMedias : [String]) {
        let assets : PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: selectMedias, options: nil)
        var sortedSelections : [PHAsset] = []
        for identify in selectMedias {
            for i in 0 ..< assets.count {
                if assets.object(at: i).localIdentifier == identify {
                    sortedSelections.append(assets.object(at: i))
                    break
                }
            }
        }
        assetStore.updateAssets(assets: sortedSelections)
    }
    
    @objc public func assetsWithAlbum(_ album: PHAssetCollection) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(in: album, options: fetchOptions)
    }
    
    public func downloadiCloudMediaDir() -> String{
        let thumbDir = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? NSTemporaryDirectory()) + "/multi_image_pick/thumb/download/"
        if !FileManager.default.fileExists(atPath: thumbDir) {
            do {
                try FileManager.default.createDirectory(atPath: thumbDir, withIntermediateDirectories: true, attributes: nil)
                var url = URL(fileURLWithPath: thumbDir, isDirectory: true)
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try url.setResourceValues(resourceValues)
            }catch{
                print(error)
            }
        }
        return thumbDir
    }
    
    public func downloadiCloudMediaPath(originName : String) -> String {
        return "\(downloadiCloudMediaDir())\(originName)"
    }
}

// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import Photos
import MBProgressHUD
final class PhotosViewController : UIViewController, CustomTitleViewDelegate, PhotoCollectionViewDataSourceDelegate, UICollectionViewDelegate {
    var cancelBarButton: UIBarButtonItem?;
    let titleContentView = CustomTitleView(frame: CGRect(x: 0, y: 0, width: 120, height: 34.0))
    
    var originBarButton: SSRadioButton = SSRadioButton(type: .custom)
    var doneBarButton: UIButton = UIButton(type: .custom)
    var bottomContentView : UIView = UIView()
    var topContentView : UIView = UIView()
    var bottomHeightConstraint : NSLayoutConstraint?
    var topHeightConstraint : NSLayoutConstraint?
    var downloadHud : MBProgressHUD?
    var albumListView: JYAlbumListView?
    
    let settings = DataCenter.shared.settings
    let assetStore = DataCenter.shared.assetStore
    
    private var photosDataSource: PhotoCollectionViewDataSource?
    private var doneBarButtonTitle: String = NSLocalizedString("Done", comment: "")
    private let originBarButtonTitle: String = NSLocalizedString("Origin", comment: "")
    
    private var collectionView : UICollectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: GridCollectionViewLayout())
    
    required init() {
        if !settings.doneButtonText.isEmpty {
            doneBarButtonTitle = settings.doneButtonText
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("b0rk: initWithCoder not implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.black
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset  = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)
        
        collectionView.backgroundColor = UIColor(hexString: "#141414")
        collectionView.allowsMultipleSelection = true
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
        let navBackButton = UIButton(frame: CGRect(x: -20, y: 0, width: 50, height: 44))
        navBackButton.setImage(UIImage.tz_imageNamed(fromMyBundle: "common_close"), for: .normal)
        navBackButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        navBackButton.imageView?.contentMode = .scaleAspectFit
        navBackButton.addTarget(self, action:#selector(PhotosViewController.cancelButtonPressed(_:)), for:.touchUpInside)
        backView.addSubview(navBackButton)
        cancelBarButton = UIBarButtonItem.init(customView: backView)

        titleContentView.titleView.text = "最近项目"
        titleContentView.delegate = self
        titleContentView.titleView.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleContentView.iconView.backgroundColor = UIColor.clear
        titleContentView.iconView.image = UIImage.tz_imageNamed(fromMyBundle: "nav_select_ablum_icon")
        titleContentView.iconView.width = 16;
        titleContentView.iconView.height = 16
        titleContentView.iconView.y = 9;
        
        let normalColor = settings.selectionStrokeColor
        doneBarButton.frame = CGRect(x: 0, y: 0, width: 98, height: 36)
        doneBarButton.backgroundColor = normalColor
        doneBarButton.setTitleColor(UIColor.white, for: .normal)
        doneBarButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        doneBarButton.setTitle(doneBarButtonTitle, for: .normal)
        doneBarButton.setBackgroundColor(color: normalColor, for: .normal)
        doneBarButton.setBackgroundColor(color: normalColor.withAlphaComponent(0.5), for: .disabled)
        doneBarButton.layer.masksToBounds = true
        doneBarButton.layer.cornerRadius = 18
        doneBarButton.center = CGPoint(x: bottomContentView.bounds.size.width - 40 - 5, y: bottomContentView.bounds.size.height/2.0)
        doneBarButton.addTarget(self, action: #selector(PhotosViewController.doneButtonPressed(_:)), for: .touchUpInside)
        doneBarButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        doneBarButton.translatesAutoresizingMaskIntoConstraints = false
        
        originBarButton.frame = CGRect(x: 60, y: 0, width: 100, height: 50)
        originBarButton.setTitle(originBarButtonTitle, for: .normal)
        originBarButton.isSelected = !settings.thumb
        originBarButton.circleRadius = 8.0
        originBarButton.circleColor = settings.selectionStrokeColor
        originBarButton.isHidden = settings.hiddenThumb
        originBarButton.center = CGPoint(x: bottomContentView.bounds.size.width/2.0, y: bottomContentView.bounds.size.height/2.0)
        originBarButton.addTarget(self, action: #selector(PhotosViewController.originButtonPressed(_:)), for: .touchUpInside)
        originBarButton.translatesAutoresizingMaskIntoConstraints = false
        
        navigationItem.leftBarButtonItem = cancelBarButton!
        navigationItem.titleView = titleContentView
        
        topContentView.backgroundColor = UIColor(hexString: "#1A2033")
        bottomContentView.backgroundColor = UIColor(hexString: "#1A2033")
        bottomContentView.addSubview(doneBarButton)
        bottomContentView.addSubview(originBarButton)
        bottomContentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(collectionView)
        self.view.addSubview(bottomContentView)
        self.view.addSubview(topContentView)
        
        let safeGuide = self.view
        bottomHeightConstraint = NSLayoutConstraint(item: bottomContentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 49)
        topHeightConstraint = NSLayoutConstraint(item: topContentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant:44)
        NSLayoutConstraint.activate([
            bottomHeightConstraint!,
            topHeightConstraint!,
            NSLayoutConstraint(item: bottomContentView, attribute: .bottom, relatedBy: .equal, toItem: safeGuide, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomContentView, attribute: .leading, relatedBy: .equal, toItem: safeGuide, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomContentView, attribute: .trailing, relatedBy: .equal, toItem: safeGuide, attribute: .trailing, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: topContentView, attribute: .top, relatedBy: .equal, toItem: safeGuide, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: topContentView, attribute: .leading, relatedBy: .equal, toItem: safeGuide, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: topContentView, attribute: .trailing, relatedBy: .equal, toItem: safeGuide, attribute: .trailing, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: doneBarButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 36),
            NSLayoutConstraint(item: doneBarButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 80),
            NSLayoutConstraint(item: doneBarButton, attribute: .top, relatedBy: .equal, toItem: bottomContentView, attribute: .top, multiplier: 1, constant: 9.5),
            NSLayoutConstraint(item: doneBarButton, attribute: .trailing, relatedBy: .equal, toItem: bottomContentView, attribute: .trailing, multiplier: 1, constant: -16),
            
            NSLayoutConstraint(item: originBarButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 49),
            NSLayoutConstraint(item: originBarButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 70),
            NSLayoutConstraint(item: originBarButton, attribute: .top, relatedBy: .equal, toItem: bottomContentView, attribute: .top, multiplier: 1, constant: 4),
            NSLayoutConstraint(item: originBarButton, attribute: .centerX, relatedBy: .equal, toItem: bottomContentView, attribute: .centerX, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: safeGuide, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: safeGuide, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: safeGuide, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: safeGuide, attribute: .trailing, multiplier: 1, constant: 0),
        ])
        
        initCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        bottomHeightConstraint?.constant = self.view.safeAreaInsets.bottom + 49
        topHeightConstraint?.constant = self.view.safeAreaInsets.top + 44
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtonState()
        collectionView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
       return .lightContent
   }
    
    func initCollectionView() {
        weak var hud = showHUDLoading(text: "加载中...");
        DispatchQueue.global().async { [weak self] in
            if DataCenter.shared.fetchResults.count ?? 0 > 0 {
                let album = DataCenter.shared.fetchResults[0]
                DispatchQueue.main.async {
                    self?.initializePhotosDataSource(album)
                    self?.updateAlbumTitle(album)
                    self?.collectionView.reloadData()
                    self?.hideHUDLoading(hud: hud)
                }
            }else{
                DispatchQueue.main.async {
                    self?.hideHUDLoading(hud: hud)
                    self?.showHUDAlert(text: NSLocalizedString("本地相册暂无图片与视频，快去拍摄吧", comment: ""))
                }
            }
        }
    }
    
    // MARK: Button actions
    @objc func cancelButtonPressed(_ sender: UIBarButtonItem) {
        var mediaList = [Dictionary<String, String>]()
        for asset in assetStore.assets {
            var dictionary = Dictionary<String, String>()
            dictionary["identify"] = asset.localIdentifier
            if asset.mediaType == .video {
                dictionary["fileType"] = "video"
            }else if asset.mediaType == .image {
              if let uti = asset.value(forKey: "uniformTypeIdentifier"), uti is String, (uti as! String).contains("gif") {
                dictionary["fileType"] = "image/gif"
              }else {
                dictionary["fileType"] = "image/jpeg"
              }
            }
            mediaList.append(dictionary)
        }
        DataCenter.shared.cancelClosure?(mediaList, settings.thumb)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtonPressed(_ sender: UIButton) {
        weak var weakSelf = self
        let thumb = !originBarButton.isSelected
        let assets = self.assetStore.assets
        doneBarButton.isEnabled = false
        
        DispatchQueue.global().async {
            let results = NSMutableDictionary();
            var identifiers = [String]();
            for asset in assets {
                identifiers.append(asset.localIdentifier)
            }
            results.setValue(identifiers, forKey: "identifiers")
            results.setValue(thumb, forKey: "thumb")
            
            DispatchQueue.main.async {
                weakSelf?.doneBarButton.isEnabled = true
                DataCenter.shared.finishClosure?(results, assets.count == identifiers.count, NSError())
                weakSelf?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func originButtonPressed(_ sender: UIButton) {
        originBarButton.isSelected = !originBarButton.isSelected
        settings.thumb = !originBarButton.isSelected
    }
    
    func customTitleViewDidAction(_ view: CustomTitleView) {
        if (albumListView == nil) {
            albumListView = JYAlbumListView(frame: CGRect(x: 0, y: self.navigationController?.navigationBar.bottom ?? 0, width: self.view.frame.size.width, height: self.view.frame.size.height - (self.navigationController?.navigationBar.bottom ?? 0) ))
            albumListView!.alpha = 0
            albumListView?.didSelectBlock = {[weak self](album : PHAssetCollection) in
                self?.initializePhotosDataSource(album)
                self?.updateAlbumTitle(album)
                self?.collectionView.reloadData()
                self?.titleContentView.isSelected = !(self?.titleContentView.isSelected ?? false)
                
                // 自动滑动到底部
                let indexPath = IndexPath(row: 0, section: 0)
                self?.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredVertically, animated: false)
                
                UIView.animate(withDuration: 0.2) {
                    self?.albumListView?.alpha = 0
                } completion: { _ in
                    self?.albumListView?.isHidden = true
                }
            }
            albumListView?.fillContent(DataCenter.shared.fetchResults)
            albumListView?.backgroundColor = UIColor(hexString: "#1A2033")
            self.view.addSubview(albumListView!)
        }
        
        view.isSelected = !view.isSelected
        view.isUserInteractionEnabled = false
        if (view.isSelected) {
            self.albumListView?.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.albumListView?.alpha = 1;
               
            } completion: { _ in
                view.isUserInteractionEnabled = true;
            }
        } else {
            self.albumListView?.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.albumListView?.alpha = 0;
            } completion: { _ in
                view.isUserInteractionEnabled = true;
            }
        }
            
    }
    
    // MARK: Private helper methods
    func updateButtonState() {
        if assetStore.assets.count > 0 {
            doneBarButton.setTitle("\(doneBarButtonTitle)(\(assetStore.count))", for: .normal)
        } else {
            doneBarButton.setTitle(doneBarButtonTitle, for: .normal)
        }

        doneBarButton.isEnabled = assetStore.assets.count > 0
        originBarButton.isSelected = !settings.thumb
    }

    func updateAlbumTitle(_ album: PHAssetCollection) {
        guard let title = album.localizedTitle else { return }
        titleContentView.titleView.text = title
    }
    
    func initializePhotosDataSource(_ album: PHAssetCollection) {
        photosDataSource = PhotoCollectionViewDataSource(album)
        photosDataSource?.delegate = self
        photosDataSource?.registerCellIdentifiersForCollectionView(collectionView)
        collectionView.dataSource = photosDataSource
        collectionView.delegate = self
        titleContentView.deSelectView()
    }
    
    func photoCollectionViewDataSourceDidReceiveCellSelectAction(_ cell: PhotoCell) {
        guard let photosDataSource = photosDataSource, collectionView.isUserInteractionEnabled else { return }
        guard let asset = cell.asset else { return }
        if !cell.thumbCanLoad {
            showHUDAlert(text: NSLocalizedString("媒体信息异常", comment: ""))
        }
        if !settings.selectType.isEmpty {
            if settings.selectType == "selectVideo"{
                if asset.mediaType != .video  {
                    showHUDAlert(text: NSLocalizedString("仅支持视频选择", comment: ""))
                    return;
                }
            }
            
            if settings.selectType == "selectImage" {
                if asset.mediaType != .image  {
                    showHUDAlert(text: NSLocalizedString("仅支持图片选择", comment: ""))
                    return;
                }
            }
            
            if settings.selectType == "selectSingleType" {
                if assetStore.isContainPic(), asset.mediaType != .image {
                    showHUDAlert(text: NSLocalizedString("暂不支持同时选择图片和视频", comment: ""))
                    return;
                }
                if assetStore.isContainVideo(), !assetStore.contains(asset) {
                    showHUDAlert(text: NSLocalizedString(asset.mediaType != .video ? "暂不支持同时选择图片和视频" : "只能选择一个视频", comment: ""))
                    return;
                }
            }
        }
      
        if (settings.videoCanPickLimitSize > 0 && asset.mediaType == PHAssetMediaType.video && asset.fileSize > Double(settings.videoCanPickLimitSize)) {
          showHUDAlert(text: "只能选择\(genMaxSizeTip(maxSize: settings.videoCanPickLimitSize))以内的视频哦")
          return;
        }
        
        if (settings.videoCanPickLimitDuration > 0 && asset.mediaType == PHAssetMediaType.video && asset.duration > Double(settings.videoCanPickLimitDuration)) {
          showHUDAlert(text: "只能选择\(genMaxDurationTip(maxDuration: settings.videoCanPickLimitDuration))以内的视频哦")
          return;
        }
        
        if (settings.imageCanPickLimitSize > 0 && asset.mediaType == PHAssetMediaType.image && asset.fileSize > Double(settings.imageCanPickLimitSize)) {
          showHUDAlert(text: "只能选择\(genMaxSizeTip(maxSize: settings.imageCanPickLimitSize))以内的图片哦")
          return;
        }
        
        if (settings.imageCanPickLimitPixel > 0 && asset.mediaType == PHAssetMediaType.image && asset.pixelWidth * asset.pixelHeight > settings.imageCanPickLimitPixel) {
          showHUDAlert(text: "只能选择\(genMaxPixelTip(maxDuration: settings.imageCanPickLimitPixel))像素以内的图片哦")
          return;
        }
        
        if (settings.imageCanPickLimitSide > 0 && asset.mediaType == PHAssetMediaType.image && (asset.pixelWidth > settings.imageCanPickLimitSide || asset.pixelHeight > settings.imageCanPickLimitSide)) {
          showHUDAlert(text: "只能选择边长小于\(settings.imageCanPickLimitSide)的图片哦")
          return;
        }
      
        if assetStore.contains(asset) {
            let canSelectBefore = assetStore.canAppend(settings.selectType, maxNum: settings.maxNumberOfSelections)
            assetStore.remove(asset)
            let canSelectAfter = assetStore.canAppend(settings.selectType, maxNum: settings.maxNumberOfSelections)
            updateButtonState()
            let selectedIndexPaths = assetStore.assets.compactMap({ (asset) -> IndexPath? in
                let index = photosDataSource.assets.index(of: asset)
                return IndexPath(item: index, section: 0)
            })
            if (canSelectBefore != canSelectAfter) {
                collectionView.reloadData()
            }else {
                UIView.setAnimationsEnabled(false)
                collectionView.reloadItems(at: selectedIndexPaths)
                UIView.setAnimationsEnabled(true)
            }
            cell.photoSelected = false
            DataCenter.shared.deselectionClosure?(asset)
        } else {
            if assetStore.count >= settings.maxNumberOfSelections {
                DataCenter.shared.selectLimitReachedClosure?(assetStore.count)
                showHUDAlert(text: NSLocalizedString("最多只能选择\(settings.maxNumberOfSelections)个文件", comment: ""))
            } else {
                let canSelectBefore = assetStore.canAppend(settings.selectType, maxNum: settings.maxNumberOfSelections)
                assetStore.append(asset)
                let canSelectAfter = assetStore.canAppend(settings.selectType, maxNum: settings.maxNumberOfSelections)
                if let selectionCharacter = settings.selectionCharacter {
                    cell.selectionString = String(selectionCharacter)
                } else {
                    cell.selectionString = String(assetStore.count)
                }
                cell.photoSelected = true
                updateButtonState()
                DataCenter.shared.selectionClosure?(asset)
                if (canSelectBefore != canSelectAfter) {
                    collectionView.reloadData()
                }
            }
        }
    }
  
    func photoCollectionViewDataSourceDidReceiveCellDownloadiCloudAction(_ cell: PhotoCell) {
        guard let asset = cell.asset else { return }
        guard asset.fileSize < Double(UIDevice.current.freeDiskSpaceInBytes) else {
            showHUDAlert(text: "磁盘空间不足，无法下载")
            return
        }
        guard let assetResource = PHAssetResource.assetResources(for: asset).first else { return }
        let filePath = DataCenter.shared.downloadiCloudMediaPath(originName: assetResource.originalFilename)
        downloadHud = showHUDPercentLoading(text: "正在下载资源")
        weak var hud = downloadHud
        weak var weakCell = cell
        weak var weakAsset = asset
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress in
            DispatchQueue.main.async {
                hud?.progress = Float(progress)
            }
        }
        hud?.button.addTarget(self, action: #selector(PhotosViewController.cancelHubLoading(_:)), for: .touchUpInside)
        if asset.mediaType == PHAssetMediaType.image || asset.mediaType == PHAssetMediaType.video {
            let fileUrl = URL(fileURLWithPath: filePath)
            PHAssetResourceManager.default().writeData(for: assetResource, toFile: fileUrl, options: options) { error in
                if (error == nil) {
                    DispatchQueue.main.async {
                        hud?.hide(animated: true)
                        weakCell?.asset = weakAsset
                    }
                } else {
                    do {
                        try FileManager.default.removeItem(at: fileUrl)
                    }catch {
                        print(error)
                    }
                }
            }
        }else {
            showHUDAlert(text: "不支持的媒体类型，暂不能下载")
        }
    }
    
    @objc func cancelHubLoading(_ sender: UIButton) {
        downloadHud?.hide(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell, let asset = cell.asset, !cell.photoDisable {
            let index = photosDataSource?.assets.index(of: asset) ?? 0
            navigationController?.pushViewController(PreviewViewController(currentAssetIndex: index, assets: photosDataSource?.assets ?? PHFetchResult<PHAsset>()), animated: true)
        }
        return true
    }
    
    func showHUDAlert(text: String) {
        JYToast.show(text)
    }
    
    func showHUDLoading(text: String) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.bezelView.backgroundColor = UIColor.darkGray
        hud.label.text = text
        hud.offset = CGPoint(x: 0, y: 0)
        return hud
    }
    
    func showHUDPercentLoading(text: String) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.determinate
        hud.bezelView.backgroundColor = UIColor.darkGray
        hud.label.text = text
        hud.offset = CGPoint(x: 0, y: 0)
        hud.button.setTitle("取消", for: .normal)
        return hud
    }
  
    func hideHUDLoading(hud : MBProgressHUD?) {
        hud?.hide(animated: true)
    }
  
    func genMaxSizeTip(maxSize : Int) -> String {
      let size = maxSize / 1024 / 1024;
      let sizeDesc = size >= 1024 ? "\(size/1024)GB" : "\(size)MB";
      return sizeDesc;
    }
    
    func genMaxDurationTip(maxDuration : Int) -> String {
      var desc = "";
      if (maxDuration >= 60 * 60) {
        desc = "\(maxDuration / 60 / 60)小时"
      }else if (maxDuration >= 60) {
        desc = "\(maxDuration / 60)分钟"
      }else {
        desc = "\(maxDuration)秒"
      }
      return desc
    }
    
    func genMaxPixelTip(maxDuration : Int) -> String {
      var desc = "\(maxDuration)";
      if (maxDuration >= 10000 * 10000) {
        desc = "\(maxDuration / 10000 / 10000)亿"
      }else if (maxDuration >= 10000) {
        desc = "\(maxDuration / 10000)万"
      }
      return desc
    }
}

// MARK: UIPopoverPresentationControllerDelegate
extension PhotosViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        titleContentView.deSelectView()
        return true
    }
}

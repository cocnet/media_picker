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
import AVKit
import MBProgressHUD

final class PreviewViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SelectionViewDelegate, PreviewCellDelegate {
    private let cellIdentifier = "PreviewCollectionCell"
//    如果是正在加载View的时候不应该去监听ScrollViewDelegate
    var loadingView = true
    
    var currentAssetIndex : Int = 0
    var assets: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    
    var collectionView : UICollectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    var cancelBarButton: UIBarButtonItem = UIBarButtonItem(image: UIImage.tz_imageNamed(fromMyBundle: "nav_back_btn").withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
    var selectBarButton: UIBarButtonItem = UIBarButtonItem()
    var icloudBarButton: UIBarButtonItem = UIBarButtonItem()
    var selectionView: SelectionView = SelectionView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    var icloudBtn: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let assetStore = DataCenter.shared.assetStore
    let settings = DataCenter.shared.settings
    var downloadHud : MBProgressHUD?
    
    private var doneBarButtonTitle: String = NSLocalizedString("Done", comment: "")
    private let originBarButtonTitle: String = NSLocalizedString("Origin", comment: "")
    var originBarButton: SSRadioButton = SSRadioButton(type: .custom)
    var doneBarButton: UIButton = UIButton(type: .custom)
    var bottomContentView : UIView = UIView(frame: CGRect.zero)
    var bottomHeightConstraint : NSLayoutConstraint?
    
    required init(currentAssetIndex : Int?, assets: PHFetchResult<PHAsset>?) {
        super.init(nibName: nil, bundle: nil)
        
        if !settings.doneButtonText.isEmpty {
            doneBarButtonTitle = settings.doneButtonText
        }
        view.backgroundColor = UIColor.black
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = UIScreen.main.bounds.size
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(PreviewCollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        self.view.addSubview(collectionView)
        
        let normalColor = settings.selectionStrokeColor
        doneBarButton.frame = CGRect(x: 0, y: 0, width: 98, height: 36)
        doneBarButton.backgroundColor = normalColor
        doneBarButton.setTitleColor(UIColor.white, for: .normal)
        doneBarButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        doneBarButton.setTitle(doneBarButtonTitle, for: .normal)
        doneBarButton.setBackgroundColor(color: normalColor, for: .normal)
        doneBarButton.setBackgroundColor(color: normalColor.withAlphaComponent(0.5), for: .disabled)
        doneBarButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        doneBarButton.titleLabel?.adjustsFontSizeToFitWidth = true
        doneBarButton.layer.masksToBounds = true
        doneBarButton.layer.cornerRadius = 18
        doneBarButton.center = CGPoint(x: bottomContentView.bounds.size.width - 40 - 5, y: bottomContentView.bounds.size.height/2.0)
        doneBarButton.addTarget(self, action: #selector(PreviewViewController.doneButtonPressed(_:)), for: .touchUpInside)
        doneBarButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        doneBarButton.translatesAutoresizingMaskIntoConstraints = false
        
        originBarButton.frame = CGRect(x: 60, y: 0, width: 100, height: 50)
        originBarButton.setTitle(originBarButtonTitle, for: .normal)
        originBarButton.isHidden = settings.hiddenThumb
        originBarButton.isSelected = !settings.thumb
        originBarButton.circleRadius = 8.0
        originBarButton.circleColor = settings.selectionStrokeColor
        originBarButton.center = CGPoint(x: bottomContentView.bounds.size.width/2.0, y: bottomContentView.bounds.size.height/2.0)
        originBarButton.addTarget(self, action: #selector(PreviewViewController.originButtonPressed(_:)), for: .touchUpInside)
        originBarButton.translatesAutoresizingMaskIntoConstraints = false
        
        bottomContentView.backgroundColor = UIColor(hexString: "#1A2033")
        bottomContentView.addSubview(doneBarButton)
        bottomContentView.addSubview(originBarButton)
        bottomContentView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bottomContentView)
        
        let safeGuide = self.view
        bottomHeightConstraint = NSLayoutConstraint(item: bottomContentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 49)
        NSLayoutConstraint.activate([
            bottomHeightConstraint!,
            NSLayoutConstraint(item: bottomContentView, attribute: .bottom, relatedBy: .equal, toItem: safeGuide, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomContentView, attribute: .leading, relatedBy: .equal, toItem: safeGuide, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomContentView, attribute: .trailing, relatedBy: .equal, toItem: safeGuide, attribute: .trailing, multiplier: 1, constant: 0),
            
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

        cancelBarButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        cancelBarButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray], for: .highlighted)
        cancelBarButton.target = self
        cancelBarButton.action = #selector(PreviewViewController.cancelButtonPressed(_:))
        
        icloudBtn.backgroundColor = UIColor.clear
        icloudBtn.layer.masksToBounds = true
        icloudBtn.setImage(UIImage.tz_imageNamed(fromMyBundle: "icloud_down"), for: .normal)
        icloudBtn.addTarget(self, action: #selector(icloudBtnDidAction), for: .touchUpInside)
        
        selectBarButton = UIBarButtonItem(customView: selectionView);
        icloudBarButton = UIBarButtonItem(customView: icloudBtn);
        
        selectionView.offset = 7
        selectionView.delegate = self
        
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = selectBarButton
        
        if let currentAssetIndex = currentAssetIndex, let assets = assets {
            self.currentAssetIndex = currentAssetIndex
            self.assets = assets
        }else {
            self.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.contentOffset = CGPoint(x: collectionView.bounds.width * CGFloat(self.currentAssetIndex), y: collectionView.contentOffset.y)
        updateButtonState()
        refreshSelectIndex()
        loadingView = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
       return .lightContent
   }
    
    func reloadData()  {
        weak var hud = showHUDLoading(text: "加载中...")
        DispatchQueue.global().async { [weak self] in
            let result = DataCenter.shared.indexAndAssetsOfMainAlbum()
            DispatchQueue.main.async { [weak self] in
                if let currentAssetIndex = result?.0, let assets = result?.1, let strongSelf = self {
                    strongSelf.loadingView = true
                    strongSelf.currentAssetIndex = currentAssetIndex
                    strongSelf.assets = assets
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.contentOffset = CGPoint(x: strongSelf.collectionView.bounds.width * CGFloat(strongSelf.currentAssetIndex), y: strongSelf.collectionView.contentOffset.y)
                    strongSelf.updateButtonState()
                    strongSelf.refreshSelectIndex()
                    strongSelf.loadingView = false
                    strongSelf.hideHUDLoading(hud: hud)
                }
            }
        }
    }
    
    func showHUDLoading(text: String) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.bezelView.backgroundColor = UIColor.darkGray
        hud.label.text = text
        hud.offset = CGPoint(x: 0, y: 0)
        return hud
    }
    
    func hideHUDLoading(hud : MBProgressHUD?) {
        hud?.hide(animated: true)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =  UIColor(hexString: "141414")
    }
  
    override func viewDidLayoutSubviews() {
        bottomHeightConstraint?.constant = self.view.safeAreaInsets.bottom + 49
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingView = true
    }
    
    // MARK: Private helper methods
    func updateButtonState() {
        if assetStore.assets.count > 0 {
            doneBarButton.setTitle("\(doneBarButtonTitle)(\(assetStore.count))", for: .normal)
        } else {
            doneBarButton.setTitle(doneBarButtonTitle, for: .normal)
        }

        originBarButton.isSelected = !settings.thumb
    }
    
    func refreshSelectIndex() {
        if currentAssetIndex < self.assets.count {
            let asset = assets[currentAssetIndex]
            let selectIndex = isSelectImageItem(asset)
            if selectIndex > 0 {
                selectionView.selectionString = "\(selectIndex)"
                selectionView.selected = true
            }else {
                selectionView.selectionString = ""
                selectionView.selected = false
            }
            if (DataCenter.shared.settings.mediaCanDownloadFromiCloud) {
                let resourceArray = PHAssetResource.assetResources(for: asset);
                let locallyAvailable = resourceArray.first?.value(forKey: "locallyAvailable")
                let localPath = DataCenter.shared.downloadiCloudMediaPath(originName: asset.originalFilename ?? "")
                if (locallyAvailable is Bool && ((locallyAvailable as? Bool) ?? true) || FileManager.default.fileExists(atPath: localPath)) {
                    navigationItem.rightBarButtonItem = selectBarButton
                    doneBarButton.isEnabled = true
                }else {
                    navigationItem.rightBarButtonItem = icloudBarButton
                    doneBarButton.isEnabled = false
                }
            }else {
                navigationItem.rightBarButtonItem = selectBarButton
                doneBarButton.isEnabled = true
            }
        }
        
        selectionView.disabled = assetStore.count >= settings.maxNumberOfSelections
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = collectionView.cellForItem(at: indexPath) as! PreviewCollectionViewCell
        cell.cellDidReceiveTapAction()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PreviewCollectionViewCell
        cell.asset = assets[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            (cell as! PreviewCollectionViewCell).stopPlayVideo()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !loadingView {
            let index = Int(round(scrollView.contentOffset.x/scrollView.bounds.width))
            if currentAssetIndex != index {
                currentAssetIndex = index
                refreshSelectIndex()
            }
        }
    }
    
    @objc func cancelButtonPressed(_ sender: UIBarButtonItem) {
        for cell in collectionView.visibleCells {
            (cell as! PreviewCollectionViewCell).stopPlayVideo()
        }
        if self.navigationController?.viewControllers[0] == self {
            let dictionary = needSelectedIdentify()
            DataCenter.shared.cancelClosure?(dictionary, settings.thumb)
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func selectMediaItem(_ asset : PHAsset) -> Int {
        let selectType = settings.selectType
        if !selectType.isEmpty {
            if selectType == "selectVideo"{
                if asset.mediaType != .video  {
                    showHUDAlert(text: NSLocalizedString("仅支持视频选择", comment: ""))
                    return -1;
                }
            }
            
            if selectType == "selectImage" {
                if asset.mediaType != .image  {
                    showHUDAlert(text: NSLocalizedString("仅支持图片选择", comment: ""))
                    return -1;
                }
            }
            
            if selectType == "selectSingleType" {
                if self.assetStore.isContainPic(), asset.mediaType != .image {
                    showHUDAlert(text: NSLocalizedString("暂不支持同时选择图片和视频", comment: ""))
                    return -1;
                }
                if self.assetStore.isContainVideo(), !self.assetStore.contains(asset) {
                    showHUDAlert(text: NSLocalizedString(asset.mediaType != .video ? "暂不支持同时选择图片和视频" : "只能选择一个视频", comment: ""))
                    return -1;
                }
            }
        }
        
        if self.assetStore.contains(asset) {
            self.assetStore.remove(asset)
            DataCenter.shared.deselectionClosure?(asset)
            updateButtonState()
            return -1
        } else if self.assetStore.count < settings.maxNumberOfSelections {
            self.assetStore.append(asset)
            DataCenter.shared.selectionClosure?(asset)
            updateButtonState()
            return self.assetStore.count
        }
        return -1
    }
    
    func selectViewDidSelectDidAction(_ view: SelectionView) {
        if let cell = collectionView.visibleCells.first, let asset = (cell as! PreviewCollectionViewCell).asset {
            if !(cell as! PreviewCollectionViewCell).thumbCanLoad {
                showHUDAlert(text: NSLocalizedString("媒体信息异常", comment: ""))
            }else if let error = canSelectImageItem(asset) {
                showHUDAlert(text: NSLocalizedString(error.domain, comment: ""))
            }else {
                let selectIndex = selectMediaItem(asset)
                if selectIndex > 0 {
                    selectionView.selectionString = "\(selectIndex)"
                    selectionView.selected = true
                }else if selectIndex == -1 {
                    selectionView.selectionString = ""
                    selectionView.selected = false
                }
                selectionView.disabled = assetStore.count >= settings.maxNumberOfSelections
            }
        }
    }
    
    func previewCellDidReceiveTapAction(_ cell: PreviewCollectionViewCell) {
        let hidden = bottomContentView.isHidden
        self.navigationController?.setNavigationBarHidden(!hidden, animated: false)
        bottomContentView.isHidden = !hidden
    }
  
    @objc func icloudBtnDidAction() {
        guard let cell = collectionView.visibleCells.first, let asset = (cell as! PreviewCollectionViewCell).asset else { return }
        guard asset.fileSize < Double(UIDevice.current.freeDiskSpaceInBytes) else {
            showHUDAlert(text: "磁盘空间不足，无法下载")
            return
        }
        guard let assetResource = PHAssetResource.assetResources(for: asset).first else { return }
        let filePath = DataCenter.shared.downloadiCloudMediaPath(originName: assetResource.originalFilename)
        downloadHud = showHUDPercentLoading(text: "正在下载资源")
        weak var hud = downloadHud
        weak var weakCell = cell
        weak var weakSelf = self
        weak var weakAsset = asset
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress in
            DispatchQueue.main.async {
                hud?.progress = Float(progress)
            }
        }
        hud?.button.addTarget(self, action: #selector(PreviewViewController.cancelHubLoading(_:)), for: .touchUpInside)
        if asset.mediaType == PHAssetMediaType.image || asset.mediaType == PHAssetMediaType.video {
            let fileUrl = URL(fileURLWithPath: filePath)
            PHAssetResourceManager.default().writeData(for: assetResource, toFile: fileUrl, options: options) { error in
                if (error == nil) {
                    DispatchQueue.main.async {
                        hud?.hide(animated: true)
                        weakSelf?.refreshSelectIndex()
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
    
    func showHUDPercentLoading(text: String) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.determinate
        hud.bezelView.backgroundColor = UIColor.darkGray
        hud.label.text = text
        hud.offset = CGPoint(x: 0, y: 0)
        hud.button.setTitle("取消", for: .normal)
        return hud
    }
    
    @objc func cancelHubLoading(_ sender: UIButton) {
        downloadHud?.hide(animated: true)
    }
    
    func needSelectedIdentify() -> [Dictionary<String, String>]{
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
        return mediaList
    }
    
    func isSelectImageItem(_ asset : PHAsset) -> Int {
        return (assetStore.assets.firstIndex(of: asset) ?? -1) + 1
    }
    
    func canSelectImageItem(_ asset : PHAsset) -> NSError? {
        if assetStore.contains(asset) {
            return nil
        }else if assetStore.count >= settings.maxNumberOfSelections {
            DataCenter.shared.selectLimitReachedClosure?(assetStore.count)
            return NSError(domain: "只能最多选择\(settings.maxNumberOfSelections)个文件哦", code: 5, userInfo: nil)
        }else if(settings.videoCanPickLimitSize > 0 && asset.mediaType == PHAssetMediaType.video && asset.fileSize > Double(settings.videoCanPickLimitSize)){
          return NSError(domain: "只能选择\(genMaxSizeTip(maxSize: settings.videoCanPickLimitSize))以内的视频哦", code: 5, userInfo: nil)
        }else if(settings.videoCanPickLimitDuration > 0 && asset.mediaType == PHAssetMediaType.video && asset.duration > Double(settings.videoCanPickLimitDuration)){
          return NSError(domain: "只能选择\(genMaxDurationTip(maxDuration: settings.videoCanPickLimitDuration))以内的视频哦", code: 5, userInfo: nil)
        }else if (settings.imageCanPickLimitSize > 0 && asset.mediaType == PHAssetMediaType.image && asset.fileSize > Double(settings.imageCanPickLimitSize)) {
          return NSError(domain: "只能选择\(genMaxSizeTip(maxSize: settings.imageCanPickLimitSize))以内的图片哦", code: 5, userInfo: nil)
        }else if (settings.imageCanPickLimitPixel > 0 && asset.mediaType == PHAssetMediaType.image && (asset.pixelWidth * asset.pixelHeight > settings.imageCanPickLimitPixel)) {
          return NSError(domain: "只能选择\(genMaxPixelTip(maxDuration: settings.imageCanPickLimitPixel))像素以内的图片哦", code: 5, userInfo: nil)
        }else if (settings.imageCanPickLimitSide > 0 && (asset.pixelWidth > settings.imageCanPickLimitSide || asset.pixelHeight > settings.imageCanPickLimitSide)) {
          return NSError(domain: "只能选择边长小于\(settings.imageCanPickLimitSide)的图片哦", code: 5, userInfo: nil)
        }
        return nil
    }
    
    @objc func originButtonPressed(_ sender: UIButton) {
        originBarButton.isSelected = !originBarButton.isSelected
        settings.thumb = !originBarButton.isSelected
    }
    
    @objc func doneButtonPressed(_ sender: UIButton) {
        if self.assetStore.assets.count < 1 {
            if let cell = collectionView.visibleCells.first, let asset = (cell as! PreviewCollectionViewCell).asset {
                if !(cell as! PreviewCollectionViewCell).thumbCanLoad {
                    showHUDAlert(text: NSLocalizedString("媒体信息异常", comment: ""))
                    return
                }else if let error = canSelectImageItem(asset) {
                    showHUDAlert(text: NSLocalizedString(error.domain, comment: ""))
                    return
                }else {
                    let selectIndex = selectMediaItem(asset)
                    if selectIndex > 0 {
                        selectionView.selectionString = "\(selectIndex)"
                        selectionView.selected = true
                    }else if selectIndex == -1 {
                        selectionView.selectionString = ""
                        selectionView.selected = false
                    }
                }
            }
        }
        weak var weakSelf = self
        let thumb = !originBarButton.isSelected
        let assets = self.assetStore.assets
        if assets.count < 1 {
            return
        }
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
    
    func showHUDAlert(text: String) {
        JYToast.show(text)
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

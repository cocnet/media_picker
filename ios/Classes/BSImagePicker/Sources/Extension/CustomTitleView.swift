//
//  CustomTitleView.swift
//  multi_image_picker
//
//  Created by johnson_zhong on 2020/5/7.
//

import Foundation
import CoreImage

@objc public protocol CustomTitleViewDelegate {
    @objc func customTitleViewDidAction(_ view : CustomTitleView)
}

public class CustomTitleView: UIView {
    @objc public let iconView = UIImageView()
    @objc public let titleView = UILabel()
    @objc public var isSelected = false
    
    @objc public weak var delegate : CustomTitleViewDelegate?
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 120, height: 34.0)
    }
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let iconWidth : CGFloat = 25.0
        let iconHeight : CGFloat = 25.0
        
        titleView.frame = CGRect(x: 5, y: 0, width: frame.size.width - iconWidth - 10, height: frame.size.height)
        titleView.backgroundColor = UIColor.clear
        titleView.textColor = UIColor.white
        titleView.textAlignment = .center
        titleView.center = CGPoint(x: (frame.size.width - iconWidth)/2.0, y: frame.size.height/2.0)
        self.addSubview(titleView)

        iconView.frame = CGRect(x: frame.size.width - iconWidth, y: 0, width: iconWidth, height: iconHeight)
        iconView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)

        iconView.image = UIImage.tz_imageNamed(fromMyBundle: "arrow_down_more")
        iconView.contentMode = .scaleAspectFit
        iconView.layer.masksToBounds = true
        iconView.layer.cornerRadius = iconWidth/2.0
        iconView.center = CGPoint(x: frame.size.width - iconWidth/2 - 5, y: frame.size.height/2.0)
        self.addSubview(iconView)
    }
    
    @objc required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func deSelectView() {
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3) {
            if (weakSelf != nil) {
                weakSelf!.iconView.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        weak var weakSelf = self
        UIView.animate(withDuration: 0.15) {
            if (weakSelf != nil) {
                weakSelf?.titleView.alpha = 0.3
            }
        }
        super.touchesBegan(touches, with: event)
    }
    
    @objc public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3) {
            if (weakSelf != nil) {
                weakSelf?.titleView.alpha = 1.0
                weakSelf!.iconView.transform = weakSelf!.iconView.transform.rotated(by: .pi)
            }
        }
        self.delegate?.customTitleViewDidAction(self)
        super.touchesEnded(touches, with: event)
    }
    
    @objc public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3) {
            if (weakSelf != nil) {
                weakSelf?.titleView.alpha = 1.0
                weakSelf!.iconView.transform = weakSelf!.iconView.transform.rotated(by: .pi)
            }
        }
        super.touchesCancelled(touches, with: event)
    }
}

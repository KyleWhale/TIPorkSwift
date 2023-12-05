//
//  BMVolumeBrightnessView.swift
//  BMPlayer
//
//  Created by 罗建 on 2023/8/15.
//

import UIKit

open class BMVolumeBrightnessView: UIView {
    
    open lazy var imageView: UIImageView = .init()
    
    open lazy var progressView: UIProgressView = {
        let progressView: UIProgressView = .init()
        progressView.trackTintColor = .init(white: 1, alpha: 0.1)
        progressView.tintColor = .white
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        return progressView
    }()
    
    open var isShow = false
    
    open var delayItem: DispatchWorkItem?
    
    //MARK: - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUIComponents()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUIComponents()
    }
        
    func setupUIComponents() {
        self.backgroundColor = .init(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.5)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.alpha = 0
        
        self.addSubview(self.imageView)
        self.addSubview(self.progressView)
        
        self.imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        self.progressView.snp.makeConstraints { make in
            make.left.equalTo(self.imageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
            make.height.equalTo(4)
        }
        
    }
    
    open func showAnimation(isShow: Bool) {
        if self.isShow == isShow {return}
        
        self.isShow = isShow
        
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            guard let self = self else {return}
            self.alpha = isShow ? 1.0 : 0.0
        }) { [weak self] _ in
            guard let self = self else {return}
            if isShow {
                self.autoFadeOutControlViewWithAnimation()
            }
        }
    }
    
    open func autoFadeOutControlViewWithAnimation() {
        self.delayItem?.cancel()
        self.delayItem = DispatchWorkItem { [weak self] in
            guard let self = self else {return}
            self.alpha = 0
            self.isShow = false
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: self.delayItem!)
    }
        
    open func prepareToDealloc() {
        self.delayItem = nil
    }
        
}

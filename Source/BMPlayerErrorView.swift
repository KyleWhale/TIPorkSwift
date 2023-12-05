//
//  BMPlayerErrorView.swift
//  BMPlayer
//
//  Created by 罗建 on 2023/8/14.
//

import UIKit

open class BMPlayerErrorView: UIView {
    
    open lazy var backButton: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_back"), for: .normal)
        btn.tag = BMPlayerControlTapType.back.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var errorLab: UILabel = {
        let lab: UILabel = .init()
        lab.font = .systemFont(ofSize: 12)
        lab.textColor = .init(red: 236 / 255.0, green: 236 / 255.0, blue: 236 / 255.0, alpha: 1)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        return lab
    }()
    
    open weak var delegate: BMPlayerControlViewDelegate?
    
    open var isFullscreen  = false
        
    //MARK: - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUIComponents()
        addSnapKitConstraint()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUIComponents()
        addSnapKitConstraint()
    }
        
    func setupUIComponents() {
        self.backgroundColor = .init(red: 17 / 255.0, green: 18 / 255.0, blue: 24 / 255.0, alpha: 1)
        
        self.addSubview(self.backButton)
        self.addSubview(self.errorLab)
    }
    
    func addSnapKitConstraint() {
        self.backButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        self.errorLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(45)
            make.centerY.equalToSuperview()
        }
    }
    
    open func updateUI(_ isForFullScreen: Bool) {
        isFullscreen = isForFullScreen
        
        self.backButton.snp.remakeConstraints { make in
            if isForFullScreen {
                make.top.equalToSuperview().inset(24)
                make.left.equalToSuperview().inset(50)
            } else {
                make.top.left.equalToSuperview()
            }
            
            make.width.height.equalTo(44)
        }
    }
    
    //MARK: - Response Action
    
    @objc
    open func onButtonPressed(_ button: UIButton) {
        self.delegate?.controlView(controlView: .init(), didPressButton: button)
    }
    
}

//
//  BMPlayerControlView.swift
//  Pods
//
//  Created by BrikerMan on 16/4/29.
//
//

import UIKit
import NVActivityIndicatorView
import LQGConstant

public enum BMPlayerControlTapType: Int {
    case scale = 1000
    case speed
    case subtitle
    
    case play
    case minus
    case plus
    case replay
    case next
    case episodes
    
    case back
    case fullscreen
    case lock
    case unlock
    
    case share
    case collection
    case joinVIP
    case tv
}

@objc
public protocol BMPlayerControlViewDelegate: class {
        
    func controlView(controlView: BMPlayerControlView, didPressButton button: UIButton)
    
    func controlView(controlView: BMPlayerControlView, slider: UISlider, onSliderEvent event: UIControl.Event)
        
}

open class BMPlayerControlView: UIView {
            
    //MARK: 视图
    
    // 字幕
    open lazy var subtitleBackView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .init(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.4)
        view.layer.cornerRadius = 5
        view.alpha = 0
        return view
    }()
    
    open lazy var subtitleLabel: UILabel = {
        let lab: UILabel = .init()
        lab.font = .systemFont(ofSize: 18)
        lab.textColor = .init(red: 236 / 255.0, green: 236 / 255.0, blue: 236 / 255.0, alpha: 1)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        return lab
    }()
    
    open var subtitleAttribute: [NSAttributedString.Key : Any]?
    
    // 主遮罩
    open lazy var mainMaskView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .init(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.5)
        view.clipsToBounds = true
        return view
    }()
    
    // 封面
    open lazy var maskImageView: UIImageView = .init()
    
    // 处理横竖屏不同的缩进
    open lazy var mainWrapperView: UIView = .init()
    
    // 顶部功能
    open lazy var topMaskView: UIView = .init()
    
    open lazy var backButton: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_back"), for: .normal)
        btn.tag = BMPlayerControlTapType.back.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var titleLabel: UILabel = {
        let lab: UILabel = .init()
        lab.font = .boldSystemFont(ofSize: 18)
        lab.textColor = .init(red: 236 / 255.0, green: 236 / 255.0, blue: 236 / 255.0, alpha: 1)
        return lab
    }()
    
    open lazy var shareBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_share"), for: .normal)
        btn.tag = BMPlayerControlTapType.share.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var collectionBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_collection"), for: .normal)
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_collection_s"), for: .selected)
        btn.isSelected = BMPlayerManager.shared.collection
        btn.tag = BMPlayerControlTapType.collection.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var tvBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_tv"), for: .normal)
        btn.tag = BMPlayerControlTapType.tv.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var ccTopBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_cc"), for: .normal)
        btn.tag = BMPlayerControlTapType.subtitle.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var vipBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_vip"), for: .normal)
        btn.tag = BMPlayerControlTapType.joinVIP.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    // 中间功能
    open lazy var centerMaskView: UIView = .init()
    
    open lazy var lockBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_unlock"), for: .normal)
        btn.tag = BMPlayerControlTapType.lock.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var minusBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_minus"), for: .normal)
        btn.tag = BMPlayerControlTapType.minus.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var playCenterBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_play_large"), for: .normal)
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_pause_large"), for: .selected)
        btn.tag = BMPlayerControlTapType.play.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var plusBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_plus"), for: .normal)
        btn.tag = BMPlayerControlTapType.plus.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var replayButton: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_replay"), for: .normal)
        btn.tag = BMPlayerControlTapType.replay.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    // 底部功能
    open lazy var bottomMaskView: UIView = {
        let view: UIView = .init()
        return view
    }()
    
    open lazy var playBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_play"), for: .normal)
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_pause"), for: .selected)
        btn.tag = BMPlayerControlTapType.play.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var nextBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_next"), for: .normal)
        btn.tag = BMPlayerControlTapType.next.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
        
    open lazy var speedBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_speed_1.0x"), for: .normal)
        btn.tag = BMPlayerControlTapType.speed.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var episodesBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_episodes"), for: .normal)
        btn.tag = BMPlayerControlTapType.episodes.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var ccBottomBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_cc"), for: .normal)
        btn.tag = BMPlayerControlTapType.subtitle.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var scaleBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_scale_1"), for: .normal)
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_scale_2"), for: .selected)
        btn.tag = BMPlayerControlTapType.scale.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    open lazy var fullscreenBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_fullscreen"), for: .normal)
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_portialscreen"), for: .selected)
        btn.tag = BMPlayerControlTapType.fullscreen.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
            
    open lazy var currentTimeLabel: UILabel = {
        let lab: UILabel = .init()
        lab.font = .systemFont(ofSize: 12)
        lab.textColor = .init(red: 236 / 255.0, green: 236 / 255.0, blue: 236 / 255.0, alpha: 1)
        lab.textAlignment = .left
        lab.text = "00:00"
        return lab
    }()
    
    open lazy var progressView: UIProgressView = {
        let progressView: UIProgressView = .init()
        progressView.tintColor = .init(red: 119 / 255.0, green: 119 / 255.0, blue: 120 / 255.0, alpha: 1)
        progressView.trackTintColor = .init(red: 119 / 255.0, green: 119 / 255.0, blue: 120 / 255.0, alpha: 0.5)
        return progressView
    }()
    
    open lazy var timeSlider: BMTimeSlider = {
        let timeSlider: BMTimeSlider = .init()
        timeSlider.setThumbImage(BMImageResourcePath("Pod_Asset_BMPlayer_slider_thumb"), for: .normal)
        timeSlider.maximumTrackTintColor = UIColor.clear
        timeSlider.minimumTrackTintColor = .init(red: 60 / 255.0, green: 222 / 255.0, blue: 244 / 255.0, alpha: 1)
        timeSlider.maximumValue = 1.0
        timeSlider.minimumValue = 0.0
        timeSlider.value = 0.0
        return timeSlider
    }()
        
    open lazy var totalTimeLabel: UILabel = {
        let lab: UILabel = .init()
        lab.font = .systemFont(ofSize: 12)
        lab.textColor = .init(red: 236 / 255.0, green: 236 / 255.0, blue: 236 / 255.0, alpha: 1)
        lab.textAlignment = .left
        lab.text = "00:00"
        return lab
    }()
    
    // 解锁
    open lazy var unlockBtn: UIButton = {
        let btn: UIButton = .init()
        btn.setImage(BMImageResourcePath("Pod_Asset_BMPlayer_lock"), for: .normal)
        btn.tag = BMPlayerControlTapType.unlock.rawValue
        btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return btn
    }()
    
    // 加载中
    open lazy var loadingIndicator: NVActivityIndicatorView = {
        let loadingIndicator: NVActivityIndicatorView  = NVActivityIndicatorView(frame:  CGRect(x: 0, y: 0, width: 30, height: 30))
        loadingIndicator.type  = BMPlayerConf.loaderType
        loadingIndicator.color = BMPlayerConf.tintColor
        return loadingIndicator
    }()
        
    // 进度调整
    open lazy var seekToView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .init(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.4)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    open lazy var seekToViewImage: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.image = BMImageResourcePath("Pod_Asset_BMPlayer_seek_to_image")
        return imageView
    }()
    
    open lazy var seekToLabel: UILabel = {
        let lab: UILabel = .init()
        lab.font = .systemFont(ofSize: 15)
        lab.textColor = .init(red: 236 / 255.0, green: 236 / 255.0, blue: 236 / 255.0, alpha: 1)
        lab.textAlignment = .center
        return lab
    }()
            
    // 手势
    open var tapGesture: UITapGestureRecognizer!
    
    open var doubleTapGesture: UITapGestureRecognizer!
    
    //MARK: 数据
    
    open weak var delegate: BMPlayerControlViewDelegate?
    
    open weak var player: BMPlayer?
    
    open var resource: BMPlayerResource?
        
    open var isFullscreen  = false
    
    open var isSubtitleEnabled = true {
        didSet {
            self.subtitleBackView.isHidden = !isSubtitleEnabled
        }
    }
        
    open var isMaskShowing = false
    
    open var isLoading = false
    
    open var isEnded = false
    
    open var isLock = false
        
    open var currentTime: TimeInterval = 0
    
    open var totalDuration: TimeInterval = 0
    
    open var delayItem: DispatchWorkItem?
    
    var playerLastState: BMPlayerState = .notSetURL
        
    //MARK: - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.ht_init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.ht_init()
    }
    
    func ht_init() {
        self.setupUIComponents()
        self.addSnapKitConstraint()
        
        self.timeSlider.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: UIControl.Event.touchDown)
        self.timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: UIControl.Event.valueChanged)
        self.timeSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [UIControl.Event.touchUpInside,UIControl.Event.touchCancel, UIControl.Event.touchUpOutside])
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGestureTapped(_:)))
        self.addGestureRecognizer(tapGesture)
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDoubleTapGestureRecognized(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGesture)
        
        tapGesture.require(toFail: doubleTapGesture)
    }
        
    func setupUIComponents() {
        // 字幕
        self.addSubview(self.subtitleBackView)
        self.subtitleBackView.addSubview(self.subtitleLabel)
        // 主遮罩
        self.addSubview(self.mainMaskView)
        // 封面
        self.mainMaskView.addSubview(self.maskImageView)
        // 缩进
        self.mainMaskView.addSubview(self.mainWrapperView)
        // 顶部功能
        self.mainWrapperView.addSubview(self.topMaskView)
        self.topMaskView.addSubview(self.backButton)
        self.topMaskView.addSubview(self.titleLabel)
        self.topMaskView.addSubview(self.shareBtn)
        self.topMaskView.addSubview(self.collectionBtn)
        self.topMaskView.addSubview(self.tvBtn)
        self.topMaskView.addSubview(self.ccTopBtn)
        self.topMaskView.addSubview(self.vipBtn)
        // 中间功能
        self.mainWrapperView.addSubview(self.centerMaskView)
        self.centerMaskView.addSubview(self.lockBtn)
        self.centerMaskView.addSubview(self.minusBtn)
        self.centerMaskView.addSubview(self.playCenterBtn)
        self.centerMaskView.addSubview(self.plusBtn)
        self.mainWrapperView.addSubview(replayButton)
        // 底部功能
        self.mainWrapperView.addSubview(self.bottomMaskView)
        self.bottomMaskView.addSubview(self.playBtn)
        self.bottomMaskView.addSubview(self.nextBtn)
        self.bottomMaskView.addSubview(self.speedBtn)
        self.bottomMaskView.addSubview(self.episodesBtn)
        self.bottomMaskView.addSubview(self.ccBottomBtn)
        self.bottomMaskView.addSubview(self.scaleBtn)
        self.bottomMaskView.addSubview(self.fullscreenBtn)
        self.bottomMaskView.addSubview(self.currentTimeLabel)
        self.bottomMaskView.addSubview(self.progressView)
        self.bottomMaskView.addSubview(self.timeSlider)
        self.bottomMaskView.addSubview(self.totalTimeLabel)
        // 解锁
        self.mainMaskView.addSubview(self.unlockBtn)
        // 加载中
        self.mainMaskView.addSubview(self.loadingIndicator)
        // 进度调整
        self.mainMaskView.addSubview(self.seekToView)
        self.seekToView.addSubview(self.seekToViewImage)
        self.seekToView.addSubview(self.seekToLabel)
    }
    
    func addSnapKitConstraint() {
        // 字幕
        self.subtitleBackView.snp.makeConstraints { [unowned self](make) in
            make.top.equalTo(self.snp.bottom).inset(54 + (LQGSize.bottomSafeHeight > 0 ? LQGSize.bottomSafeHeight : 20))
            make.centerX.equalToSuperview()
        }
        
        self.subtitleLabel.snp.makeConstraints { [unowned self](make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
            make.width.lessThanOrEqualTo(UIScreen.main.bounds.size.width-30)
        }
        
        // 主遮罩
        self.mainMaskView.snp.makeConstraints { [unowned self](make) in
            make.edges.equalToSuperview()
        }
        
        // 封面
        self.maskImageView.snp.makeConstraints { [unowned self](make) in
            make.edges.equalToSuperview()
        }
        
        // 缩进
        self.mainWrapperView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 顶部功能
        self.topMaskView.snp.makeConstraints { [unowned self](make) in
            make.top.left.right.equalToSuperview()
        }
        
        self.backButton.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        self.titleLabel.snp.makeConstraints { [unowned self](make) in
            make.left.equalTo(self.backButton.snp.right).offset(10)
            make.right.equalTo(self.vipBtn.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        
        self.shareBtn.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(44)
        }
        
        self.collectionBtn.snp.makeConstraints { make in
            make.right.equalTo(self.shareBtn.snp.left)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(44)
        }
        
        self.tvBtn.snp.makeConstraints { make in
            make.right.equalTo(self.collectionBtn.snp.left)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(44)
        }
        
        self.ccTopBtn.snp.makeConstraints { make in
            make.right.equalTo(self.tvBtn.snp.left)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(44)
        }
        
        self.vipBtn.snp.makeConstraints { make in
            make.right.equalTo(self.ccTopBtn.snp.left)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(BMPlayerManager.shared.isVip ? 0 : 95)
        }
        
        // 中间功能
        self.centerMaskView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalTo(self.mainMaskView)
            make.height.equalTo(48)
        }
        
        self.lockBtn.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(44)
        }
        
        self.minusBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(0.5)
        }
        
        self.playCenterBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        self.plusBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(1.5)
        }
        
        self.replayButton.snp.makeConstraints { make in
            make.center.equalTo(self.mainMaskView)
        }
        
        // 底部功能
        self.bottomMaskView.snp.makeConstraints { [unowned self](make) in
            make.bottom.left.right.equalToSuperview()
        }
                
        self.playBtn.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        self.nextBtn.snp.makeConstraints { make in
            make.left.equalTo(self.playBtn.snp.right)
            make.bottom.equalToSuperview()
            make.width.equalTo(BMPlayerManager.shared.haveEpisodes ? 44 : 0)
            make.height.equalTo(44)
        }
        
        self.speedBtn.snp.makeConstraints { make in
            make.right.equalTo(self.episodesBtn.snp.left)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        self.episodesBtn.snp.makeConstraints { make in
            make.right.equalTo(self.ccBottomBtn.snp.left)
            make.bottom.equalToSuperview()
            make.width.equalTo(BMPlayerManager.shared.haveEpisodes ? 44 : 0)
            make.height.equalTo(44)
        }
        
        self.ccBottomBtn.snp.makeConstraints { make in
            make.right.equalTo(self.scaleBtn.snp.left)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        self.scaleBtn.snp.makeConstraints { make in
            make.right.equalTo(self.fullscreenBtn.snp.left)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        self.fullscreenBtn.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        self.currentTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(self.nextBtn.snp.right)
            make.bottom.equalToSuperview()
            make.centerY.equalTo(self.nextBtn)
        }
        
        self.progressView.snp.makeConstraints { make in
            make.left.equalTo(self.currentTimeLabel.snp.right).offset(12)
            make.right.equalTo(self.totalTimeLabel.snp.left).offset(-12)
            make.centerY.equalTo(self.currentTimeLabel)
            make.height.equalTo(2)
        }
        
        self.timeSlider.snp.makeConstraints { make in
            make.left.right.centerY.equalTo(self.progressView)
            make.height.equalTo(30)
        }
        
        self.totalTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(self.speedBtn.snp.left)
            make.centerY.equalTo(self.currentTimeLabel)
        }
        
        // 解锁
        self.unlockBtn.snp.makeConstraints { make in
            make.left.equalTo(self.mainWrapperView)
            make.centerY.equalTo(self.mainMaskView)
            make.width.equalTo(44)
            make.height.equalTo(48)
        }
        
        // 加载中
        self.loadingIndicator.snp.makeConstraints { [unowned self](make) in
            make.center.equalTo(self.mainMaskView)
        }
        
        // 进度调整
        self.seekToView.snp.makeConstraints { [unowned self](make) in
            make.center.equalTo(self.mainMaskView)
            make.width.equalTo(168)
        }
                        
        self.seekToViewImage.snp.makeConstraints { [unowned self](make) in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }

        self.seekToLabel.snp.makeConstraints { [unowned self](make) in
            make.top.equalTo(self.seekToViewImage.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    open func updateUI(_ isForFullScreen: Bool) {
        isFullscreen = isForFullScreen
    
        self.subtitleBackView.isHidden = !self.isSubtitleEnabled
        self.titleLabel.isHidden = !isForFullScreen
        self.centerMaskView.isHidden = !isForFullScreen || self.isEnded
        self.unlockBtn.isHidden = !isForFullScreen || self.isEnded
        fullscreenBtn.isSelected = isForFullScreen
        
        self.mainWrapperView.snp.remakeConstraints { make in
            if isFullscreen {
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 50, bottom: 18, right: 50))
            } else {
                make.edges.equalToSuperview()
            }
        }
        
        self.shareBtn.snp.updateConstraints { make in
            make.width.equalTo(isForFullScreen ? 44 : 0)
        }
        
        self.collectionBtn.snp.updateConstraints { make in
            make.width.equalTo(isForFullScreen ? 44 : 0)
        }
                
        self.ccTopBtn.snp.updateConstraints { make in
            make.width.equalTo(isForFullScreen ? 0 : 44)
        }
        
        self.nextBtn.snp.updateConstraints { make in
            make.width.equalTo(BMPlayerManager.shared.haveEpisodes && isForFullScreen ? 44 : 0)
        }
        
        self.speedBtn.snp.updateConstraints { make in
            make.width.equalTo(isForFullScreen ? 44 : 0)
        }
        
        self.episodesBtn.snp.updateConstraints { make in
            make.width.equalTo(BMPlayerManager.shared.haveEpisodes && isForFullScreen ? 44 : 0)
        }
        
        self.ccBottomBtn.snp.updateConstraints { make in
            make.width.equalTo(isForFullScreen ? 44 : 0)
        }
        
        self.scaleBtn.snp.updateConstraints { make in
            make.width.equalTo(isForFullScreen ? 44 : 0)
        }
        
        self.currentTimeLabel.snp.remakeConstraints { make in
            if isForFullScreen {
                make.top.equalToSuperview()
                make.left.equalToSuperview().inset(15)
                make.bottom.equalTo(self.playBtn.snp.top).offset(-6)
            } else {
                make.left.equalTo(self.nextBtn.snp.right)
                make.top.bottom.equalToSuperview()
                make.centerY.equalTo(self.nextBtn)
            }
        }
        
        self.totalTimeLabel.snp.remakeConstraints { make in
            if isForFullScreen {
                make.right.equalToSuperview().inset(10)
            } else {
                make.right.equalTo(self.speedBtn.snp.left)
            }
            make.centerY.equalTo(self.currentTimeLabel)
        }
        
    }
    
    open func controlViewAnimation(isShow: Bool) {
        UIApplication.shared.setStatusBarHidden(!isShow, with: .fade)
        
        self.isMaskShowing = isShow
        
        self.subtitleBackView.snp.remakeConstraints { [unowned self](make) in
            if isShow && self.isLock == false {
                make.bottom.equalTo(self.bottomMaskView.snp.top).offset(-10)
            } else {
                make.top.equalTo(self.snp.bottom).inset(54 + (self.isFullscreen && LQGSize.bottomSafeHeight > 0 ? LQGSize.bottomSafeHeight : 20))
            }
            make.centerX.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            guard let wSelf = self else {return}
            wSelf.mainMaskView.backgroundColor = UIColor(white: 0, alpha: isShow ? 0.5 : 0.0)
            wSelf.topMaskView.alpha = isShow && wSelf.isLock == false ? 1.0 : 0.0
            wSelf.centerMaskView.alpha = isShow && wSelf.isLock == false ? 1.0 : 0.0
            wSelf.replayButton.alpha = isShow && wSelf.isLock == false ? 1.0 : 0.0
            wSelf.bottomMaskView.alpha = isShow && wSelf.isLock == false ? 1.0 : 0.0
            wSelf.unlockBtn.alpha = isShow && wSelf.isLock ? 1.0 : 0.0
            wSelf.layoutIfNeeded()
        }) { [weak self] _ in
            guard let wSelf = self else {return}
            if isShow {
                wSelf.autoFadeOutControlViewWithAnimation()
            }
        }
    }
    
    //MARK: 封面显示/隐藏
    
    open func showCoverWithLink(_ cover:String) {
        self.showCover(url: URL(string: cover))
    }
    
    open func showCover(url: URL?) {
        if let url = url {
            DispatchQueue.global(qos: .default).async { [weak self] in
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async(execute: { [weak self] in
                  guard let `self` = self else { return }
                    if let data = data {
                        self.maskImageView.image = UIImage(data: data)
                    } else {
                        self.maskImageView.image = nil
                    }
                    self.hideLoader()
                });
            }
        }
    }
    
    open func hideCoverImageView() {
        self.maskImageView.isHidden = true
    }
    
    //MARK: 加载中显示/隐藏
    
    open func showLoader() {
        self.isLoading = true
        
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
    }
    
    open func hideLoader() {
        self.isLoading = false
        
        self.loadingIndicator.isHidden = true
    }
    
    //MARK: 播放结束显示/隐藏
    open func showPlayToTheEndView() {
        self.isEnded = true
        
        self.centerMaskView.isHidden = true
        self.replayButton.isHidden = false
    }
    
    open func hidePlayToTheEndView() {
        self.isEnded = false
        
        self.centerMaskView.isHidden = !self.isFullscreen
        self.replayButton.isHidden = true
    }
    
    open func videoPlaybackRateChanged(rate: Float) {
        self.speedBtn.setImage(BMImageResourcePath(String(format: "Pod_Asset_BMPlayer_speed_%.1fx", rate)), for: .normal)
    }
        
    // 拖拽结束
    open func hideSeekToView() {
        seekToView.isHidden = true
    }
    
    // MARK: - Action Response
    
    @objc
    open func onTapGestureTapped(_ gesture: UITapGestureRecognizer) {
        if playerLastState == .playedToTheEnd {return}
        controlViewAnimation(isShow: !isMaskShowing)
    }
    
    @objc
    open func onDoubleTapGestureRecognized(_ gesture: UITapGestureRecognizer) {
        if self.isLock {return}
        guard let player = player else { return }
        guard playerLastState == .readyToPlay || playerLastState == .buffering || playerLastState == .bufferFinished else { return }
        
        self.onButtonPressed(self.playBtn)
    }
    
    @objc
    open func onButtonPressed(_ button: UIButton) {
        autoFadeOutControlViewWithAnimation()
        if let type = BMPlayerControlTapType(rawValue: button.tag) {
            switch type {
            case .speed:
                self.controlViewAnimation(isShow: false)
            case .subtitle:
                self.controlViewAnimation(isShow: false)
                
            case .play, .replay:
                if playerLastState == .playedToTheEnd {
                    hidePlayToTheEndView()
                }
            case .episodes:
                self.controlViewAnimation(isShow: false)
                
            case .lock:
                self.isLock = true
                self.controlViewAnimation(isShow: true)
                self.timeSlider.isUserInteractionEnabled = false
            case .unlock:
                self.isLock = false
                self.controlViewAnimation(isShow: true)
                self.timeSlider.isUserInteractionEnabled = true
            default:
                break
            }
        }
        delegate?.controlView(controlView: self, didPressButton: button)
    }
    
    @objc
    func progressSliderTouchBegan(_ sender: UISlider)  {
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchDown)
    }
    
    @objc
    func progressSliderValueChanged(_ sender: UISlider)  {
        cancelAutoFadeOutAnimation()
        hidePlayToTheEndView()
        self.currentTimeLabel.text = formatSecondsToString(Double(sender.value) * totalDuration)
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .valueChanged)
    }
    
    @objc
    func progressSliderTouchEnded(_ sender: UISlider)  {
        autoFadeOutControlViewWithAnimation()
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchUpInside)
    }
    
    // MARK: - handle player state change
    /**
     call on when play time changed, update duration here
     
     - parameter currentTime: current play time
     - parameter totalTime:   total duration
     */
    open func playTimeDidChange(currentTime: TimeInterval, totalTime: TimeInterval) {
        self.currentTimeLabel.text = formatSecondsToString(currentTime)
        self.totalTimeLabel.text   = formatSecondsToString(totalTime)
        self.timeSlider.value      = Float(currentTime) / Float(totalTime)
        self.showSubtile(from: self.resource?.subtitle, at: currentTime)
    }


    /**
     change subtitle resource
     
     - Parameter subtitles: new subtitle object
     */
    open func update(subtitles: BMSubtitles?) {
        resource?.subtitle = subtitles
    }
    
    /**
     call on load duration changed, update load progressView here
     
     - parameter loadedDuration: loaded duration
     - parameter totalDuration:  total duration
     */
    open func loadedTimeDidChange(loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        progressView.setProgress(Float(loadedDuration)/Float(totalDuration), animated: true)
    }
    
    open func playerStateDidChange(state: BMPlayerState) {
        playerLastState = state
        switch state {
        case .readyToPlay:
            hideLoader()
        case .buffering:
            showLoader()
        case .bufferFinished:
            hideLoader()
        case .playedToTheEnd:
            playBtn.isSelected = false
            playCenterBtn.isSelected = false
            showPlayToTheEndView()
            controlViewAnimation(isShow: true)
        default:
            break
        }
    }
    
    /**
     Call when User use the slide to seek function
     
     - parameter toSecound:     target time
     - parameter totalDuration: total duration of the video
     - parameter isAdd:         isAdd
     */
    open func showSeekToView(to toSecound: TimeInterval, current currentPosition:TimeInterval, total totalDuration:TimeInterval, isAdd: Bool) {
        self.seekToView.isHidden = false
        self.seekToViewImage.transform = CGAffineTransform(rotationAngle: isAdd ? 0 : CGFloat(Double.pi))
        self.seekToLabel.text = formatSecondsToString(toSecound) + "/" + formatSecondsToString(currentPosition)
        
        self.currentTimeLabel.text = formatSecondsToString(toSecound)
        self.timeSlider.value = Float(toSecound / totalDuration)
    }
    
    // MARK: - UI update related function
    /**
     Update UI details when player set with the resource
     
     - parameter resource: video resouce
     - parameter index:    defualt definition's index
     */
    open func prepareUI(for resource: BMPlayerResource, selectedIndex index: Int) {
        self.resource = resource
        titleLabel.text = resource.name
        self.hidePlayToTheEndView()
        prepareChooseDefinitionView()
        autoFadeOutControlViewWithAnimation()
    }
    
    open func playStateDidChange(isPlaying: Bool) {
        autoFadeOutControlViewWithAnimation()
        playBtn.isSelected = isPlaying
        playCenterBtn.isSelected = isPlaying
    }
    
    /**
     auto fade out controll view with animtion
     */
    open func autoFadeOutControlViewWithAnimation() {
        cancelAutoFadeOutAnimation()
        delayItem = DispatchWorkItem { [weak self] in
            if self?.playerLastState != .playedToTheEnd {
                self?.controlViewAnimation(isShow: false)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + BMPlayerConf.animateDelayTimeInterval,
                                      execute: delayItem!)
    }
    
    /**
     cancel auto fade out controll view with animtion
     */
    open func cancelAutoFadeOutAnimation() {
        delayItem?.cancel()
    }
    
    open func prepareChooseDefinitionView() {}
    
    open func prepareToDealloc() {
        self.delayItem = nil
    }
    
    // MARK: - private functions
    fileprivate func showSubtile(from subtitle: BMSubtitles?, at time: TimeInterval) {
        if let subtitle = subtitle, let group = subtitle.search(for: time) {
            subtitleBackView.alpha = 1
            subtitleLabel.attributedText = NSAttributedString(string: group.text, attributes: subtitleAttribute)
        } else {
            subtitleBackView.alpha = 0
        }
    }
    
    @objc
    fileprivate func onDefinitionSelected(_ button:UIButton) {}
    
    @objc
    fileprivate func onReplyButtonPressed() {
        self.centerMaskView.isHidden = false
        replayButton.isHidden = true
    }
    
}

//
//  BMPlayer.swift
//  Pods
//
//  Created by BrikerMan on 16/4/28.
//
//

import UIKit
import SnapKit
import MediaPlayer

enum BMPanDirection: Int {
    case horizontal = 0
    case vertical   = 1
}

public protocol BMPlayerDelegate : NSObjectProtocol {
    
    func bmPlayerCanPlay(player: BMPlayer) -> Bool
    
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState)
    
    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool)
    
    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval)
    
    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime : TimeInterval, totalTime: TimeInterval)
    
    
    func bmPlayer(player: BMPlayer, playSubtitleDidLoad groups: [BMSubtitles.Group]?)
    
    func bmPlayer(player: BMPlayer, playSubtitleDidChange group: BMSubtitles.Group?, groups: [BMSubtitles.Group]?)
    
            
    func bmPlayer(player: BMPlayer, playerDidTapSpeedBtn currentSpeed: Float)
    
    func bmPlayer(player: BMPlayer, playerDidTapSubtitleBtn isFullscreen: Bool)
    
    func bmPlayer(player: BMPlayer, playerDidTapPlayBtn isPlaying: Bool)
    
    func bmPlayer(player: BMPlayer, playerDidTapNextBtn isFullscreen: Bool)
    
    func bmPlayer(player: BMPlayer, playerDidTapEpisodesBtn isFullscreen: Bool)
    
    func bmPlayer(player: BMPlayer, playerDidTapBackBtn isFullscreen: Bool)
        
    func bmPlayer(player: BMPlayer, playerDidTapLockBtn isLock: Bool)
    
    func bmPlayer(player: BMPlayer, playerDidTapShareBtn isFullscreen: Bool)
    
    func bmPlayer(player: BMPlayer, playerDidTapCollectionBtn isFullscreen: Bool)
    
    func bmPlayer(player: BMPlayer, playerDidTapJoinVIPBtn isFullscreen: Bool)
    
    func bmPlayer(player: BMPlayer, playerDidTapTVBtn isFullscreen: Bool)

    func bmPlayerDidTapMinusBtn(player: BMPlayer)
    
    func bmPlayerDidTapPlusBtn(player: BMPlayer)
}

open class BMPlayer: UIView {
    
    open weak var delegate: BMPlayerDelegate?
    
    open var resource: BMPlayerResource!
        
    open var playerLayer: BMPlayerLayerView?
    
    public lazy var controlView: BMPlayerControlView = .init()
        
    open lazy var errorView: BMPlayerErrorView = {
        let errorView: BMPlayerErrorView = .init()
        errorView.delegate = self
        return errorView
    }()
            
    open var panGesture: UIPanGestureRecognizer!
    
    /// 滑动方向
    fileprivate var panDirection = BMPanDirection.horizontal
    
    /// 系统音量视图
    fileprivate var systemVolumeView: MPVolumeView!
    
    /// 系统音量滑竿
    fileprivate var systemVolumeViewSlider: UISlider!
    
    /// 自定义音量/亮度视图
    fileprivate var customVolumeBrightnessView: BMVolumeBrightnessView = {
        let customVolumeBrightnessView: BMVolumeBrightnessView = .init()
//        customVolumeBrightnessView.isHidden = true
        return customVolumeBrightnessView
    }()
    
    open var volume: CGFloat = 0
    
    open var brightness: CGFloat = 0
        
    open var isPlaying: Bool {
        get {
            return playerLayer?.isPlaying ?? false
        }
    }
    
    open var avPlayer: AVPlayer? {
        return playerLayer?.player
    }
    
    /// AVLayerVideoGravityType
    open var videoGravity = AVLayerVideoGravity.resizeAspect {
        didSet {
            self.playerLayer?.videoGravity = videoGravity
        }
    }
    
    //Closure fired when play time changed
    open var playTimeDidChange:((TimeInterval, TimeInterval) -> Void)?

    //Closure fired when play state chaged
    @available(*, deprecated, message: "Use newer `isPlayingStateChanged`")
    open var playStateDidChange:((Bool) -> Void)?

    open var playOrientChanged:((Bool) -> Void)?

    open var isPlayingStateChanged:((Bool) -> Void)?

    open var playStateChanged:((BMPlayerState) -> Void)?
    
    fileprivate var currentDefinition = 0
    
    open var isSubtitleEnabled = true {
        didSet {
            self.controlView.isSubtitleEnabled = isSubtitleEnabled
        }
    }
    
    open var isLock = false
    
    fileprivate var isFullScreen:Bool {
        get {
            return UIScreen.main.bounds.size.height < UIScreen.main.bounds.size.width
        }
    }
    
    
    fileprivate let BMPlayerAnimationTimeInterval: Double             = 4.0
    fileprivate let BMPlayerControlBarAutoFadeOutTimeInterval: Double = 0.5
    
    /// 用来保存时间状态
    open var sumTime         : TimeInterval = 0
    open var totalDuration   : TimeInterval = 0
    open var currentPosition : TimeInterval = 0
    open var shouldSeekTo    : TimeInterval = 0
    
    fileprivate var isURLSet        = false
    fileprivate var isSliderSliding = false
    open var isPauseByUser   = false
    fileprivate var isVolume        = false
    fileprivate var isMaskShowing   = false
    fileprivate var isSlowed        = false
    fileprivate var isMirrored      = false
    fileprivate var isPlayToTheEnd  = false
    //视频画面比例
    fileprivate var aspectRatio: BMPlayerAspectRatio = .default
    
    //Cache is playing result to improve callback performance
    fileprivate var isPlayingCache: Bool? = nil
    
    // MARK: - Public functions
        
    /**
     auto start playing, call at viewWillAppear, See more at pause
     */
    open func autoPlay() {
        if !isPauseByUser && isURLSet && !isPlayToTheEnd {
            play()
        }
    }
    
    /**
     Play
     */
    open func play() {
        if self.delegate?.bmPlayerCanPlay(player: self) ?? true == false {return}
        
        guard resource != nil else { return }
        
        if !isURLSet {
            let asset = resource.definitions[currentDefinition]
            playerLayer?.playAsset(asset: asset.avURLAsset)
            controlView.hideCoverImageView()
            isURLSet = true
        }
        
        panGesture.isEnabled = true
        playerLayer?.play()
        playerLayer?.player?.rate = BMPlayerManager.shared.speed
        isPauseByUser = false
    }
    
    /**
     Pause
     
     - parameter allow: should allow to response `autoPlay` function
     */
    open func pause(allowAutoPlay allow: Bool = false) {
        playerLayer?.pause()
        isPauseByUser = !allow
    }
    
    /**
     seek
     
     - parameter to: target time
     */
    open func seek(_ to:TimeInterval, completion: (()->Void)? = nil) {
        playerLayer?.seek(to: to, completion: completion)
    }
    
    /**
     update UI to fullScreen
     */
    open func updateUI(_ isFullScreen: Bool) {
        self.controlView.updateUI(isFullScreen)
        self.errorView.updateUI(isFullScreen)
//        self.customVolumeBrightnessView.isHidden = !isFullScreen
    }
    
    /**
     prepare to dealloc player, call at View or Controllers deinit funciton.
     */
    open func prepareToDealloc() {
        playerLayer?.prepareToDeinit()
        controlView.prepareToDealloc()
    }
    
    /**
     If you want to create BMPlayer with custom control in storyboard.
     create a subclass and override this method.
     
     - return: costom control which you want to use
     */
    open func storyBoardCustomControl() -> BMPlayerControlView? {
        return nil
    }
    
    // MARK: - Action Response
    
    @objc fileprivate func panDirection(_ pan: UIPanGestureRecognizer) {
        if self.controlView.isLock {return}
        // 根据在view上Pan的位置，确定是调音量还是亮度
        let locationPoint = pan.location(in: self)
        
        // 我们要响应水平移动和垂直移动
        // 根据上次和本次移动的位置，算出一个速率的point
        let velocityPoint = pan.velocity(in: self)
        
        // 判断是垂直移动还是水平移动
        switch pan.state {
        case UIGestureRecognizer.State.began:
            // 使用绝对值来判断移动的方向
            let x = abs(velocityPoint.x)
            let y = abs(velocityPoint.y)
            
            if x > y {
                if BMPlayerConf.enablePlaytimeGestures {
                    self.panDirection = BMPanDirection.horizontal
                    
                    // 给sumTime初值
                    if let player = playerLayer?.player {
                        let time = player.currentTime()
                        self.sumTime = TimeInterval(time.value) / TimeInterval(time.timescale)
                    }
                }
            } else {
                self.panDirection = BMPanDirection.vertical
                if locationPoint.x > self.bounds.size.width / 2 {
                    self.isVolume = true
                    self.volume = CGFloat(self.systemVolumeViewSlider.value)
                } else {
                    self.isVolume = false
                    self.brightness = UIScreen.main.brightness
                }
            }
            
        case UIGestureRecognizer.State.changed:
            switch self.panDirection {
            case BMPanDirection.horizontal:
                self.horizontalMoved(velocityPoint.x)
            case BMPanDirection.vertical:
                self.verticalMoved(velocityPoint.y)
            }
            
        case UIGestureRecognizer.State.ended:
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
            case BMPanDirection.horizontal:
                controlView.hideSeekToView()
                isSliderSliding = false
                if isPlayToTheEnd {
                    isPlayToTheEnd = false
                    seek(self.sumTime, completion: {[weak self] in
                        self?.play()
                    })
                } else {
                    seek(self.sumTime, completion: {[weak self] in
                        self?.autoPlay()
                    })
                }
                // 把sumTime滞空，不然会越加越多
                self.sumTime = 0.0
                
            case BMPanDirection.vertical:
                self.isVolume = false
            }
        default:
            break
        }
    }
        
    fileprivate func horizontalMoved(_ value: CGFloat) {
        if self.controlView.isLock {return}
        guard BMPlayerConf.enablePlaytimeGestures else { return }
        
        isSliderSliding = true
        if let playerItem = playerLayer?.playerItem {
            // 每次滑动需要叠加时间，通过一定的比例，使滑动一直处于统一水平
            self.sumTime = self.sumTime + TimeInterval(value) / 100.0 * (TimeInterval(self.totalDuration)/400)
            
            let totalTime = playerItem.duration
            
            // 防止出现NAN
            if totalTime.timescale == 0 { return }
            
            let totalDuration = TimeInterval(totalTime.value) / TimeInterval(totalTime.timescale)
            if (self.sumTime >= totalDuration) { self.sumTime = totalDuration }
            if (self.sumTime <= 0) { self.sumTime = 0 }
            
            controlView.showSeekToView(to: sumTime, current: self.currentPosition, total: totalDuration, isAdd: value > 0)
        }
    }
    
    fileprivate func verticalMoved(_ value: CGFloat) {
        if self.controlView.isLock {return}
        if BMPlayerConf.enableVolumeGestures && self.isVolume {
            self.systemVolumeViewSlider.value -= Float(value / 10000)
//            self.showVolumeBrightnessView(with: true)
        } else if BMPlayerConf.enableBrightnessGestures && !self.isVolume {
            self.brightness -= value / 10000
            UIScreen.main.brightness = self.brightness
            self.showVolumeBrightnessView(with: false)
        }
    }

    @objc fileprivate func fullScreenButtonPressed() {
        if isFullScreen {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            UIApplication.shared.statusBarOrientation = .portrait
        } else {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            }
            UIApplication.shared.setStatusBarHidden(false, with: .fade)
            UIApplication.shared.statusBarOrientation = .landscapeRight
        }
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    // MARK: - 生命周期
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public convenience init() {
        self.init(customControlView:nil)
    }
    
    public init(customControlView: BMPlayerControlView?) {
        super.init(frame:CGRect.zero)
        self.backgroundColor = .black
//        self.backgroundColor = .init(red: 17 / 255.0, green: 18 / 255.0, blue: 24 / 255.0, alpha: 1)
        
        self.systemVolumeView = .init()
//        self.addSubview(self.systemVolumeView)
        
        for view in self.systemVolumeView.subviews {
            if let slider = view as? UISlider {
                self.systemVolumeViewSlider = slider
            }
        }
        
        self.volume = CGFloat(self.systemVolumeViewSlider.value)
        self.brightness = UIScreen.main.brightness
                
        self.playerLayer = BMPlayerLayerView()
        self.playerLayer!.videoGravity = videoGravity
        self.playerLayer!.delegate = self
        
        self.controlView.delegate = self
        self.controlView.player = self
        self.controlView.updateUI(isFullScreen)
                
        self.addSubview(self.playerLayer!)
        self.addSubview(self.controlView)
        self.addSubview(self.customVolumeBrightnessView)
        self.addSubview(self.errorView)
        
        self.playerLayer!.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.controlView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.customVolumeBrightnessView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(60)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 260, height: 48))
        }
        
        self.errorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
                
        self.layoutIfNeeded()
                
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panDirection(_:)))
        self.addGestureRecognizer(panGesture)
                
        do {
            let session = try AVAudioSession.sharedInstance()
            session.addObserver(self, forKeyPath: "outputVolume", options: .new, context: nil)
            try session.setCategory(.playback, mode: .default, options: .allowBluetooth)
            try session.setActive(true)
        } catch {}
    }
    
    deinit {
        playerLayer?.pause()
        playerLayer?.prepareToDeinit()
        
        do {
            let session = try AVAudioSession.sharedInstance()
            session.removeObserver(self, forKeyPath: "outputVolume")
        } catch {}
        
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let session = object as? AVAudioSession {
            self.volume = CGFloat(session.outputVolume)
//            self.showVolumeBrightnessView(with: true)
        }
    }
    
    open func setError(with message: String) {
        self.errorView.isHidden = false
        self.errorView.errorLab.text = message
    }
    
    open func setVideo(resource: BMPlayerResource, definitionIndex: Int = 0) {
        self.errorView.isHidden = true
        
        self.isURLSet = false
        self.resource = resource
        
        currentDefinition = definitionIndex
        controlView.prepareUI(for: resource, selectedIndex: definitionIndex)
        
        if BMPlayerConf.shouldAutoPlay {
            isURLSet = true
            let asset = resource.definitions[definitionIndex]
            playerLayer?.playAsset(asset: asset.avURLAsset)
            self.controlView.showLoader()
        } else {
            controlView.showCover(url: resource.cover)
            controlView.hideLoader()
        }
    }
    
    open func showVolumeBrightnessView(with isVolume: Bool = true) {
        self.customVolumeBrightnessView.showAnimation(isShow: true)
        if isVolume {
            self.customVolumeBrightnessView.imageView.image = BMImageResourcePath(self.volume < 0.001 ? "Pod_Asset_BMPlayer_volume_0" : "Pod_Asset_BMPlayer_volume")
            self.customVolumeBrightnessView.progressView.progress = Float(self.volume)
        } else {
            self.customVolumeBrightnessView.imageView.image = BMImageResourcePath("Pod_Asset_BMPlayer_brightness")
            self.customVolumeBrightnessView.progressView.progress = Float(self.brightness)
        }
    }
}

extension BMPlayer: BMPlayerLayerViewDelegate {

    public func bmPlayer(player: BMPlayerLayerView, playerStateDidChange state: BMPlayerState) {
        BMPlayerManager.shared.log("playerStateDidChange - \(state)")
        
        controlView.playerStateDidChange(state: state)
        switch state {
        case .readyToPlay:
            if !isPauseByUser {
                play()
            }
            if shouldSeekTo != 0 {
                seek(shouldSeekTo, completion: {[weak self] in
                  guard let `self` = self else { return }
                  if !self.isPauseByUser {
                      self.play()
                  } else {
                      self.pause()
                  }
                })
                shouldSeekTo = 0
            }
        case .bufferFinished:
            autoPlay()
        case .playedToTheEnd:
            isPlayToTheEnd = true
        default:
            break
        }
        panGesture.isEnabled = state != .playedToTheEnd
        
        self.playStateChanged?(state)
        
        self.delegate?.bmPlayer(player: self, playerStateDidChange: state)
    }
    
    public func bmPlayer(player: BMPlayerLayerView, playerIsPlaying playing: Bool) {
        self.playStateDidChange?(player.isPlaying)
        self.isPlayingStateChanged?(player.isPlaying)
        
        self.controlView.playStateDidChange(isPlaying: playing)
        
        self.delegate?.bmPlayer(player: self, playerIsPlaying: playing)
    }
    
    public func bmPlayer(player: BMPlayerLayerView, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        BMPlayerManager.shared.log("loadedTimeDidChange - \(loadedDuration) - \(totalDuration)")
        
        self.totalDuration = totalDuration
        
        self.controlView.totalDuration = totalDuration
        self.controlView.loadedTimeDidChange(loadedDuration: loadedDuration, totalDuration: totalDuration)
        
        self.delegate?.bmPlayer(player: self, loadedTimeDidChange: loadedDuration, totalDuration: totalDuration)
    }
    
    public func bmPlayer(player: BMPlayerLayerView, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        BMPlayerManager.shared.log("playTimeDidChange - \(currentTime) - \(totalTime)")
        
        self.currentPosition = currentTime
        self.totalDuration = totalTime
        
        if isSliderSliding {return}
        
        self.playTimeDidChange?(currentTime, totalTime)
        
        self.controlView.totalDuration = totalDuration
        self.controlView.playTimeDidChange(currentTime: currentTime, totalTime: totalTime)
        
        self.delegate?.bmPlayer(player: self, playTimeDidChange: currentTime, totalTime: totalTime)
        self.delegate?.bmPlayer(player: self, playSubtitleDidChange: self.resource.subtitle?.search(for: currentTime), groups: self.resource.subtitle?.groups)
    }
    
    public func update(with delay: TimeInterval) {
        if self.resource == nil {return}
        self.resource.subtitle?.delay = delay

        self.controlView.playTimeDidChange(currentTime: self.currentPosition, totalTime: self.totalDuration)
        self.delegate?.bmPlayer(player: self, playSubtitleDidChange: self.resource.subtitle?.search(for: self.currentPosition), groups: self.resource.subtitle?.groups)
    }
    
}

extension BMPlayer: BMPlayerControlViewDelegate {
    
    open func controlView(controlView: BMPlayerControlView, didPressButton button: UIButton) {
        guard let action = BMPlayerControlTapType(rawValue: button.tag) else {return}
        switch action {
        case .scale:
            self.controlView(didChangeVideoAspectRatio: self.aspectRatio == .default ? .fullscreen : .default)
        case .speed:
            self.delegate?.bmPlayer(player: self, playerDidTapSpeedBtn: BMPlayerManager.shared.speed)
        case .subtitle:
            self.delegate?.bmPlayer(player: self, playerDidTapSubtitleBtn: self.isFullScreen)
            
        case .play:
            if button.isSelected {
                pause()
                self.delegate?.bmPlayer(player: self, playerDidTapPlayBtn: false)
            } else {
                if isPlayToTheEnd {
                    seek(0, completion: {[weak self] in
                      self?.play()
                    })
                    controlView.hidePlayToTheEndView()
                    isPlayToTheEnd = false
                }
                play()
            }
        case .minus:
            let target = max(self.currentPosition - 10, 0)
            
            self.controlView.currentTimeLabel.text = formatSecondsToString(target)
            self.controlView.timeSlider.value = Float(target) / Float(self.totalDuration)
            
            self.delegate?.bmPlayerDidTapMinusBtn(player: self)
            seek(target, completion: {[weak self] in
              self?.autoPlay()
            })
        case .plus:
            let target = min(self.currentPosition + 10, self.totalDuration)
            
            self.controlView.currentTimeLabel.text = formatSecondsToString(target)
            self.controlView.timeSlider.value = Float(target) / Float(self.totalDuration)
            
            self.delegate?.bmPlayerDidTapPlusBtn(player: self)
            seek(target, completion: {[weak self] in
              self?.autoPlay()
            })
        case .replay:
            isPlayToTheEnd = false
            seek(0)
            play()
        case .next:
            self.delegate?.bmPlayer(player: self, playerDidTapNextBtn: self.isFullScreen)
        case .episodes:
            self.delegate?.bmPlayer(player: self, playerDidTapEpisodesBtn: self.isFullScreen)
            
        case .back:
            if isFullScreen == false {
                self.playerLayer?.prepareToDeinit()
                self.delegate?.bmPlayer(player: self, playerDidTapBackBtn: false)
            } else {
                self.fullScreenButtonPressed()
                self.delegate?.bmPlayer(player: self, playerDidTapBackBtn: true)
            }
        case .fullscreen:
            self.fullScreenButtonPressed()
        case .lock:
            self.isLock = true
            self.delegate?.bmPlayer(player: self, playerDidTapLockBtn: true)
        case .unlock:
            self.isLock = false
            self.delegate?.bmPlayer(player: self, playerDidTapLockBtn: false)
        case .share:
            self.delegate?.bmPlayer(player: self, playerDidTapShareBtn: self.isFullScreen)
        case .collection:
            self.delegate?.bmPlayer(player: self, playerDidTapCollectionBtn: self.isFullScreen)
        case .joinVIP:
            self.delegate?.bmPlayer(player: self, playerDidTapJoinVIPBtn: self.isFullScreen)
        case .tv:
            self.delegate?.bmPlayer(player: self, playerDidTapTVBtn: self.isFullScreen)
            
        default:
            break
        }
    }
    
    open func controlView(controlView: BMPlayerControlView, slider: UISlider, onSliderEvent event: UIControl.Event) {
        switch event {
        case .touchDown:
            playerLayer?.onTimeSliderBegan()
            isSliderSliding = true
            
        case .touchUpInside :
            isSliderSliding = false
            let target = self.totalDuration * Double(slider.value)
            
            if isPlayToTheEnd {
                isPlayToTheEnd = false
                seek(target, completion: {[weak self] in
                  self?.play()
                })
                controlView.hidePlayToTheEndView()
            } else {
                seek(target, completion: {[weak self] in
                  self?.autoPlay()
                })
            }
        default:
            break
        }
    }
    
    open func controlView(didChangeVideoAspectRatio aspectRatio: BMPlayerAspectRatio) {
        self.aspectRatio = aspectRatio
        self.playerLayer?.aspectRatio = aspectRatio
        self.controlView.scaleBtn.isSelected = aspectRatio == .fullscreen
    }
    
    open func controlView(didChangeVideoPlaybackRate rate: Float) {
        BMPlayerManager.shared.speed = rate
        self.playerLayer?.player?.rate = rate
        self.controlView.videoPlaybackRateChanged(rate: rate)
    }
    
}

//
//  PlaybackControlsView.swift
//  Alamofire
//
//  Created by Max Lesichniy on 26.12.2017.
//

import Foundation

public protocol PlaybackControlsViewDelegate: UIToolbarDelegate {
    func playbackControls(_ view: PlaybackControlsView, didSeek to: TimeInterval)
    func playbackControls(_ view: PlaybackControlsView, perform action: PlaybackControlsView.Action)
}

public class PlaybackControlsView: UIToolbar {
    
    public enum Action: Int {
        case play, pause
    }
    
    private weak var _delegate: PlaybackControlsViewDelegate?
    public override var delegate: UIToolbarDelegate? {
        didSet {
            _delegate = delegate as? PlaybackControlsViewDelegate
        }
    }
    
    public var isPlaying: Bool = false {
        didSet {
            updateBarButtomItems()
        }
    }
    
    public fileprivate(set) lazy var playButton: UIBarButtonItem = { [unowned self] in
        let button = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playClick(_:)))
        return button
    }()
    
    public fileprivate(set) lazy var pauseButton: UIBarButtonItem = { [unowned self] in
        let button = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(pauseClick(_:)))
        return button
    }()
    
    public fileprivate(set) lazy var slider: UISlider = { [unowned self] in
        let view = UISlider()
        view.minimumValue = 0
        view.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
        return view
    }()

    public fileprivate(set) var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "0:00"
        return label
    }()
    
    public fileprivate(set) var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "0:00"
        return label
    }()
    
    public init() {
        super.init(frame: .zero)
        barStyle = .black
        setShadowImage(UIImage(), forToolbarPosition: .any)
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        updateBarButtomItems()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateCurrentTime(_ currentTime: TimeInterval, totalTime: TimeInterval) {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.maximumUnitCount = 2
        formatter.zeroFormattingBehavior = .pad
        totalTimeLabel.text = formatter.string(from: totalTime)
        currentTimeLabel.text = formatter.string(from: currentTime)
        slider.maximumValue = Float(totalTime)
        slider.value = Float(currentTime)
        totalTimeLabel.sizeToFit()
        currentTimeLabel.sizeToFit()
    }
    
    fileprivate func updateBarButtomItems() {
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        fixedSpace.width = Constants.overlayBarButtonItemSpacing
        let firstItem: UIBarButtonItem
        if isPlaying {
            firstItem = pauseButton
        } else {
            firstItem = playButton
        }
        
        let sliderItem = UIBarButtonItem(customView: slider)
        slider.frame = CGRect(x: 0, y: 0, width: 250, height: 30)
//        sliderItem.width = 250
        
        let items = [firstItem,
                     fixedSpace,
                     UIBarButtonItem(customView: currentTimeLabel),
                     fixedSpace,
                     sliderItem,
                     fixedSpace,
                     UIBarButtonItem(customView: totalTimeLabel)]
        setItems(items, animated: true)
    }
    
    @objc func playClick(_ sender: UIBarButtonItem) {
        _delegate?.playbackControls(self, perform: .play)
    }
    
    @objc func pauseClick(_ sender: UIBarButtonItem) {
        _delegate?.playbackControls(self, perform: .pause)
    }
    
    @objc func sliderChange(_ sender: UISlider) {
        _delegate?.playbackControls(self, didSeek: TimeInterval(slider.value))
    }
}


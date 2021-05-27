//
// Created by Eric Chen on 2021/5/3.
// Copyright (c) 2021 CyberLink. All rights reserved.
//

import Foundation
import AVFoundation

class FLVideoView : UIView {
    private(set) var player : AVPlayer? = AVPlayer()
    private var avPlayerLayer:AVPlayerLayer?
    var replay = true
    private var path = "" // url path
    private let clock = FLTicTac()
    private var onEndLis:NSObjectProtocol?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.clipsToBounds = true
        addObservers()
    }

    private func addObservers() {
        onEndLis = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: onEnded)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(onEndLis)
    }

    deinit {
        removeObservers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        initAvLayer()
        avPlayerLayer?.frame = self.bounds
    }

    private func initAvLayer() {
        if (avPlayerLayer == nil) {
            let av = AVPlayerLayer()
            av.videoGravity = .resizeAspect
            av.player = player
            self.layer.addSublayer(av)
            avPlayerLayer = av
        }
    }

    @objc
    func setVideoUrl(url:URL) {
        let a = AVURLAsset(url: url, options: nil)
        path = url.path
        setAsset(a)
    }

    private func setAsset(_ s:AVURLAsset) {
        let newer = AVPlayerItem(asset: s)
        player?.replaceCurrentItem(with: newer)
        player?.actionAtItemEnd = .none
    }

    // return nil if notification is not me, return notif.object casted if is me
    private func isMe(_ got:Notification) -> AVPlayerItem? {
        let x = got.object as? AVPlayerItem
        let isMe = x == self.player?.currentItem
        if (isMe) {
            return x
        } else {
            return nil
        }
    }

    @objc
    private func onEnded(_ got:Notification) {
        let x = isMe(got)
        if (x == nil) {
            return // not me
        }
        if (replay) {
            //clock.tic()
            player?.seek(to: .zero, completionHandler: { [unowned self] b in
                //clock.tacS("seek to 0 \(self.path)")
                // seek about 10ms, but for objRemoval = 60ms
            })
        }
    }

}

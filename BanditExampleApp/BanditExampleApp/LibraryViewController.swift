/*
 * Copyright (C) 2012-2016. TomTom International BV (http://tomtom.com).
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import BanditCameraKit

class LibraryViewController: BaseViewController {

    let pageSize: UInt = 32
    var videos: [VideoItem] = []
    var thumbnails: [String: UIImage] = [:]
    var fetchedAllVideos: Bool = false
    @IBOutlet var collectionViewVideos: UICollectionView!
    @IBOutlet var imageViewPreview: UIImageView!
    @IBOutlet var labelTapToPause: UILabel!

    private let previewControl: PreviewStreamControl = PreviewStreamControl()
    private var stopPreviewTap: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        previewControl.delegate = self
        
        labelTapToPause.hidden = true
        imageViewPreview.hidden = true
        imageViewPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LibraryViewController.pausePreview)))
        imageViewPreview.userInteractionEnabled = true
        stopPreviewTap = UITapGestureRecognizer(target: self, action: #selector(LibraryViewController.stopPreview))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if videos.count == 0 {
            if camera.connected {
                fetchVideos()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        previewControl.stop()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionViewVideos.reloadData()
    }
    
    override func onCameraConnected(completion: (() -> Void)? = nil) {
        super.onCameraConnected() {
            self.fetchVideos()
            completion?()
        }
    }
    
    override func onCameraDisconnected() {
        super.onCameraDisconnected()
        previewControl.stop()
    }
    
    func fetchVideos() {
        startActivityIndicator("Fetching videos...")
        camera.rest.getVideos(order: .Descending, offset: UInt(videos.count), count: pageSize, highlightsIncluded: .No) { (videos) in
            if videos.count < Int(self.pageSize) {
                self.fetchedAllVideos = true
            }
            self.videos += videos
            self.collectionViewVideos.userInteractionEnabled = true
            self.collectionViewVideos.reloadData()
            self.stopActivityIndicator()
        }
    }
    
    func onRecordingStopped(newVideo: [String: AnyObject]!) {
        let video = VideoItem()
        if video.fromDictionary(newVideo) {
            videos.insert(video, atIndex: 0)
            if let collectionViewVideos = collectionViewVideos {
                collectionViewVideos.reloadData()
            }
        }
    }

    private func startPreviewFor(video: VideoItem) {
        startActivityIndicator()
        previewControl.startPreviewFor(video) {
            dispatch_async(dispatch_get_main_queue()) {
                self.stopActivityIndicator()
            }
        }
    }
    
    @objc private func pausePreview() {
        previewControl.pause()
    }

    @objc private func stopPreview() {
        startActivityIndicator()
        previewControl.stop() {
            self.stopActivityIndicator()
        }
    }
}

extension LibraryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
        let video = videos[indexPath.row]
        cell.imageViewThumbnail.image = nil
        if thumbnails[video.mediaItemId] == nil {
            camera.rest.getVideoThumbnail(video.mediaItemId) { (thumbnail) in
                cell.imageViewThumbnail.image = thumbnail
                self.thumbnails.updateValue(thumbnail, forKey: video.mediaItemId)
            }
        }
        else {
            cell.imageViewThumbnail.image = thumbnails[video.mediaItemId]
        }
        
        if indexPath.row == videos.count - 1 {
            if fetchedAllVideos == false {
                collectionView.userInteractionEnabled = false
                fetchVideos()
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        startPreviewFor(videos[indexPath.row])
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.frame.width - 12) / 2
        let height = width * (9 / 16)
        return CGSizeMake(width, height)
    }
}

extension LibraryViewController: PreviewStreamControlDelegate {
    
    func previewDidStart() {
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionViewVideos.hidden = true
            self.imageViewPreview.hidden = false
            self.labelTapToPause.hidden = false
            self.containerView.addGestureRecognizer(self.stopPreviewTap)
        }
    }
    
    func previewDidStop() {
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionViewVideos.hidden = false
            self.imageViewPreview.hidden = true
            self.labelTapToPause.hidden = true
            self.containerView.removeGestureRecognizer(self.stopPreviewTap)
        }
    }
    
    func previewDidPause(paused: Bool) {}
    
    func previewShouldPresentVideoFrame(frame: UIImage, forPresentationTimestamp pts: Double) {
        imageViewPreview.image = frame
    }
}

class VideoCell: UICollectionViewCell {
    @IBOutlet var imageViewThumbnail: UIImageView!
}

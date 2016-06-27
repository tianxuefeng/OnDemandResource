/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class VideoListViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet var collectionViewDataSource: VideoListCollectionViewDataSource!

  @IBOutlet weak var progressView: UIProgressView!
  
  var currentVideoResourceRequest: NSBundleResourceRequest?
}

//http://code.tutsplus.com/tutorials/an-introduction-to-on-demand-resources-on-ios-and-tvos--cms-24929
//https://www.raywenderlich.com/126300/on-demand-resources-in-tvos-tutorial

extension VideoListViewController: UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    didSelectVideoAtIndexPath(indexPath)
  }

  func didSelectVideoAtIndexPath(indexPath: NSIndexPath) {

    progressView.hidden = false
    
    // 1
    currentVideoResourceRequest?.progress.cancel()
    // 2
    guard var video = collectionViewDataSource
      .videoForIndexPath(indexPath),
      let videoCategory = collectionViewDataSource
        .videoCategoryForIndexPath(indexPath) else {
          return
    }
    // 3
      currentVideoResourceRequest = ResourceManager.sharedManager
        .requestVideoWithTag(video.videoName, progressObserver: self,
        onSuccess: { [weak self] in
          self?.progressView.hidden = true
          
          guard let currentVideoResourceRequest =
            self?.currentVideoResourceRequest else { return }
          video.videoURL = currentVideoResourceRequest.bundle
            .URLForResource(video.videoName, withExtension: "mp4")
          let viewController = PlayVideoViewController
            .instanceWithVideo(video, videoCategory: videoCategory)
          self?.navigationController?.pushViewController(viewController,
            animated: true)
   
        },
        onFailure: { [weak self] error in
        
          self?.progressView.hidden = true
          
          self?.handleDownloadingError(error)
        }
    )
  }

  func handleDownloadingError(error: NSError) {
    switch error.code{
    case NSBundleOnDemandResourceOutOfSpaceError:
      let message = "You don't have enough storage left to download this resource."
      let alert = UIAlertController(title: "Not Enough Space",
        message: message,
        preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK",
        style: .Cancel, handler: nil))
      presentViewController(alert, animated: true,
        completion: nil)
    case NSBundleOnDemandResourceExceededMaximumSizeError:
      assert(false, "The bundle resource was too large.")
    case NSBundleOnDemandResourceInvalidTagError:
      assert(false, "The requested tag(s) (\(currentVideoResourceRequest?.tags ?? [""])) does not exist.")
    default:
      assert(false, error.description)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
   
    currentVideoResourceRequest?.endAccessingResources()
    currentVideoResourceRequest = nil
  }
  
  override func observeValueForKeyPath(keyPath: String?,
  ofObject object: AnyObject?, change: [String : AnyObject]?,
  context: UnsafeMutablePointer<Void>) {
 
      if context == progressObservingContext && keyPath == "fractionCompleted"{
   
          NSOperationQueue.mainQueue().addOperationWithBlock {
            self.progressView.progress
              = Float((object as! NSProgress).fractionCompleted)
          }
      }
  }
  
}

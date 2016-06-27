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

struct VideoListViewIdentifiers {
  static let VideoCell = "VideoCell"
  static let VideoHeaderView = "VideoHeaderView"
}

class VideoListCollectionViewDataSource: NSObject {

  let videoCategories = VideoPlistParser.parsePlistWithName("VideosList",
    bundle: NSBundle.mainBundle())

  func videoForIndexPath(indexPath: NSIndexPath) -> Video? {
    guard let videoCategory = videoCategoryForIndexPath(indexPath) else {
      return nil
    }

    if indexPath.row >= videoCategory.videos.count {
      return nil
    }

    return videoCategory.videos[indexPath.row]
  }

  func videoCategoryForIndexPath(indexPath: NSIndexPath) -> VideoCategory? {
    if indexPath.section >= videoCategories.count {
      return nil
    }

    return videoCategories[indexPath.section]
  }
}

extension VideoListCollectionViewDataSource: UICollectionViewDataSource {

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return videoCategories.count
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let videoCategory = videoCategories[section]
    return videoCategory.videos.count
  }

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    if kind == UICollectionElementKindSectionHeader {
      return self.collectionView(collectionView, headerViewAtIndexPath: indexPath)
    }

    assert(false, "Unexpected element kind")
    return UICollectionReusableView()
  }

  private func collectionView(collectionView: UICollectionView, headerViewAtIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let videoCategory = videoCategories[indexPath.section]

    let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(
      UICollectionElementKindSectionHeader,
      withReuseIdentifier: VideoListViewIdentifiers.VideoHeaderView,
      forIndexPath: indexPath) as! VideoHeaderView

    headerView.label.text = videoCategory.name

    return headerView
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    return self.collectionView(collectionView, videoCellForItemAtIndexPath: indexPath)!
  }

  func collectionView(collectionView: UICollectionView, videoCellForItemAtIndexPath indexPath: NSIndexPath) -> VideoCell? {
    guard let video = videoForIndexPath(indexPath) else {
      return nil
    }

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
      VideoListViewIdentifiers.VideoCell,
      forIndexPath: indexPath) as! VideoCell

    cell.video = video

    return cell
  }

}

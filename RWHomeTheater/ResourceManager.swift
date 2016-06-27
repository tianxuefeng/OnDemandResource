//
//  ResourceManager.swift
//  RWHomeTheater
//
//  Created by Main Account on 2/10/16.
//  Copyright © 2016 Razeware, LLC. All rights reserved.
//

import Foundation

let progressObservingContext = UnsafeMutablePointer<Void>()

class ResourceManager {
  static let sharedManager = ResourceManager()
  
  // 1
  func requestVideoWithTag(tag: String,
    progressObserver: NSObject?,
    onSuccess: () -> Void,
    onFailure: (NSError) -> Void) -> NSBundleResourceRequest {
   
      // 2
      let videoRequest = NSBundleResourceRequest(tags: [tag])
      videoRequest.loadingPriority
        = NSBundleResourceRequestLoadingPriorityUrgent
   
      // 3
      videoRequest.beginAccessingResourcesWithCompletionHandler {
        error in
        NSOperationQueue.mainQueue().addOperationWithBlock {
        
          if let progressObserver = progressObserver {
            videoRequest.progress.removeObserver(progressObserver,
              forKeyPath: "fractionCompleted")
          }
          
          if let error = error {
            onFailure(error)
          } else {
            onSuccess()
          }
        }
      }      
      if let progressObserver = progressObserver {
        videoRequest.progress.addObserver(progressObserver,
          forKeyPath: "fractionCompleted",
          options: [.New, .Initial],
          context: progressObservingContext)
      }
      return videoRequest
  }
  
}
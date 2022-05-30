//
//  FlickrPhotoObject.swift
//  searchimage
//
//  Created by Nandish Bellad on 30/05/2022.
//


import UIKit

class FlickrPhotoObject : Equatable {
    let photoId : String
    let photoFarm : Int
    let photoServer : String
    let photoSecret : String
    
    init (photoId:String,photoFarm:Int, photoServer:String, photoSecret:String) {
        self.photoId = photoId
        self.photoFarm = photoFarm
        self.photoServer = photoServer
        self.photoSecret = photoSecret
    }
    
    func flickrPhotoURL() -> URL? {
        if let url =  URL(string: "https://farm\(photoFarm).static.flickr.com/\(photoServer)/\(photoId)_\(photoSecret).jpg") {
            return url
        }
        return nil
    }
}

func == (lhs: FlickrPhotoObject, rhs: FlickrPhotoObject) -> Bool {
    return lhs.photoId == rhs.photoId
}

//
//  SearchFlickr.swift
//  searchimage
//
//  Created by Nandish Bellad on 30/05/2022.
//

import Foundation
import UIKit

let apiKey = "9480a18b30ba78893ebd8f25feaabf17"

class SearchFlickr {
    // Query to Flickr to get the search response and store the result list data , return nil in case of error.
    func searchFlickr(_ searchTerm: String, page: Int = 1,completion : @escaping (_ results: FlickrSearchResults?, _ paging: FlickrPaging?,_ error : NSError?) -> Void){
        
        guard let searchURL = getFlickrSearchURLForSearchTerm(searchTerm) else {
            let apiError = NSError(domain: "SearchFlickr", code: 0, userInfo: nil)
            completion(nil, nil,apiError)
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        URLSession.shared.dataTask(with: searchRequest, completionHandler: { (data, response, error) in
            
            if let _ = error {
                let apiError = NSError(domain: "SearchFlickr", code: 0, userInfo: nil)
                OperationQueue.main.addOperation({
                    completion(nil, nil,apiError)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                let apiError = NSError(domain: "SearchFlickr", code: 0, userInfo: nil)
                OperationQueue.main.addOperation({
                    completion(nil, nil,apiError)
                })
                    return
            }
            
            do {
                
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                    let stat = resultsDictionary["stat"] as? String else {
                        
                    let apiError = NSError(domain: "SearchFlickr", code: 0, userInfo: nil)
                    OperationQueue.main.addOperation({
                        completion(nil, nil,apiError)
                    })
                        return
                }
                
                switch (stat) {
                case "ok":
                    print("Result is OK")
                case "fail":
                    if let message = resultsDictionary["message"] {
                        let apiError = NSError(domain: "SearchFlickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:message])
                        OperationQueue.main.addOperation({
                            completion(nil, nil,apiError)
                        })
                    }
                    
                    let apiError = NSError(domain: "SearchFlickr", code: 0, userInfo: nil)
                    OperationQueue.main.addOperation({
                        completion(nil, nil,apiError)
                    })
                    
                    return
                default:
                    let apiError = NSError(domain: "SearchFlickr", code: 0, userInfo: nil)
                    OperationQueue.main.addOperation({
                        completion(nil, nil,apiError)
                    })
                    return
                }
                print(resultsDictionary)
                guard let photos = resultsDictionary["photos"] as? [String: AnyObject], let photosReceived = photos["photo"] as? [[String: AnyObject]] else {
                    let apiError = NSError(domain: "SearchFlickr", code: 0, userInfo: nil)
                    OperationQueue.main.addOperation({
                        completion(nil, nil,apiError)
                    })
                    return
                }
                var paging : FlickrPaging?
                var flickrPhotoObjects = [FlickrPhotoObject]()
                
                for photo in photosReceived {
                    guard let id = photo["id"] as? String,
                        let farm = photo["farm"] as? Int ,
                        let server = photo["server"] as? String ,
                        let secret = photo["secret"] as? String else {
                            break
                    }
                    let flickrPhotoObject = FlickrPhotoObject(photoId: id, photoFarm: farm, photoServer: server, photoSecret: secret)
                    flickrPhotoObjects.append(flickrPhotoObject)
                }
                
                if let currentPage = photos["page"] as? Int,
                    let totalPages = photos["pages"] as? Int ,
                    let numberOfElements = photos["total"] as? String {
                    paging = FlickrPaging(totalPages: totalPages, elements: Int32(numberOfElements)!, currentPage: currentPage)
                }
                
                OperationQueue.main.addOperation({
                    completion(FlickrSearchResults(results: flickrPhotoObjects),paging ,nil)
                })
            } catch _ {
                completion(nil, nil,nil)
                return
            }
            
            
        }) .resume()
    }
    
    // Returns the Flickr Search URL with search Term.
    fileprivate func getFlickrSearchURLForSearchTerm(_ searchTerm:String) -> URL? {
        guard let escapedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
    // Example link :
    //https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6af377dc54798281790fc638f6e4da5e&format=json&nojsoncallback=1&text=kittens
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&format=json&nojsoncallback=1&text=\(escapedSearchTerm)"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
}

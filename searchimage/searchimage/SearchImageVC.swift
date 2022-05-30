//
//  SearchImageVC.swift
//  searchimage
//
//  Created by Nandish Bellad on 29/05/2022.
//

import UIKit
import Combine

class SearchImageVC: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var customTextField: CustomUITextField!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var searchResults = FlickrSearchResults()
    let searchFlickr = SearchFlickr()
    var itemsPerRowInCollectionView: CGFloat = 2.0
    var paging : FlickrPaging?
    var loadMore: Bool = false
    let searchHistoryTVC = SearchHistoryTableVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = self
        customTextField.layer.borderWidth = 2.0
        customTextField.layer.borderColor = UIColor.systemGray.cgColor
        customTextField.layer.cornerRadius = 7
//        let leftBarButton = UIBarButtonItem(title: "Clear History", style: .plain, target: self, action: #selector(clearSearchHistory))
        let rightBarButton = UIBarButtonItem(title: "View History", style: .plain, target: self, action: #selector(searchHistoryButtonTapped))
        self.navigationController?.navigationBar.tintColor = .systemGray
        
//        self.navigationItem.setLeftBarButton(leftBarButton, animated: true)
        self.navigationItem.setRightBarButton(rightBarButton, animated: true)
    }
    
    @objc func clearSearchHistory() {
        UserDefaults.standard.setValue(nil, forKey: "SearchHistory")
    }
    
    @IBAction func searchHistoryButtonTapped(_ sender: Any) {
        print("searchHistoryButtonTapped")
        NotificationCenter.default.addObserver(self, selector: #selector(searchTermSelectedFromTable), name: NSNotification.Name("searchTermSelectedFromTable"), object: nil)
        self.performSegue(withIdentifier: "segueToSearchHistory", sender: self)
    }
    
    @objc func searchTermSelectedFromTable() {
        if let searchTerm = SearchHistoryTableVC.selectedSearchTerm {
            DispatchQueue.main.async {
                self.customTextField.text = searchTerm
                self.customTextField.becomeFirstResponder()
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("searchTermSelectedFromTable"), object: nil)
            }
        }
    }
    
    
    func invokeFlickrSearchApi (searchTerm: String, pageNo: Int) {
        // Use SearchFlickr wrapper class to search Flickr for photos that match the
        // given searchTerm asynchronously. When search completes, the completion block
        // will be called with the result set of FlickrPhotoObjects and error (if there is one)
        searchFlickr.searchFlickr(searchTerm, page: pageNo) { results, paging, error in
            
            self.customTextField.stopAnimating()
            if let paging = paging, paging.currentPage == 1 {
                //                ImageDownloadManager.shared.cancelAll()
                self.searchResults.results.removeAll()
                self.imageCollectionView.reloadData()
            }
            
            if let error = error {
                // Print errors to the console.
                print("Error while searching: \(error)")
                return
            }
            
            if let searchResults = results {
                print("Found \(searchResults.results.count) photos matching \(searchResults.searchTerm)")
                self.searchResults.results.removeAll()
                self.searchResults.results.append(contentsOf: searchResults.results)
                for photo in self.searchResults.results {
                    print("Photo url:  \(photo.flickrPhotoURL()?.absoluteString ?? "")")
                }
                self.paging = paging
                self.imageCollectionView.reloadData()
            }
            self.loadMore = false
        }
    }
    
    private func loadMorePhotos() {
        guard let searchTerm = self.customTextField.text, searchTerm.count > 0 else {
            return
        }
        if !loadMore && paging!.currentPage! < paging!.totalPages! {
            loadMore = true
            self.invokeFlickrSearchApi(searchTerm: searchTerm, pageNo: paging!.currentPage! + 1)
        }
    }
}

extension SearchImageVC : UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.searchResults.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let photoUrl = self.searchResults.results[indexPath.row].flickrPhotoURL() {
            cell.configure(with: photoUrl)
        } else {
            print("Photo url is nil")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastRowIndex = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.row == lastRowIndex && paging != nil {
            loadMorePhotos()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let cellWidth = (width - (CGFloat(itemsPerRowInCollectionView - 1) * CGFloat(3.0))) / CGFloat(itemsPerRowInCollectionView)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
                         
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
}

extension SearchImageVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.paging = nil
        self.loadMore = true
        guard let searchTerm = textField.text, searchTerm.count > 0 else {
            self.searchResults.results.removeAll()
            self.imageCollectionView.reloadData()
            self.loadMore = false
            return true
        }
        customTextField.startAnimating()
        self.searchResults.searchTerm = searchTerm
        if var searchHistoryArray = UserDefaults.standard.array(forKey: "SearchHistory") as? [String] {
            if searchHistoryArray.contains(searchTerm) == false {
                searchHistoryArray.append(searchTerm as String)
                UserDefaults.standard.setValue(searchHistoryArray, forKey: "SearchHistory")
            }
        } else {
            var searchHistoryArray:[String] = [String]()
            searchHistoryArray.append(searchTerm)
            UserDefaults.standard.setValue(searchHistoryArray, forKey: "SearchHistory")
        }
        
        self.invokeFlickrSearchApi(searchTerm: searchTerm, pageNo: 1)
    
        return true
    }
}

class ImageCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    private var cancellable: AnyCancellable?
    private var animator: UIViewPropertyAnimator?
        
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        photoImageView.alpha = 0.0
        if let animator = animator , animator.isRunning {
            animator.stopAnimation(true)
        }
        cancellable?.cancel()
    }
    
    public func configure(with photoUrl : URL) {
        cancellable = loadImage(for: photoUrl).sink { [unowned self] image in self.showImage(image: image) }
    }
    
    private func showImage(image: UIImage?) {
        photoImageView.alpha = 0.0
        if let animator = animator , animator.isRunning {
            animator.stopAnimation(false)
        }
        photoImageView.image = image
        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.photoImageView.alpha = 1.0
        })
    }
    
    private func loadImage(for photoUrl : URL) -> AnyPublisher<UIImage?, Never> {
        return Just(photoUrl)
            .flatMap({ tnUrl -> AnyPublisher<UIImage?,Never> in
                return ImageLoader.shared.loadImage(from: photoUrl)
            })
            .eraseToAnyPublisher()
    }
}


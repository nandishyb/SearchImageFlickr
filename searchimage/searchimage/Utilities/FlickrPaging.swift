//
//  FlickrPaging.swift
//  searchimage
//
//  Created by Nandish Bellad on 30/05/2022.
//

import Foundation

public class FlickrPaging {

    // MARK: - Properties
    public var totalPages: Int?
    public var totalNumberOfElements: Int32?
    public var currentSize: Int = 20
    public var currentPage: Int?

    // MARK: - Init method
    init(totalPages: Int, elements: Int32, currentPage: Int) {
        self.totalPages = totalPages
        self.totalNumberOfElements = elements
        self.currentPage = currentPage
    }
}

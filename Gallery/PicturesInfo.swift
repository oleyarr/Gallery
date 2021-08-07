//
//  PicturesArray.swift
//  Gallery
//
//  Created by Володя on 09.07.2021.
//

import Foundation

class PicturesInfo: Codable {
    var imageAddTime: Date
    var imageName: String
    var imageLikesCount: Int
    var imageComment: [ImageComment]
    
    init(imageAddTime: Date, imageName: String) {
        self.imageAddTime = imageAddTime
        self.imageName  = imageName
        self.imageLikesCount = 0
        imageComment = [ImageComment]()
    }
}

class ImageComment: Codable {
    var imageCommentTime: Date
    var imageCommentText: String
    
    init() {
        self.imageCommentTime = Date()
        imageCommentText = ""
    }
}

//
//  AddImageViewController.swift
//  Gallery
//
//  Created by Володя on 23.07.2021.
//

import UIKit

class AddImageViewController: NSObject {

    private var fileManager = FileManager.default
    private lazy var cacheFolderURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    private lazy var savedImagesFolderURL = cacheFolderURL.appendingPathComponent("Images")

    var completion: (() -> ())?
    
    var addedImage: UIImage?
    
    var viewController: ViewController
    var customCollectionViewCell: CustomCollectionViewCell
    
    init(viewController: ViewController, customCollectionViewCell: CustomCollectionViewCell) {
        self.viewController = viewController
        self.customCollectionViewCell = customCollectionViewCell
        super.init()
    }

    func addImage(completion: @escaping () -> ()) {
        self.completion = completion 
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        viewController.present(picker, animated: true)
        picker.sourceType = .photoLibrary
    }
    
}

extension AddImageViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        addedImage = info[.editedImage] as? UIImage
        
        print("AddImageViewController addedImage = ", addedImage)

        // записать выбранную картинку в каталог с новым именем
        let imageName = "\(Int(Date().timeIntervalSince1970)).png"
        print("loadPictureButtonPressed imageNameTMP =",imageName)
        let imageURL = savedImagesFolderURL.appendingPathComponent(imageName)
        fileManager.createFile(atPath: imageURL.path, contents: addedImage?.pngData(), attributes: [ : ])
        
        
        //и записать это имя в массив имен и в userDefaults.value(forKey: "Gallery")
        viewController.picturesInfoArray.append(PicturesInfoArray(imageAddTime: Date(), imageName: imageName))
        let encoder = JSONEncoder()
        let data = try? encoder.encode(viewController.picturesInfoArray)
        viewController.userDefaults.setValue(data, forKey: "Gallery")

        viewController.collectionView.reloadData()
        picker.dismiss(animated: true)
        
        completion?()
    }
}


//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
    
//

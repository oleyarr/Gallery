//
//  Gallery
//
//  Created by Володя on 23.07.2021.
//

import UIKit

class AddImageNSObject: NSObject {

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
        picker.sourceType = .photoLibrary
        viewController.present(picker, animated: true)
    }
}

extension AddImageNSObject: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        addedImage = info[.editedImage] as? UIImage
        // записать выбранную картинку в каталог с новым именем
        let imageName = "\(Int(Date().timeIntervalSince1970)).png"
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

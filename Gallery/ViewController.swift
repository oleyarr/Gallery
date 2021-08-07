
//  ViewController.swift
//  Gallery
//
//  Created by Володя on 08.07.2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadPictureButton: UIButton!
    
    var userDefaults = UserDefaults.standard
    var picturesInfoArray: [PicturesInfo] = []
    lazy var addImageToGallery = AddImageToGalleryPickerDelegate(viewController: self)
    var selectedIndexPath: IndexPath?
    private var fileManager = FileManager.default
    private lazy var cacheFolderURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    private lazy var savedImagesFolderURL = cacheFolderURL.appendingPathComponent("Images")
    
    override func viewDidAppear(_ animated: Bool) {
        popupPasswordViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            try? fileManager.createDirectory(at: savedImagesFolderURL, withIntermediateDirectories: true, attributes: [ : ])
            picturesInfoArray = getSavedPictures()
            collectionView.dataSource = self
            collectionView.delegate = self
    }

    @IBAction func loadPictureButtonPressed(_ sender: Any) {
        addImageToGallery.addImage {addedImage in
            // записать выбранную картинку в каталог с новым именем
            let imageName = "\(Int(Date().timeIntervalSince1970)).png"
            let imageURL = self.savedImagesFolderURL.appendingPathComponent(imageName)
            self.fileManager.createFile(atPath: imageURL.path, contents: addedImage.pngData(), attributes: [ : ])
            //и записать это имя в массив имен и в userDefaults.value(forKey: "Gallery")
            self.picturesInfoArray.append(PicturesInfo(imageAddTime: Date(), imageName: imageName))
            let encoder = JSONEncoder()
            let data = try? encoder.encode(self.picturesInfoArray)
            self.userDefaults.setValue(data, forKey: "Gallery")
            self.collectionView.reloadData()
        }
    }
    
    func popupPasswordViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let passwordViewController = storyboard.instantiateViewController(identifier: "PasswordViewController")
        passwordViewController.modalPresentationStyle = .overCurrentContext
        present(passwordViewController, animated: false)
    }

    func getSavedPictures() -> [PicturesInfo] {
        // достаем информацию о картинках: путь к картинкам, кол-во лайков, комменты и прочее
        if let dataKey = userDefaults.value(forKey: "Gallery") as? Data {
            let decoder = JSONDecoder()
            do {
                let getData = try decoder.decode([PicturesInfo].self, from: dataKey)
                return getData
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return []
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesInfoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath
        ) as? CustomCollectionViewCell else { return UICollectionViewCell() }
        if !(picturesInfoArray.count == 1 && picturesInfoArray[0].imageName == "default_image") {
            let imageFileName = picturesInfoArray[indexPath.item].imageName
            let imageFileURL = savedImagesFolderURL.appendingPathComponent(imageFileName)
            do {
                let imageData = try Data(contentsOf: imageFileURL)
                let image = UIImage(data: imageData)
                cell.imageViewInCell.image = image
            } catch {
                print("error= ",error.localizedDescription)
            }
        } else {
            cell.imageViewInCell.image = UIImage(named: "default_image")
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPath == nil {
            selectedIndexPath = indexPath   
            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.scrollDirection = .horizontal
                collectionView.isPagingEnabled = true
            }
        } else {
            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.scrollDirection = .vertical
                collectionView.isPagingEnabled = false
                selectedIndexPath = nil
            }
        }
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if selectedIndexPath == nil {
            return 10
        } else {
            return 0
            // 0 иначе не отображается выбранный image на полный экран при выборе, но при этом
            // картинки склеиваются по вертикали (можно задать констрейнтами отступ, но фон ячейки
            //  должен быть прозрачным)
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectedIndexPath == nil {
            return CGSize(width: collectionView.frame.size.width / 2 - 5, height: collectionView.frame.size.height / 5 - 10)
        } else {
            return collectionView.frame.size
        }
    }
    
}

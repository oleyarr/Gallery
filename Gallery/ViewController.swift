
//  ViewController.swift
//  Gallery
//
//  Created by Володя on 08.07.2021.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadPictureButton: UIButton!
    @IBOutlet weak var pickerImageView: UIImageView!
    @IBOutlet weak var testSizeView: UIView!
    
    var userDefaults = UserDefaults.standard
    var picturesInfoArray: [PicturesInfoArray] = []
    var pictureInfoArrayElement: PicturesInfoArray?
    var imagesArray: [UIImage] = []
    lazy var addImageViewController = AddImageViewController(viewController: self, customCollectionViewCell: CustomCollectionViewCell())
    var selectedIndexPath: IndexPath?
    
    private var fileManager = FileManager.default
    private lazy var cacheFolderURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    private lazy var savedImagesFolderURL = cacheFolderURL.appendingPathComponent("Images")
    
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? fileManager.createDirectory(at: savedImagesFolderURL, withIntermediateDirectories: true, attributes: [ : ])
//        print("savedImagesURL ",savedImagesFolderURL)
        picturesInfoArray = getSavedPictures()
        
        collectionView.dataSource = self
        moveImageViewCell()
        collectionView.delegate = self
        
    }

    @IBAction func loadPictureButtonPressed(_ sender: Any) {
        print("loadPictureButtonPressed")
        addImageViewController.addImage(completion: {
         print("проба completion")
        })
    }
    
    
    func getSavedPictures() -> [PicturesInfoArray] {
        // достаем информацию о картинках: путь к картинкам, кол-во лайков, комменты и прочее
        if let dataKey = userDefaults.value(forKey: "Gallery") as? Data {
            let decoder = JSONDecoder()
            do {
            let getData = try decoder.decode([PicturesInfoArray].self, from: dataKey)
                return getData
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return []
    }
    
    func moveImageViewCell() {
        print("moveImageViewCell started")
        testSizeView.frame = CGRect(x: 350, y: 150, width: 50, height: 50)//imageViewInCell.frame
        let saveFrame = testSizeView.frame
        print("saveFrame =", saveFrame)
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 1 / 60
            motionManager.startGyroUpdates(to: .main) { (data, error) in
                if let error = error {
                    print("error = ", error.localizedDescription)
                    return
                }
                if let gyroData = data {
//                    print(gyroData.rotationRate.x * 100)
//                    print(gyroData.rotationRate.y * 100)
//                    print(gyroData.rotationRate.z * 100)
                    self.testSizeView.frame.origin.x += (CGFloat(gyroData.rotationRate.y) * 10)
                    self.testSizeView.frame.origin.y +=  (CGFloat(gyroData.rotationRate.x ) * 10)
                    print("new collectionView.frame =", self.testSizeView.frame)
//                    self.collectionView.reloadData()
                }
            }
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesInfoArray.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as? CustomCollectionViewCell else { return UICollectionViewCell() }
        print("cellForItemAt. indexPath.item = ",indexPath.item)

        if !(picturesInfoArray.count == 1 && picturesInfoArray[0].imageName == "default_image") {
            let imageFileName = picturesInfoArray[indexPath.item].imageName
            print("cellForItemAt. imageFileName = ", imageFileName)
            let imageFileURL = savedImagesFolderURL.appendingPathComponent(imageFileName)
            print("cellForItemAt. imageFileURL = ", imageFileURL)
            do {
                let imageData = try Data(contentsOf: imageFileURL)
                let image = UIImage(data: imageData)
                cell.imageViewInCell.image = image
                print(image?.description)
            } catch {
                print("error= ",error.localizedDescription)
            }
        } else {
            cell.imageViewInCell.image = UIImage(named: "default_image")
        }
//        if let selectedIndexPath = selectedIndexPath {
//            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: true)
//        }
        return cell
    }
}



extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("indexPath = ",indexPath)
        
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
//        collectionView.reloadData()
        collectionView.reloadItems(at: [indexPath])
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectedIndexPath == nil {
            return CGSize(width: 150, height: 150)
        } else {
            return collectionView.frame.size
//                CGSize(width: 300, height: 300)
        }
    }
}




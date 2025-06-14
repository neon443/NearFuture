//
//  SymbolsPickerStoryboard.swift
//  NearFuture
//
//  Created by neon443 on 14/06/2025.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

class ViewController: UIViewController {
	@IBOutlet weak var collectionView: UICollectionView!
	var symbolLoader: SymbolsLoader = SymbolsLoader()
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			flowLayout.itemSize = CGSize(
				width: 100,
				height: 100
			)
		}
	}
}

extension ViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		symbolLoader.allSymbols.count
	}
	
	func collectionView(
		_ collectionView: UICollectionView,
		numberOfItemsInSection section: Int
	) -> Int {
		10
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SymbolCell
		
		let imageView = cell.imageView
		imageView?.image = UIImage(systemName: symbolLoader.allSymbols[indexPath.item])
		cell.textLabel?.text = "hi\(indexPath.row)"
		return cell
	}
}

extension ViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print(indexPath.item + 1)
	}
}

class SymbolCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var textLabel: UILabel!
	
}

struct SymbolsPickerStoryboardUIViewRepresentable: UIViewRepresentable {
	func makeUIView(context: Context) -> some UIView {
		let storyboard = UIStoryboard(name: "SymbolsPicker", bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: "SymbolsPicker") as! ViewController
		return viewController.view
	}
	
	func updateUIView(_ uiView: UIViewType, context: Context) {
		print()
	}
}


//
//  PeopleViewController.swift
//  ExpandingCollectionViewCell
//
//  Created by Shawn Gee on 9/28/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import SwiftUI
import UIKit

class PeopleViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case main
    }
    
    // MARK: - Private Properties
    
    private let people: [Person] = [
        Person(name: "Shawn", age: 31, favoriteColor: "Blue", favoriteMovie: "Dinner For Schmucks"),
        Person(name: "Bob", age: 54, favoriteColor: "Red", favoriteMovie: "Saving Private Ryan"),
        Person(name: "Susan", age: 23, favoriteColor: "Teal", favoriteMovie: "The Lion King"),
    ]
    
    private let flowLayout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    
    private let padding: CGFloat = 12
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        setUpLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Private Methods
    
    private func setUpLayout() {
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.minimumLineSpacing = padding
    }
    
    private func setUpCollectionView() {
        collectionView.register(PersonCell.self, forCellWithReuseIdentifier: String(describing: PersonCell.self))
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension PeopleViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection sectionNumber: Int) -> Int {
        guard let section = Section(rawValue: sectionNumber) else { return 0 }
        
        switch section { // using a switch and Section enum for future expandability
        case .main:
            return people.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: PersonCell.self),
            for: indexPath) as? PersonCell else {
                fatalError("Could not cast cell as \(PersonCell.self)")
        }
        cell.person = people[indexPath.item]
        cell.width = collectionView.bounds.width - padding * 2
        return cell
    }
}

// MARK: - Collection View Delegate

extension PeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        
        collectionView.performBatchUpdates(nil)
        
        return false // The selecting or deselecting is already performed above
    }
}

extension UICollectionViewDiffableDataSource {
    /// Reapplies the current snapshot to the data source, animating the differences.
    /// - Parameters:
    ///   - completion: A closure to be called on completion of reapplying the snapshot.
    func refresh(completion: (() -> Void)? = nil) {
        self.apply(self.snapshot(), animatingDifferences: true, completion: completion)
    }
}


// MARK: - SwiftUI Previews

struct PeopleVCWrapper: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<PeopleVCWrapper>) -> UIView {
        PeopleViewController().view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PeopleVCWrapper>) {}
}

struct PeopleVCWrapper_Previews: PreviewProvider {
    static var previews: some View {
        PeopleVCWrapper().edgesIgnoringSafeArea(.all) // remove this to respect safe area
    }
}

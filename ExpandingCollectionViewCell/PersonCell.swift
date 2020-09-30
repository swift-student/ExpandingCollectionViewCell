//
//  PersonCell.swift
//  ExpandingCollectionViewCell
//
//  Created by Shawn Gee on 9/29/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class PersonCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var person: Person? { didSet { updateContent() } }
    override var isSelected: Bool { didSet { updateAppearance() } }
    /// Use this property to set the width of the cell in `cellForItemAt`.
    var width: CGFloat? {
        didSet {
            guard let maxWidth = width else { return }
            widthConstraint?.constant = maxWidth
            widthConstraint?.isActive = true
        }
    }
    
    // MARK: - Private Properties
    
    // Views
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        return nameLabel
    }()
    private let ageLabel = UILabel()
    private let favoriteColorLabel = UILabel()
    private let favoriteMovieLabel = UILabel()
    
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.contentMode = .scaleAspectFit
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    
    // Stacks
    private lazy var rootStack: UIStackView = {
        let rootStack = UIStackView(arrangedSubviews: [labelStack, disclosureIndicator])
        rootStack.alignment = .top
        rootStack.distribution = .fillProportionally
        return rootStack
    }()
    private lazy var labelStack: UIStackView = {
        let labelStack = UIStackView(arrangedSubviews: [
            nameLabel,
            ageLabel,
            favoriteColorLabel,
            favoriteMovieLabel,
        ])
        labelStack.axis = .vertical
        labelStack.spacing = padding
        return labelStack
    }()
    
    // Constraints
    private var closedConstraint: NSLayoutConstraint?
    private var openConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    
    // Layout
    private let padding: CGFloat = 8
    private let cornerRadius: CGFloat = 8
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    // MARK: - Private Methods
    
    private func setUp() {
        backgroundColor = .systemGray6
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        
        contentView.addSubview(rootStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        
        setUpConstraints()
        updateAppearance()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])
        
        // Create a constraint for the width, which will be updated and activated by setting `width`
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 100)
        widthConstraint?.priority = .required
        
        // We need constraints that define the height of the cell when closed and when open
        // to allow for animating between the two states.
        closedConstraint =
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
            favoriteMovieLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        openConstraint?.priority = .defaultLow
    }

    private func updateContent() {
        guard let person = person else { return }
        nameLabel.text = person.name
        ageLabel.text = "Age: \(person.age)"
        favoriteColorLabel.text = "Favorite color: \(person.favoriteColor)"
        favoriteMovieLabel.text = "Favorite movie: \(person.favoriteMovie)"
    }
    
    /// Updates the views to reflect changes in selection
    private func updateAppearance() {
        closedConstraint?.isActive = !isSelected
        openConstraint?.isActive = isSelected
        
        UIView.animate(withDuration: 0.3) { // 0.3 seconds matches collection view animation
            // Set the rotation just under 180º so that it rotates back the same way
            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
            self.disclosureIndicator.transform = self.isSelected ? upsideDown :.identity
        }
    }
}

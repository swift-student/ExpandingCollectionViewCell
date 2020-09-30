[![Platform](https://img.shields.io/badge/platform-iOS%2013.0-lightgrey)](https://developer.apple.com) [![Swift Version](https://img.shields.io/badge/swift-5.2-orange.svg)](https://swift.org/)

# Expanding Collection View Cell

This is a sample project demonstrating how to set up a collection view cell and collection view controller to allow the cells to animate open and closed. The technique used here could also be used to do any number of other animations in the cell upon selection. The process is quite simple once you know how to do it, but can be a bit tricky trying to figure it out the first time around.

The branch you are viewing is set up to use a traditional collection view data source and flow layout. However, you can also [check out the master branch here](https://github.com/swift-student/ExpandingCollectionViewCell/tree/master) that uses a diffable data source and compositional layout for the collection view.

# Demo

![Demo](Demo.gif)

# Key Points

### Cell

When setting up your constraints, create properties for any constraints that need to be modified or activated/deactivated in order to open or close the cell, as well as a width constraint to allow the width to be set by the collection view controller.

``` swift
private var closedConstraint: NSLayoutConstraint?
private var openConstraint: NSLayoutConstraint?
private var widthConstraint: NSLayoutConstraint?
```

To allow the width to be set externally, create a public variable that, when set, activates the width constraint and sets it's constant:

``` sw
var width: CGFloat? {
    didSet {
        guard let maxWidth = width else { return }
        widthConstraint?.constant = maxWidth
        widthConstraint?.isActive = true
    }
}
```



Then take care to set up your constraints so that they properly define the height of your cell, and use priority to make sure your content stays where you want it when the cell expands and contracts:

``` swift
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
```

Also, don't forget to set those `translatesAutoresizingMasksIntoConstraints` to false:

``` swift
contentView.translatesAutoresizingMaskIntoConstraints = false
rootStack.translatesAutoresizingMaskIntoConstraints = false
```

In order to modify the cell's appearance when it is selected or deselected, use a `didSet` on the `isSelected` property of the cell to call an update method:

``` swift
override var isSelected: Bool { didSet { updateAppearance() } }
```

In the update method, modify the properties you would like to change. I found that constraints are properly animated in combination with the technique I used in the collection view delegate. However, other things such as transform must be explicitly animated in order to properly animate in all circumstances:

``` swift
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
```

### Collection View Layout

Set up your flow layout to use automatic sizing via the `estimatedItemSize` property:

``` swift
flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
```

### Collection View Delegate

In order to support deselecting the currently selected cell, implement `shouldSelectItemAt` instead of `didSelectItemAt`. Then in this method, manually select or deselect the cell. After doing so, let the collectionView animate the changes to the cell size by simply calling `performBatchUpdates` with `nil`:

``` swift
extension PeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        // Allows for closing an already open cell
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        
        collectionView.performBatchUpdates(nil)
        
        return false // The selecting or deselecting is already performed above
    }
}
```




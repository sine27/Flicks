# Project 2 - *Flicks* Part 2

**Flicks** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: 

- **7** hours spent in Version 2.1
- **3** hours spent in Version 2.2
- **2** hour spent in version 2.3 (Gesture enabled & code organized)
- **10** hour spent in version 2.4 (Review Table & Gesture & Animation & infinite scroll & movie Model)

**22** hours spent in total

## User Stories

The following **required** functionality is completed:

- ☑️ User can view movie details by tapping on a cell.
- ☑️ User can select from a tab bar for either **Now Playing** or **Top Rated** movies.
- ☑️ Customize the selection effect of the cell.

The following **optional** features are implemented:

- ☑️ For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- ☑️ Customize the navigation bar.

The following **additional** features are implemented:

- ☑️ User can show the content view by tapping the button and hide it by tapping outside or tapping the button.
- ☑️ User can scroll the content view.
- ☑️ User can sort the movies by swiching filter keys in the dropdown menu.
- ☑️ User can zoom the original poster in the detail view.
- ☑️ User can hide keyboard by tapping outside.
- ☑️ User can hide the dropdown menu by tapping outside.
- ☑️ User can pull to load more data.
- ☑️ User can view the review table by clicking the right navigation bar item.
- ☑️ User can view the full content of a review by tapping the cell.

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

version 2.4 review table

<img src='https://github.com/sine27/Flicks/blob/master/demo/assign2-4review.gif' title='tip calculation' width='270' alt='Video Walkthrough' />

version 2.2 tab view & zoom image

<img src='https://github.com/sine27/Flicks/blob/master/demo/assign2-2tabView.gif' title='tip calculation' width='150' alt='Video Walkthrough' />

version 2.1 detail view enabled with animation and custom navigation bar & filter (change by sorting key)

<img src='https://github.com/sine27/Flicks/blob/master/demo/assign2-1detail&filter.gif' title='tip calculation' width='150' alt='Video Walkthrough' />

## Notes

```swift
// CollectionView Layout
let layout = self.moviesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
let itemWidth = self.view.frame.width / 2
layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
layout.minimumInteritemSpacing = 0
layout.minimumLineSpacing = 0
layout.itemSize = CGSize(width: itemWidth, height: (1.5 * itemWidth))
  

// Sort Date
movies.sort {
    item1, item2 in
    let data1 = item1[key] as! String
    let data2 = item2[key] as! String
    let date1 = dateFormatter.date(from: data1)
    let date2 = dateFormatter.date(from: data2)
    return date1! > date2!
}


// Transparent NavigationBar
self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
// Sets shadow (line below the bar) to a blank image
self.navigationController?.navigationBar.shadowImage = UIImage()
// Sets the translucent background color
self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
// Set translucent. (Default value is already true, so this can be removed if desired.)
self.navigationController?.navigationBar.isTranslucent = true


// Scroll View Layout ignoring NavigationBar & BottomBar
self.automaticallyAdjustsScrollViewInsets = false


// Animation
UIView.animate(withDuration: 1.0, animations: {
    subView.alpha = 0
}, completion: { (finished: Bool) -> Void in
    subView.removeFromSuperview()
})


// Round Angle
contentView.layer.masksToBounds = true
contentView.layer.cornerRadius = radius


// Blur View
let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
let blurView = UIVisualEffectView(effect : blurEffect)
blurView.frame = moviePostImg.bounds
image.addSubview(blurView)


// Geture : Tap outside to hide
var tapGesture = UITapGestureRecognizer()
func whenGestureNeeded () {
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(MoviesViewController.autoHideWhenTapOutside(sender: )))
        viewTapped.addGestureRecognizer(tapGesture)
    }
}
func autoHideDropdownWhenTapOutside(sender: UITapGestureRecognizer) {
    hideTargetView()
    viewTapped.removeGestureRecognizer(tapGesture)
}

```

## License

    Copyright [2017] [Shayin Feng]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

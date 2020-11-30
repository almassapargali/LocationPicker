# LocationPicker

`LocationPickerViewController` is a `UIViewController` subclass to let users choose locations by searching or selecting on map.
It's designed to work as `UIImagePickerController`.

User can select location either by searching or long pressing on map. In both cases you'll receive CLPlacemark, which contains location coordinates as well as information such as the country, state, city, street address, and POI names.

## Installation

Uses Swift 5, use version `1.3.0` for Swift 4.2, `1.0.3` for Swift 3, `0.6.0` for Swift 2.

### Carthage

```
github "almassapargali/LocationPicker"
```

### CocoaPods

```
pod 'LocationPicker'
```

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a dependency manager built into Xcode. LocationPicker supports SPM from version 1.4.3.

If you are using Xcode 11 or higher, go to `File` -> `Swift Packages` -> `Add Package Dependency` and enter the [package repository URL](https://github.com/almassapargali/LocationPicker.git), then follow the instructions.

## Screenshots
| Map | Search | Select |
|---|---|---|
| ![][screen1] | ![][screen3] | ![][screen2] |

## Usage

Create a new instance in code (`LocationPickerViewController()`) or by setting class of `UIViewController` in Storyboard.
Then provide completion block which will be called when user closes view controller.

```swift
let locationPicker = LocationPickerViewController()

// you can optionally set initial location
let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.331686, longitude: -122.030656), addressDictionary: nil)
let location = Location(name: "1 Infinite Loop, Cupertino", location: nil, placemark: placemark)
locationPicker.location = location

// button placed on right bottom corner
locationPicker.showCurrentLocationButton = true // default: true

// default: navigation bar's `barTintColor` or `UIColor.white`
locationPicker.currentLocationButtonBackground = .blue

// ignored if initial location is given, shows that location instead
locationPicker.showCurrentLocationInitially = true // default: true

locationPicker.mapType = .Standard // default: .Hybrid

// for searching, see `MKLocalSearchRequest`'s `region` property
locationPicker.useCurrentLocationAsHint = true // default: false

locationPicker.searchBarPlaceholder = "Search places" // default: "Search or enter an address"

locationPicker.searchHistoryLabel = "Previously searched" // default: "Search History"

// optional region distance to be used for creation region when user selects place from search results
locationPicker.resultRegionDistance = 500 // default: 600

locationPicker.completion = { location in
    // do some awesome stuff with location
}

navigationController?.pushViewController(locationPicker, animated: true)
```

## License

LocationPicker is available under the MIT license. See the LICENSE file for more info.

[screen1]:https://raw.githubusercontent.com/almassapargali/LocationPicker/master/Screenshots/screen1.jpg
[screen2]:https://raw.githubusercontent.com/almassapargali/LocationPicker/master/Screenshots/screen2.png
[screen3]:https://raw.githubusercontent.com/almassapargali/LocationPicker/master/Screenshots/screen3.jpg

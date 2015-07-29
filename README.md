# LocationPicker

`LocationPickerViewController` is a `UIViewController` subclass to let users choose locations by searching or selecting on map.
It's designed to work as `UIImagePickerController`.

## Installation

### Carthage

```
github "almassapargali/LocationPicker"
```

## Screenshots

![](https://raw.githubusercontent.com/almassapargali/LocationPicker/master/Screenshots/screen1.jpg)

![](https://raw.githubusercontent.com/almassapargali/LocationPicker/master/Screenshots/screen2.jpg)

![](https://raw.githubusercontent.com/almassapargali/LocationPicker/master/Screenshots/screen3.jpg)

## Usage

Create a new instance in code (`LocationPickerViewController()`) or by setting class of `UIViewController` in Storyboard.
Then provide completion block which will be called when user closes view controller.

```swift
let locationPicker = LocationPickerViewController()

// you can optionally set initial location
let location = CLLocation(latitude: 35, longitude: 35)
let initialLocation = Location(name: nil, location: location)
locationPicker.location = initialLocation

// optional region distance to be used for creation region when user selects place from search results (defaults to 600)
locationPicker.resultRegionDistance = 500

locationPicker.completion = { location in
    // do some awesome stuff with location
}

navigationController?.pushViewController(locationPicker, animated: true)
```

*Note: `LocationPickerViewController` is expected to be pushed to `UINavigationController`. Pull requests for supporting other presentation styles are welcome*

## License

LocationPicker is available under the MIT license. See the LICENSE file for more info.
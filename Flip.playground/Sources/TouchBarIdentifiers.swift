import Cocoa

extension NSTouchBarItem.Identifier {
  static let colorScrubber = NSTouchBarItem.Identifier("flip.colorScrubber")
  static let colorLabel = NSTouchBarItem.Identifier("flip.colorLabel")
  static let toolLabel = NSTouchBarItem.Identifier("flip.toolLabel")
  static let toolSegmentedControl = NSTouchBarItem.Identifier("flip.toolSegmentedControl")
  static let playbackButton = NSTouchBarItem.Identifier("flip.playbackButton")
  static let newFrameButton = NSTouchBarItem.Identifier("flip.newFrameButton")
}

extension NSTouchBar.CustomizationIdentifier {
  static let colorPickerTouchBar = NSTouchBar.CustomizationIdentifier("flip.colorPickerTouchBar")
}

import AppKit
import PlaygroundSupport

/// A view controller that holds both the canvas FlipView and the TouchBar used to control it.
public class FlipViewController: NSViewController, NSTouchBarDelegate, NSScrubberDataSource, NSScrubberDelegate {
  
  
  var colorPalette: [NSColor]!
  
  var selectedColor: Int! {
    didSet {
      if let flipView = self.view as? FlipView {
        flipView.currentColor = selectedColor
      }
    }
  }
  
  let scrubberViewIdentifier = "scrubberViewIdentifier"
  
  override public func makeTouchBar() -> NSTouchBar? {
    let touchBar = NSTouchBar()
    touchBar.delegate = self
    touchBar.customizationIdentifier = .colorPickerTouchBar
    touchBar.defaultItemIdentifiers = [.colorLabel, .colorScrubber,.toolSegmentedControl, .fixedSpaceLarge,.playbackButton, .newFrameButton]
    touchBar.customizationAllowedItemIdentifiers = [.colorLabel, .colorScrubber,.toolSegmentedControl,.flexibleSpace,.playbackButton, .newFrameButton]
    return touchBar
  }
  
  public func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
    
    guard let flipView = self.view as? FlipView, let colorPalette = flipView.colorPalette else {return nil}
    
    self.colorPalette = colorPalette
    let viewItem = NSCustomTouchBarItem(identifier: identifier)
    
    switch identifier {
    case NSTouchBarItem.Identifier.colorLabel:
      let label = NSTextField(labelWithString: "Colors:")
      viewItem.view = label
      return viewItem
    
    case NSTouchBarItem.Identifier.toolLabel:
      let label = NSTextField(labelWithString: "Tool:")
      viewItem.view = label
      return viewItem
      
    case NSTouchBarItem.Identifier.colorScrubber:
      let scrubber = NSScrubber()
      scrubber.mode = .fixed
      scrubber.delegate = self
      scrubber.dataSource = self
      scrubber.register(NSScrubberTextItemView.self, forItemIdentifier: NSUserInterfaceItemIdentifier(rawValue: scrubberViewIdentifier))
      scrubber.scrubberLayout = NSScrubberFlowLayout()
      scrubber.selectionOverlayStyle = .outlineOverlay
      scrubber.floatsSelectionViews = true
      scrubber.selectedIndex = 1
      viewItem.view = scrubber
      return viewItem
      
    case NSTouchBarItem.Identifier.toolSegmentedControl:
     
      let bucket = NSImage(named: "bucket.pdf")!
      let pencil = NSImage(named: "pencil.pdf")!
      let control = NSSegmentedControl(images: [pencil, bucket], trackingMode: NSSegmentedControl.SwitchTracking.selectOne, target: nil, action: #selector(toolSelected(sender:)))
      control.setWidth(65, forSegment: 0)
      control.setWidth(65, forSegment: 1)
      control.setSelected(true, forSegment: 0)
      viewItem.view = control
      return viewItem
      
      
    case NSTouchBarItem.Identifier.playbackButton:
      guard let playImage = NSImage(named:NSImage.touchBarPlayTemplateName) else { return nil }
      let button = NSButton(image: playImage, target: nil, action: #selector(playbackTapped(sender:)))
      button.bezelColor = NSColor(srgbRed:0.451, green:0.543, blue:0.687, alpha:1.00)
      viewItem.view = button
      return viewItem
      
    case NSTouchBarItem.Identifier.newFrameButton:
      guard let addImage = NSImage(named:NSImage.touchBarAddDetailTemplateName) else { return nil }
      let button = NSButton(image: addImage, target: nil, action: #selector(newFrameButtonTapped))
      viewItem.view = button
      return viewItem
      
    default: return nil
    }
  }
  
  // selectors
  
  @objc func playbackTapped(sender: Any) {
    guard let flipView = self.view as? FlipView, let button = sender as? NSButton else { return }
    
    if flipView.isPlaying {
      flipView.stop()
      button.image = NSImage(named: NSImage.touchBarPlayTemplateName)
    } else {
      flipView.play()
      button.image = NSImage(named: NSImage.touchBarRecordStopTemplateName)
    }
  }
  
  @objc func newFrameButtonTapped() {
    if let flipView = self.view as? FlipView {
      flipView.newFrame()
    }
  }
  
  @objc func toolSelected(sender: Any) {
    if let control = sender as? NSSegmentedControl, let flipView = self.view as? FlipView {
      //Change the tool depending on segmented control selection
      flipView.currentTool = (control.selectedSegment == 0) ? .pencil : .bucket
    }
  }
  
  //  MARK: - ScrubberDataSource
  
  public func numberOfItems(for scrubber: NSScrubber) -> Int {
    return self.colorPalette.count
  }
  public func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
    if let itemView = scrubber.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: scrubberViewIdentifier), owner: nil) as? NSScrubberTextItemView {
      itemView.layer?.backgroundColor = self.colorPalette[index].cgColor
      itemView.layer?.cornerRadius = 5
      return itemView
    }
    return NSScrubberItemView()
  }
  
  // MARK: - ScrubberDelegate
  public func scrubber(_ scrubber: NSScrubber, didSelectItemAt selectedIndex: Int) {
    self.selectedColor = selectedIndex
  }
}

# CHANGELOG

## 3.10.7

Gestures improvements.

## 3.10.6

Status bar management improvements.
Updated documentation.

## 3.10.5

Further improvements to iOS 18 support.
Internal improvements.
Fixed safe area inset and layout margin issues.
PBPopupContentView improvements.
PBPopupCloseButton improvements.
Exposes the popupCloseButton on the content view controller.
Status bar management improvements.
Added support for prefersHomeIndicatorAutoHidden / setNeedsUpdateOfHomeIndicatorAutoHidden.
Added a property (shouldUseSnapshotForPresentingView) to present the popup without capturing the presenting view.
The presenting view will be scaled if popupController.shouldUseSnapshotForPresentingView is false (default).

## 3.10.4

Popup content dismissal animation improvements.
Configure the visual effects of the popup content view to match those of the popup bar.
Asks the delegate for additional animations to add to the animator while opening/closing the popup content view.

## 3.10.3

Updated background color for bars transition.

## 3.10.2

Improved popup content frame animation when popup bar is floating & presentation is interactive.

## 3.10.1

iOS 18.0 Support (Final).

## 3.10.0

iOS 18 Support (Initial).

## 3.9.10

Minor fix.

## 3.9.9

Fixed the display of the popup bar and bottom bar shadow line.

## 3.9.8

Updated popup content safe area insets.
Updated popup close button position.
Status bar style animation improvements.
Updated demo project.

## 3.9.7

Fixes a bug where Apple does not correctly update the safe area insets when closing a navigation controller is canceled.
Updates example.

## 3.9.6

Improved the presentation animation of floating popup bars.

## 3.9.5

Improved the presentation animation of popup vontent view when floating popup bars.
Improved popup bar title and subtitle layout and appearance.

## 3.9.4

Adds hooks for shouldOpen, shouldClose, tapGestureShouldBegin and panGestureShouldBegin (swiftUI).
Exposes the `.popupContentViewCustomizer()` modifier, which allows lower-level customization through the UIKit `PBPopupContentView` object (swiftUI).
Adds the `.popupContentBackground()` modifier to fixe ignoresSafeArea() displaying view out of bounds (swiftUI).
Improves popup content rotation.
Updates example.
Updates documentation.

## 3.9.3

Remove the unnecessary safe area modifier.

## 3.9.2

Minor presentation and rotation tweaks.
SwiftUI updates and improvements.

## 3.9.1

Update Package.swift (iOS v13).
SwiftUI updates.
Added support for haptic feedback when interacting with the popup.
Bug fixes and improvements.
Update documentation.

## 3.9.0

Updated example.
Set iOS minimum deployment target to 13.0.
Gesture improvements.
Width support for custom bars.
Improved popup presentation.
Navigation transition improvement ([issue #29](https://github.com/iDevelopper/PBPopupController/issues/29)

## 3.8.1 - 3.8.2 - 3.8.3

Update Cocoapods home page.

## 3.8.0

Update iOS minimum deployment target to 12.0.

## 3.7.7

Improved floating popup bar background shadow and exposed it.
Update documentation.

## 3.7.6

Added [smooth-gradient](https://github.com/janselv/smooth-gradient) Copyright (c) 2016 Jansel Valentin.
Floating popup bar layout improvements.
Improved floating popup bar animation when hidesPopupBarWhenPushed.
Example update.
Update documentation.

## 3.7.5

Fixes popup bar tint color issue (SplitViewController detail).
Example update.

## 3.7.4

Added support for very large content category sizes by adjusting the labels height.

## 3.7.2 - 3.7.3

Podspecs Update.

## 3.7.1

SPM Update.

## 3.7.0

iOS 17 Support.
New “Floating" Popup Bar Style.

## 3.6.16

Status bar appearance and animation improvements.
Configure TabBar, NavBar & Toolbar appearances.

## 3.6.15

Status bar appearance and animation improvements.

## 3.6.14

SwiftUI improvements.
Update documentation.

## 3.6.13

Pan gesture bug fixes and improvements for dismissal transition.
Console logs from PBPopupController module can be disabled.

## 3.6.11 & 3.6.12

Pan gesture bug fixes and improvements.

## 3.6.9 & 3.6.10

Screenshot improvements.

## 3.6.8

Gestures animations and conflicts improvements.

## 3.6.7

Reset the corner radius for the aesthetics of the animation of the control center presentation when state is open (issue #23).

## 3.6.6

Example improvements.

## 3.6.5

Fixes a popup bar layout issue after transition to size.

## 3.6.4

Fix for bad layout animation when the bottom bar is the toolbar of a navigation controller.

## 3.6.3

Fix for bad layout animation when the bottom bar is the toolbar of a navigation controller.
Bug fixes when hidesPopupBarWhenPushed is true.

## 3.6.2

iOS 16 support.

## 3.6.1

Gestures improvements.

## 3.6.0

Update for SwiftUI.

## 3.4.10

Layout improvements.

## 3.4.9

Minor fixes.

## 3.4.8

iOS 15 support.
Improvements.
Updated example.

## 3.4.7

Fixes incorrect additionalSafeAreaInsets in some cases.

## 3.4.6

Fixes a bug introduced in version 3.4.4 when the view of the content view controller is a scroll view.
Fixes popup bar appearance when the container is a navigation controller.
Remove unnecessary code.

## 3.4.5

Adds the ability to add a view to close the controller by swiping down.
Documentation updates.

## 3.4.4

Fix a crash when popupCloseButtonStyle is set to none## 3.4.4

## 3.4.3

Custom popupPresentationStyle width.
Status bar appearance and animation improvements.
Documentation updates.

## 3.4.2

Fix popup bar highlightView background color according user interface style.
Do not snapshot the backing view when enter in background.

## 3.4.1

Fix issue #12.
Change the default value for popupContentView.popupIgnoreDropShadowView to true.

## 3.4.0

SwiftPM Support.

## 3.3.0

SwiftUI Support (WIP).

## 3.2.3

Update travis.
Documentation updates.

## 3.2.2

Do not override user interface style.

## 3.2.1

Fixes backing view corner radius issue.
Fixes additional safe area bug.

## 3.2.0

More layout Improvements.
iOS 14 support improvements.
Demo project updates.

## 3.1.0

Improvements.
iOS 14 support.
Updated example.

## 3.0.1

Improve rotation when popup content is open.

## 3.0.0

Version 3.0.0: Completely revisited.
Dropping support for iOS 9, 10.
Adding support for macOS Catalyst.

## 2.1.1

Fix toolbar layout issue.

## 2.1.0

Fix layout issues.

## 2.0.0

Refactor, improvements and fix layout issues.

## 1.1.0

Support iOS 13 dark mode.

## 1.0.6

Do not end the popup bar gesture recognizer when the finger is still pressed on the screen and the popup controller is closed.

## 1.0.5

Remove 1.0.4 tag.

## 1.0.4

Enhancements and refactor.

## 1.0.3

hidesBottomBarWhenPushed animation fix.

## 1.0.2

Bug fixes.

## 1.0.1

Bug fixes.

## 1.0.0

The fisrt version.

Pod::Spec.new do |s|

    s.name         = "PBPopupController"
    s.version      = "3.10.8"
    s.summary      = "A framework for presenting bars and view controllers as popup, much like the look and feel of Apple Music App."
    # s.readme       = 'https://raw.githubusercontent.com/iDevelopper/PBPopupController/#{s.version.to_s}/README.md'
    # s.changelog    = 'https://raw.githubusercontent.com/iDevelopper/PBPopupController/#{s.version.to_s}/CHANGELOG.md'

    s.description  = <<-DESC
    PBPopupController is a framework for presenting bars and view controllers as popup, much like the look and feel of Apple Music App.
    DESC

    s.homepage     = 'https://github.com/iDevelopper/PBPopupController'
    s.documentation_url = 'http://iDevelopper.github.io/PBPopupController/'

    # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

    s.license = { :type => "MIT", :file => "LICENSE" }

    s.author             = { "iDevelopper" => "patrick.bodet4@wanadoo.fr" }

    s.platform     = :ios
    s.ios.deployment_target = '13.0'

    s.source       = { :git => "https://github.com/iDevelopper/PBPopupController.git", :tag => "#{s.version}" }

    s.source_files  = "PBPopupController/PBPopupController/PBPopupController-Swift/*.{swift}", "PBPopupController/PBPopupController/PBPopupController-Swift/SwiftUIWrapper/*.{swift}",
        "PBPopupController/PBPopupController/PBPopupController-ObjC/*.{h,m}",
        "PBPopupController/PBPopupController/PBPopupController-ObjC/Private/*.{h,m}"

    s.swift_version = '5.2'

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

    s.resources = "PBPopupController/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

    s.requires_arc = true

end

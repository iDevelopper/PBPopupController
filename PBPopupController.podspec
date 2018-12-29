Pod::Spec.new do |s|

    s.name         = "PBPopupController"
    s.version      = "0.1.0"
    s.summary      = "PBPopupController is a framework for presenting view controllers as popups."

    s.description  = <<-DESC
    PBPopupController is a framework for presenting view controllers as popups, much like the Apple Music and Podcasts apps.
    DESC

    s.homepage     = "https://github.com/iDevelopper/PBPopupController"
    # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

    s.license = { :type => "MIT", :file => "LICENSE" }

    s.author             = { "iDevelopper" => "patrick.bodet4@wanadoo.fr" }

    s.platform     = :ios
    s.ios.deployment_target = '9.3'

    s.source       = { :git => "https://github.com/iDevelopper/PBPopupController.git", :tag => "#{s.version}" }

    s.source_files  = "PBPopupController/**/*.{swift,h,m}"
    # s.exclude_files = "PBPopupController/CGMathSwift"

    s.swift_version = '4.2'

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

    s.resources = "PBPopupController/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

    s.requires_arc = true

end

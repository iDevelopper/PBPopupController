Pod::Spec.new do |s|

    s.name         = "PBPopupController"
    s.version      = "2.1.1"
    s.summary      = "A framework for presenting bars and view controllers as popup, much like the look and feel of Apple Music App."

    s.description  = <<-DESC
    PBPopupController is a framework for presenting bars and view controllers as popup, much like the look and feel of Apple Music App.
    DESC

    s.homepage     = "https://github.com/iDevelopper/PBPopupController"
    s.documentation_url = 'http://iDevelopper.github.io/PBPopupController/'

    # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

    s.license = { :type => "MIT", :file => "LICENSE" }

    s.author             = { "iDevelopper" => "patrick.bodet4@wanadoo.fr" }

    s.platform     = :ios
    s.ios.deployment_target = '9.3'

    s.source       = { :git => "https://github.com/iDevelopper/PBPopupController.git", :tag => "#{s.version}" }

    s.source_files  = "PBPopupController/**/*.{swift,h,m}"
    # s.exclude_files = "PBPopupController/CGMathSwift"

    s.swift_version = '5.0'

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

    s.resources = "PBPopupController/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

    s.requires_arc = true

end

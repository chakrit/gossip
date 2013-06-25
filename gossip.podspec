# vim: filetype=ruby
#
# Be sure to run `pod spec lint gossip.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "gossip"
  s.version      = "0.1.0"
  s.summary      = "A SIP client library that wraps PJSIP into a nice and clean OO api."
  s.homepage     = "https://github.com/chakrit/gossip"
  s.license      = { :type => 'Public Domain', :file => 'LICENSE.md' }
  s.author       = { "Chakrit Wichian" => "service@chakrit.net" }
  s.source       = { :git => "https://github.com/chakrit/gossip.git", :tag => "v0.1.0" }
  s.platform     = :ios, '5.1'

  s.source_files = 'Gossip', 'Gossip/**/*.{h,m}'
  s.resource = "GossipExample/ringtone.wav"

  s.frameworks = 'AudioToolbox', 'AVFoundation', 'CFNetwork', 'CoreMedia', 'CoreVideo', 'CoreAudio', 'Foundation'
  # Specify a list of libraries that the application needs to link
  # against for this Pod to work.
  #
  # s.library   = 'iconv'
  # s.libraries = 'iconv', 'xml2'
  s.libraries =
    "libg729codec-arm-apple-darwin10.a",
    "libg7221codec-arm-apple-darwin10.a",
    "libgsmcodec-arm-apple-darwin10.a",
    "libilbccodec-arm-apple-darwin10.a",
    "libmilenage-arm-apple-darwin10.a",
    "libpj-arm-apple-darwin10.a",
    "libpjlib-util-arm-apple-darwin10.a",
    "libpjmedia-arm-apple-darwin10.a",
    "libpjmedia-audiodev-arm-apple-darwin10.a",
    "libpjmedia-codec-arm-apple-darwin10.a",
    "libpjmedia-videodev-arm-apple-darwin10.a",
    "libpjnath-arm-apple-darwin10.a",
    "libpjsdp-arm-apple-darwin10.a",
    "libpjsip-arm-apple-darwin10.a",
    "libpjsip-simple-arm-apple-darwin10.a",
    "libpjsip-ua-arm-apple-darwin10.a",
    "libpjsua-arm-apple-darwin10.a",
    "libresample-arm-apple-darwin10.a",
    "libspeex-arm-apple-darwin10.a",
    "libsrtp-arm-apple-darwin10.a"

  s.requires_arc = true

  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => [
      "$(SRCROOT)/pjsip/source/pjlib/include",
      "$(SRCROOT)/pjsip/source/pjlib-util/include",
      "$(SRCROOT)/pjsip/source/pjmedia/include",
      "$(SRCROOT)/pjsip/source/pjnath/include",
      "$(SRCROOT)/pjsip/source/pjsip/include",
      "$(SRCROOT)/pjsip/source/third_party/resample/include",
      "$(SRCROOT)/pjsip/source/third_party/speex/include",
      "$(SRCROOT)/pjsip/source/third_party/srtp/crypto/include",
      "$(SRCROOT)/pjsip/source/third_party/srtp/include",
    ],
    'LIBRARY_SEARCH_PATHS' => [
      "$(inherited)",
      "$(SRCROOT)/pjsip/lib",
      "$(SRCROOT)/pjsip",
      "$(SRCROOT)/pjsip/g729",
      "$(SRCROOT)/pjsip/source/third_party/lib",
    ],
  }
end

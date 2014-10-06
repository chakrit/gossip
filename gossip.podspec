# vim: filetype=ruby
#
# Be sure to run `pod spec lint gossip.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "gossip"
  s.version      = "0.1.1"
  s.summary      = "A SIP client library that wraps PJSIP into a nice and clean OO api."
  s.homepage     = "https://github.com/chakrit/gossip"
  s.license      = { :type => 'Public Domain', :file => 'LICENSE.md' }
  s.author       = { "Chakrit Wichian" => "service@chakrit.net" }
  s.source       = { :git => "https://github.com/chakrit/gossip.git", :tag => "v0.1.1" }
  s.platform     = :ios, '6.0'

  s.source_files = 'Gossip', 'Gossip/**/*.{h,m}'
  s.resource = "GossipExample/ringtone.wav"

  s.frameworks = 'AudioToolbox', 'AVFoundation', 'CFNetwork', 'CoreMedia', 'CoreVideo', 'CoreAudio', 'Foundation'
  # Specify a list of libraries that the application needs to link
  # against for this Pod to work.
  #
  # s.library   = 'iconv'
  # s.libraries = 'iconv', 'xml2'
  s.libraries =
    "libg7221codec-arm-apple-darwin9.a",
    "libgsmcodec-arm-apple-darwin9.a",
    "libilbccodec-arm-apple-darwin9.a",
    "libmilenage-arm-apple-darwin9.a",
    "libpj-arm-apple-darwin9.a",
    "libpjlib-util-arm-apple-darwin9.a",
    "libpjmedia-arm-apple-darwin9.a",
    "libpjmedia-audiodev-arm-apple-darwin9.a",
    "libpjmedia-codec-arm-apple-darwin9.a",
    "libpjmedia-videodev-arm-apple-darwin9.a",
    "libpjnath-arm-apple-darwin9.a",
    "libpjsdp-arm-apple-darwin9.a",
    "libpjsip-arm-apple-darwin9.a",
    "libpjsip-simple-arm-apple-darwin9.a",
    "libpjsip-ua-arm-apple-darwin9.a",
    "libpjsua-arm-apple-darwin9.a",
    "libresample-arm-apple-darwin9.a",
    "libspeex-arm-apple-darwin9.a",
    "libsrtp-arm-apple-darwin9.a"

  s.requires_arc = true

  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => [
      "$(SRCROOT)/pjsip/src/pjlib/include",
      "$(SRCROOT)/pjsip/src/pjlib-util/include",
      "$(SRCROOT)/pjsip/src/pjmedia/include",
      "$(SRCROOT)/pjsip/src/pjnath/include",
      "$(SRCROOT)/pjsip/src/pjsip/include",
      "$(SRCROOT)/pjsip/src/third_party/resample/include",
      "$(SRCROOT)/pjsip/src/third_party/speex/include",
      "$(SRCROOT)/pjsip/src/third_party/srtp/crypto/include",
      "$(SRCROOT)/pjsip/src/third_party/srtp/include",
    ].join(' '),
    'LIBRARY_SEARCH_PATHS' => [
      "$(inherited)",
      "$(SRCROOT)/pjsip/lib",
      "$(SRCROOT)/pjsip",
      "$(SRCROOT)/pjsip/source/third_party/lib",
    ].join(' '),
  }
end

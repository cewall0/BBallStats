//
//  BannerAdView.swift
//  My BBaller Stats
//
//  Created by Chad Wallace on 2/20/25.
//

import Foundation
import GoogleMobileAds
import SwiftUI
import UIKit

enum AdFormat {
    case standardBanner
    case largeBanner
    case mediumRectangle
    case fullBanner
    case leaderboard
    case skyscraper
    case fluid
    case adaptiveBanner
    var adSize: GADAdSize {
        switch self {
        case .standardBanner: return GADAdSizeBanner // iPhone and iPod Touch ad size. Typically 320x50.
        case .largeBanner: return GADAdSizeLargeBanner // Taller version of GADAdSizeBanner. Typically 320x100.
        case .mediumRectangle: return GADAdSizeMediumRectangle // Medium rectangle size for iPad (especially in UISplitView's left pane). Typically 300x250.
        case .fullBanner: return GADAdSizeFullBanner // Full Banner size for the iPad (especially in a UIPopoverController or in UIModalPresentationFormSheet). Typidally 48x60.
        case .leaderboard: return GADAdSizeLeaderboard // Leaderboard size for the iPad. Typcially 728x90.
        case .skyscraper: return GADAdSizeSkyscraper // Skyscraper size for the iPad. Mediation only. AdMob/Google does not offer this size. Typically 120x600.
        case .fluid: return GADAdSizeFluid // An ad size that spans the full width of its container, with a height of dynamically determined by the ad.
        case .adaptiveBanner: return GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width)
        }
    }
    var size: CGSize {
        adSize.size
    }
}
// --------------
enum AdStatus {
    case loading
    case success
    case failure
}
// -------------
struct BannerAdView: View {
    var adUnit: AdUnit = AdUnit.homeBanner
    let adFormat: AdFormat
    @State var adStatus: AdStatus = .loading
    var onShow: () -> Void
    @AppStorage("isPurchased") var isPurchased = false
    var body: some View {
        if !isPurchased {
            HStack {
                if adStatus != .failure {
                    BannerView(adUnitID: adUnit.unitID, adSize: adFormat.adSize, adStatus: $adStatus)
                        .frame(width: adFormat.size.width, height: adFormat.size.height)
                        .onChange(of: adStatus) {
                            if adStatus == .success {
                                onShow()
                            }
                        }
                }
            }.frame(maxWidth: .infinity)
        }
        else {
            EmptyView()
        }
    }
}

// -------------
struct BannerView: UIViewControllerRepresentable {
    let adUnitID: String
    let adSize: GADAdSize
    @Binding var adStatus: AdStatus
    init(adUnitID: String, adSize: GADAdSize, adStatus: Binding<AdStatus>) {
        self.adUnitID = adUnitID
        self.adSize = adSize
        _adStatus = adStatus
    }
@State private var viewWidth: CGFloat = .zero
private let bannerView = GADBannerView()
// private let adUnitID = "ca-app-pub-5511806561009019~3126056249"
func makeUIViewController(context: Context) -> some UIViewController {
    let bannerViewController = BannerViewController()
    bannerView.adUnitID = adUnitID
    bannerView.rootViewController = bannerViewController
    bannerView.delegate = context.coordinator
    bannerViewController.view.addSubview(bannerView)
    bannerViewController.delegate = context.coordinator
    return bannerViewController
}
func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    // guard viewWidth != .zero { return }
    bannerView.adSize = adSize // GADCurrentOrientationAnchorAdaptiveBannerAdSizeWithWidth(viewWidth)
    bannerView.load(GADRequest())
}
func makeCoordinator() -> Coordinator {
    Coordinator(self)
}
internal class Coordinator: NSObject, BannerViewControllerWidthDelegate, GADBannerViewDelegate {
    let parent: BannerView
    init(_ parent: BannerView) {
        self.parent = parent
    }
        // MARK: - BannerViewControllerWidthDelegate methods
        func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat
        ) {
            parent.viewWidth = width
        }
        // MARK: - GADBannerViewDelegate Methods
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("bannerViewDidReceiveAd")
            parent.adStatus = .success
        }
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("DidFailToReceiveWithError: \(error.localizedDescription)")
            parent.adStatus = .failure
        }
        
        func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
            print("bannerViewDidRecordImpression")
        }
        
        func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
            print("bannerViewDidRecordClick")
        }
        
        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
            print("bannerViewWillPresentScreen")
        }
        
        func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
            print("bannerViewWillDismissScreen")
        }
        }
        }
protocol BannerViewControllerWidthDelegate: AnyObject {
    func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat)
}
class BannerViewController: UIViewController {
    weak var delegate: BannerViewControllerWidthDelegate?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.bannerViewController(
            self, didUpdate: view.frame.inset(by: view.safeAreaInsets).size.width)
        }
    override func viewWillTransition(
        to size: CGSize, with coordinator:  UIViewControllerTransitionCoordinator
    ) {
        coordinator.animate { _ in
            // do nothing
        } completion: { _ in
            self.delegate?.bannerViewController(
                self, didUpdate: self.view.frame.inset(by: self.view.safeAreaInsets).size.width)
    }
    }
}
// ___________




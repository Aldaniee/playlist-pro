//
//  Extensions.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/22/20.
//

import UIKit
import Foundation
import AVFoundation

extension String {
    func safeDatabaseKey() -> String {
        return replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-").lowercased()
    }
    func strippingHTML() throws -> String?  {
            if isEmpty {
                return nil
            }
            
            if let data = data(using: .utf8) {
                let attributedString = try NSAttributedString(data: data,
                                                              options: [.documentType : NSAttributedString.DocumentType.html,
                                                                        .characterEncoding: String.Encoding.utf8.rawValue],
                                                              documentAttributes: nil)
                var string = attributedString.string
               
                // These steps are optional, and it depends on how you want handle whitespace and newlines
                string = string.replacingOccurrences(of: "\u{FFFC}",
                                                     with: "",
                                                     options: .regularExpression,
                                                     range: nil)
                string = string.replacingOccurrences(of: "(\n){3,}",
                                                     with: "\n\n",
                                                     options: .regularExpression,
                                                     range: nil)
                return string.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            return nil
        }
}


// MARK: UIApplication
extension UIApplication {
    
    /*class func getCurrentViewController(base: UIViewController? = UIApplication.shared.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getCurrentViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getCurrentViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getCurrentViewController(base: presented)
        }
        return base
    }*/
    
    var version: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    var buildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }

}

// MARK: UIViewController
var spinner_view: UIView?
var progress_view: UIView?

extension UIViewController {
    func showSpinner(onView : UIView, withTitle title: String?) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width*0.65, height: 40))
        titleLbl.text = title ?? ""
        titleLbl.textColor = .white
        titleLbl.font = UIFont.systemFont(ofSize: 34)
        
        titleLbl.textAlignment = .center
        titleLbl.center = ai.center
        titleLbl.frame = CGRect(x: titleLbl.frame.minX, y: titleLbl.frame.minY - ai.frame.height - 10,
                                width: titleLbl.frame.width, height: titleLbl.frame.height)

        DispatchQueue.main.async {
            spinnerView.addSubview(titleLbl)
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        spinner_view = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            spinner_view?.removeFromSuperview()
            spinner_view = nil
        }
    }
    
    func showProgressView(onView : UIView, withTitle title: String?) {
        let progressView = UIView.init(frame: onView.bounds)
        progressView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        let boxView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width*0.65, height: 80))
        boxView.backgroundColor = .white
        boxView.layer.cornerRadius = 10.0
        boxView.layer.borderWidth = 2.0
        boxView.layer.borderColor = UIColor.darkPink.cgColor
        boxView.center = progressView.center

        let pBar = UIProgressView(frame: CGRect(x: boxView.frame.width*0.1, y: boxView.frame.height * 0.8, width: boxView.frame.width*0.8, height: 2))
        pBar.tag = 10
        pBar.progressTintColor = .darkPink
        pBar.progress = 0.0
        
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 0, width: pBar.frame.width, height: pBar.frame.minY - 10))
        titleLbl.text = title ?? ""
        titleLbl.font = .systemFont(ofSize: 30)
        titleLbl.textAlignment = .center
        titleLbl.center = pBar.center
        titleLbl.frame = CGRect(x: titleLbl.frame.minX, y: 5,
                                width: titleLbl.frame.width, height: titleLbl.frame.height)

        
        DispatchQueue.main.async {
            boxView.addSubview(titleLbl)
            boxView.addSubview(pBar)
            progressView.addSubview(boxView)
            onView.addSubview(progressView)
        }
        
        progress_view = progressView
    }

    func updateProgressView(to value: Double) {
        DispatchQueue.main.async {
            (progress_view?.viewWithTag(10) as! UIProgressView).progress = Float(value)
        }
    }

    func removeProgressView() {
        DispatchQueue.main.async {
            progress_view?.removeFromSuperview()
            progress_view = nil
        }
    }

    
    func getSelectedTextField() -> UITextField? {
        let totalTextFields = getTextFieldsInView(view: self.view)
        
        for textField in totalTextFields {
            if textField.isFirstResponder {
                return textField
            }
        }
        return nil
    }
    
    func getTextFieldsInView(view: UIView) -> [UITextField] {
        var totalTextFields = [UITextField]()
        
        for subview in view.subviews as [UIView] {
            if let textField = subview as? UITextField {
                totalTextFields += [textField]
            } else {
                totalTextFields += getTextFieldsInView(view: subview)
            }
        }
        return totalTextFields
    }
    
    func getSelectedTextView() -> UITextView? {
        let totalTextViews = getTextViewsInView(view: self.view)
        
        for textView in totalTextViews {
            if textView.isFirstResponder {
                return textView
            }
        }
        return nil
    }
    
    func getTextViewsInView(view: UIView) -> [UITextView] {
        var totalTextViews = [UITextView]()
        
        for subview in view.subviews as [UIView] {
            if let textView = subview as? UITextView {
                totalTextViews += [textView]
            } else {
                totalTextViews += getTextViewsInView(view: subview)
            }
        }
        return totalTextViews
    }

}

// MARK: UIView
extension UIView {
    func applyDiagonalButtonGradient(colors: [CGColor]) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = Constants.UI.cornerRadius

        gradientLayer.shadowColor = UIColor.lightGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 0.3
        gradientLayer.masksToBounds = false

        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    func applyButtonGradient(colors: [CGColor]) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = Constants.UI.cornerRadius

        gradientLayer.shadowColor = UIColor.lightGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 0.3
        gradientLayer.masksToBounds = false

        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    func applyGradient(colors: [CGColor]) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)

        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    public var top: CGFloat {
        return frame.origin.y
    }
    public var bottom: CGFloat {
        return top + height
    }
    public var left: CGFloat {
        return frame.origin.x
    }
    public var right: CGFloat {
        return left + width
    }
    
    enum BorderSide {
        case top, bottom, left, right
    }
    
    func addBorder(side: BorderSide, color: UIColor, width: CGFloat) {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = color
        self.addSubview(border)
        
        let topConstraint = topAnchor.constraint(equalTo: border.topAnchor)
        let rightConstraint = trailingAnchor.constraint(equalTo: border.trailingAnchor)
        let bottomConstraint = bottomAnchor.constraint(equalTo: border.bottomAnchor)
        let leftConstraint = leadingAnchor.constraint(equalTo: border.leadingAnchor)
        let heightConstraint = border.heightAnchor.constraint(equalToConstant: width)
        let widthConstraint = border.widthAnchor.constraint(equalToConstant: width)
        
        
        switch side {
            case .top:
                NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, heightConstraint])
            case .right:
                NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, widthConstraint])
            case .bottom:
                NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, heightConstraint])
            case .left:
                NSLayoutConstraint.activate([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
        }
    }
    
    func snapshotOfView() -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let viewSnapshot : UIView = UIImageView(image: image)
        viewSnapshot.layer.masksToBounds = false
        viewSnapshot.layer.cornerRadius = 0.0
        viewSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        viewSnapshot.layer.shadowRadius = 5.0
        viewSnapshot.layer.shadowOpacity = 0.4
        return viewSnapshot
    }

}

// MARK: UITableView
extension UITableView {
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < numberOfSections && indexPath.row < numberOfRows(inSection: indexPath.section)
    }
    
    func scrollToTop(_ animated: Bool = false) {
        let indexPath = IndexPath(row: 0, section: 0)
        if hasRowAtIndexPath(indexPath: indexPath) {
            scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
    
}


extension CGRect {
    
    /// SwifterSwift: Create a `CGRect` instance with center and size
    /// - Parameters:
    ///   - center: center of the new rect
    ///   - size: size of the new rect
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0)
        self.init(origin: origin, size: size)
    }
    
}



// MARK: TimeInterval
extension TimeInterval {

    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        let seconds = time % 60
        var minutes = (time / 60) % 60
        minutes += Int(time / 3600) * 60  // to account for the hours as minutes
        
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
}

// MARK: AVAsset
extension AVAsset {

    // Provide a URL for where you wish to write
    // the audio file if successful
    func writeAudioTrack(to url: URL,
                         success: @escaping () -> (),
                         failure: @escaping (Error) -> ()) {
        do {
            let asset = try audioAsset()
            asset.write(to: url, success: success, failure: failure)
        } catch {
            failure(error)
        }
    }

    private func write(to url: URL,
                       success: @escaping () -> (),
                       failure: @escaping (Error) -> ()) {
        // Create an export session that will output an
        // audio track (M4A file)
        guard let exportSession = AVAssetExportSession(asset: self,
                                                       presetName: AVAssetExportPresetAppleM4A) else {
                                                        // This is just a generic error
                                                        let error = NSError(domain: "domain",
                                                                            code: 0,
                                                                            userInfo: nil)
                                                        failure(error)

                                                        return
        }

        exportSession.outputFileType = .m4a
        exportSession.outputURL = url

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                success()
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                let error = NSError(domain: "domain", code: 0, userInfo: nil)
                failure(error)
            @unknown default:
                let error = NSError(domain: "domain", code: 0, userInfo: nil)
                failure(error)
            }
        }
    }

    private func audioAsset() throws -> AVAsset {
        // Create a new container to hold the audio track
        let composition = AVMutableComposition()
        // Create an array of audio tracks in the given asset
        // Typically, there is only one
        let audioTracks = tracks(withMediaType: .audio)

        // Iterate through the audio tracks while
        // Adding them to a new AVAsset
        for track in audioTracks {
            let compositionTrack = composition.addMutableTrack(withMediaType: .audio,
                                                               preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                // Add the current audio track at the beginning of
                // the asset for the duration of the source AVAsset
                try compositionTrack?.insertTimeRange(track.timeRange,
                                                      of: track,
                                                      at: track.timeRange.start)
            } catch {
                throw error
            }
        }
        return composition
    }
    
}

extension Array {
    func deepCopy() -> Array<Element> {
        return self.map{
            let copiable = $0 as! NSCopying
            return copiable.copy() as! Element
        }
    }
}
    
// MARK: UITextField
extension UITextField {

    enum PaddingSpace {
        case left(CGFloat)
        case right(CGFloat)
        case equalSpacing(CGFloat)
    }
    
    func addPadding(padding: PaddingSpace) {
        
        self.leftViewMode = .always
        self.layer.masksToBounds = true
        
        switch padding {
            
            case .left(let spacing):
                let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
                self.leftView = leftPaddingView
                self.rightViewMode = .always
            
            case .right(let spacing):
                let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
                self.rightView = rightPaddingView
                self.rightViewMode = .always
            
            case .equalSpacing(let spacing):
                let equalPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
                // left
                self.leftView = equalPaddingView
                self.leftViewMode = .always
                // right
                self.rightView = equalPaddingView
                self.rightViewMode = .always
        }
    }
    
}

// MARK: String
extension NSString {

    func estimateSizeWidth(font: UIFont, padding: CGFloat) -> CGFloat {
        let size = CGSize(width: 200, height: 1000) // temporary size
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = self.boundingRect(with: size,
                                    options: options,
                                    attributes: [.font: font],
                                    context: nil)
        return ceil(rect.width) + padding
    }
    
}

extension String {

    var length: Int {
        return count
    }

    var isNumeric : Bool {
        return Double(self) != nil
    }
    
    var isRTL: Bool {
        if self == "" {
            return false
        }
        let tagschemes = NSArray(objects: NSLinguisticTagScheme.language)
        let tagger = NSLinguisticTagger(tagSchemes: tagschemes as! [NSLinguisticTagScheme], options: 0)
        tagger.string = self
        
        let language = tagger.tag(at: 0, scheme: NSLinguisticTagScheme.language, tokenRange: nil, sentenceRange: nil)
        return String(describing: language).range(of: "he") != nil ||
            String(describing: language).range(of: "ar") != nil ||
            String(describing: language).range(of: "fa") != nil
    }

    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }

    func convertToTimeInterval() -> TimeInterval {
        guard self != "" else {
            return 0
        }
        
        var interval:Double = 0
        
        let parts = self.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
        
        return interval
    }
    
    func extractYoutubeId() -> String? {
        let pattern = #"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)"#
        if let matchRange = self.range(of: pattern, options: .regularExpression) {
            return String(self[matchRange])
        } else {
            return .none
        }
    }


}

// MARK: NSArray
extension NSArray {

    func isSubset(of arr: NSArray) -> Bool{
        for i in 0 ..< self.count {
            if !arr.contains(self.object(at: i)) {
                return false
            }
        }
        return true
    }
    
    func hasIntersect(with arr: NSArray) -> Bool {
        for i in 0 ..< self.count {
            if arr.contains(self.object(at: i)) {
                return true
            }
        }
        return false
    }
    func asStringArray() -> [String] {
        return self.compactMap({ $0 as? String })
    }

}

// MARK: NSMutableArray
extension NSMutableArray {

    func sortAscending() -> NSMutableArray {
        return NSMutableArray(array: (self as AnyObject as! [String]).sorted {
            $0.localizedCompare($1) == ComparisonResult.orderedAscending
        })
    }
}
extension Encodable {
    var toDict: Dictionary<String,Any>? {
        guard let data =  try? JSONEncoder().encode(self) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
}
extension UIImage {
    
    func cropToSquare(sideLength: Double) -> UIImage {
        
        let cgimage = self.cgImage!
        let contextImage = UIImage(cgImage: cgimage)
        let contextSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth = CGFloat(sideLength)
        var cgheight = CGFloat(sideLength)

        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        return UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
    }
}

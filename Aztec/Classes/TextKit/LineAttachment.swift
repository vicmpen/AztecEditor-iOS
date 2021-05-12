import Foundation
import UIKit

/// Custom horizontal line drawing attachment.
///
open class LineAttachment: NSTextAttachment {
    
    fileprivate var glyphImage: UIImage? = UIImage(named: "SeparatorDots")
    
    fileprivate var screenWidth: CGFloat {
        get {
            UIScreen.main.bounds.width
        }
    }
    
    /// The color to use when drawing progress indicators
    ///
    open var color = UIColor.gray
    
    // MARK: - NSTextAttachmentContainer
    override open func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        
        if let cachedImage = glyphImage, imageBounds.size.equalTo(cachedImage.size) {
            return cachedImage
        }
        
        //glyphImage = glyph(forBounds: imageBounds)
        let remainingWidth = screenWidth - 66 - 48 // 66 -> image's width, 48 -> proposedLineFragment width
        return glyphImage?.withInsets(UIEdgeInsets(top: 40, left: remainingWidth/2, bottom: 20, right: remainingWidth/2))
    }
    
    // MARK: - Currently not used
    fileprivate func glyph(forBounds bounds: CGRect) -> UIImage? {
        let size = bounds.size
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        color.setStroke()
        let path = UIBezierPath()
        path.lineWidth = 1.0
        path.move(to: CGPoint(x:0, y:bounds.height / 2))
        path.addLine(to: CGPoint(x: size.width, y: bounds.height / 2))
        path.stroke()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result;
    }
    
    override open func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
        let padding = textContainer?.lineFragmentPadding ?? 0
        let width = lineFrag.width - padding * 2
        let height:CGFloat = 40 + 20 + 6 // top, bottom spacing plus real height of dots
        
        return CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height))
    }
}

extension UIImage {
    func withInsets(_ insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}

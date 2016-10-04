import Foundation
import UIKit


// MARK: - NSAttributedString Lists Helpers
//
extension NSAttributedString
{
    /// Get the range of a TextList containing the specified index.
    ///
    /// - Parameter index: An index intersecting a TextList.
    ///
    /// - Returns: An NSRange optional containing the range of the list or nil if no list was found.
    ///
    func rangeOfTextList(atIndex index: Int) -> NSRange? {
        var effectiveRange = NSRange()
        let targetRange = rangeOfEntireString
        guard let _ = attribute(TextList.attributeName, atIndex: index, longestEffectiveRange: &effectiveRange, inRange: targetRange) as? TextList else {
            return nil
        }

        return effectiveRange
    }

    /// Returns a NSRange instance that covers the entire string (Location = 0, Length = Full)
    ///
    var rangeOfEntireString: NSRange {
        return NSRange(location: 0, length: length)
    }


    /// Return the contents of a TextList following the specified index (inclusive).
    /// Used to retrieve list items that need to be renumbered.
    ///
    /// - Parameter index: An index intersecting a TextList.
    ///
    /// - Returns: An NSAttributedString optional containing the list from the specified range or nil if no list was found.
    ///
    func textListContents(followingIndex index: Int) -> NSAttributedString? {
        guard let listRange = rangeOfTextList(atIndex: index) else {
            return nil
        }

        let diff = index - listRange.location
        let subRange = NSRange(location: index, length: listRange.length - diff)
        return attributedSubstringFromRange(subRange)
    }


    /// Returns the TextList attribute at the specified NSRange, if any.
    ///
    /// - Parameter index: The index at which to inspect.
    ///
    /// - Returns: A TextList optional.
    ///
    func textListAttribute(atIndex index: Int) -> TextList? {
        return attribute(TextList.attributeName, atIndex: index, effectiveRange: nil) as? TextList
    }


    /// Finds the paragraph ranges in the specified string intersecting the specified range.
    ///
    /// - Parameters range: The range within the specified string to find paragraphs.
    ///
    /// - Returns: An array containing an NSRange for each paragraph intersected by the specified range.
    ///
    func paragraphRanges(spanningRange range: NSRange) -> [NSRange] {
        var paragraphRanges = [NSRange]()
        let targetRange = rangeOfEntireString

        let foundationString = string as NSString
        foundationString.enumerateSubstringsInRange(targetRange, options: .ByParagraphs) { (substring, substringRange, enclosingRange, stop) in
            // Stop if necessary.
            if enclosingRange.location >= NSMaxRange(range) {
                stop.memory = true
                return
            }

            // Bail early if the paragraph precedes the start of the selection
            if NSMaxRange(enclosingRange) <= range.location {
                return
            }

            paragraphRanges.append(enclosingRange)
        }

        return paragraphRanges
    }


    /// Returns all of the paragraphs, spanning at the specified index, with the given TextList Kind.
    ///
    /// - Parameters:
    ///     - index: The index at which to inspect.
    ///     - kind: The type of TextList.
    ///
    /// - Return: A NSRange collection containing the paragraphs with the specified TextList Kind.
    ///
    func paragraphRanges(atIndex index: Int, matchingListKind kind: TextList.Kind) -> [NSRange] {
        guard index >= 0 && index < length, let range = rangeOfTextList(atIndex: index),
            let list = textListAttribute(atIndex: index) where list.kind == kind else
        {
            return []
        }

        return paragraphRanges(spanningRange: range)
    }


    /// Given a collection of Ranges, this helper will attempt to infer if the previous + following
    /// paragraphs contain a TextList, of the specified kind.
    /// If so, their ranges will be returned along with the received ranges, in a sorted fashion.
    ///
    /// - Parameters:
    ///     - ranges: Ranges that should be checked
    ///     - kind: Kind of list to look for
    ///
    /// - Returns: A collection of sorted NSRange's
    ///
    func paragraphRanges(preceedingAndSucceding ranges: [NSRange], matchingListKind kind: TextList.Kind) -> [NSRange] {
        guard let firstRange = ranges.first, lastRange = ranges.last else {
            return ranges
        }

        // Check preceding + following paragraphs style for same kind of list & same list level.
        // If found add those paragraph ranges.
        let preceedingIndex = firstRange.location - 1
        let followingIndex = NSMaxRange(lastRange)
        var adjustedRanges = ranges

        for index in [preceedingIndex, followingIndex] {
            for range in paragraphRanges(atIndex: index, matchingListKind: kind) {
                guard adjustedRanges.contains({ NSEqualRanges($0, range)}) == false else {
                    continue
                }

                adjustedRanges.append(range)
            }
        }

        // Make sure the ranges are sorted in ascending order
        return adjustedRanges.sort {
            $0.location < $1.location
        }
    }
}
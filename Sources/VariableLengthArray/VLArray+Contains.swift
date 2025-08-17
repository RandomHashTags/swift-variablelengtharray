
extension VLArray where Element: ~Copyable {
    /// Returns a Boolean value indicating whether the sequence contains an
    /// element that satisfies the given predicate.
    /// 
    /// - Parameter predicate: A closure that takes an element of the sequence
    ///   as its argument and returns a Boolean value that indicates whether
    ///   the passed element represents a match.
    /// - Returns: `true` if the sequence contains an element that satisfies
    ///   `predicate`; otherwise, `false`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @inlinable
    public func contains(where predicate: (borrowing Element) throws -> Bool) rethrows -> Bool {
        for i in indices {
            if try predicate(self[i]) {
                return true
            }
        }
        return false
    }
}
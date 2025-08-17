
// MARK: VLArray
/// Variable-length array, most likely stored on the stack.
/// 
/// - Warning: May fall back to heap allocation if the compiler/runtime decides the allocation is too big for the stack.
public struct VLArray<Element>: ~Copyable, @unchecked Sendable where Element: ~Copyable {
    public typealias Index = Int

    @usableFromInline
    let _storage:UnsafeMutableBufferPointer<Element>
    
    @inlinable
    public init(_storage: UnsafeMutableBufferPointer<Element>) {
        self._storage = _storage
    }
}

extension VLArray where Element: ~Copyable {
    /// The index of the first element in a nonempty buffer.
    ///
    /// The `startIndex` property of an `VLArray` instance
    /// is always zero.
    @inlinable
    public var startIndex: Index {
        _storage.startIndex
    }

    /// The "past the end" position---that is, the position one greater than the
    /// last valid subscript argument.
    ///
    /// The `endIndex` property of an `VLArray` instance is
    /// always identical to `count`.
    @inlinable
    public var endIndex: Index {
        _storage.endIndex
    }

    /// The number of elements in the buffer.
    ///
    /// If the `baseAddress` of this buffer is `nil`, the count is zero. However,
    /// a buffer can have a `count` of zero even with a non-`nil` base address.
    @inlinable
    public var count: Int {
        _storage.count
    }

    /// A Boolean value indicating whether the buffer is empty.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var isEmpty: Bool {
        _storage.isEmpty
    }

    /// The indices that are valid for subscripting the collection, in ascending
    /// order.
    ///
    /// A collection's `indices` property can hold a strong reference to the
    /// collection itself, causing the collection to be nonuniquely referenced.
    /// If you mutate the collection while iterating over its indices, a strong
    /// reference can result in an unexpected copy of the collection. To avoid
    /// the unexpected copy, use the `index(after:)` method starting with
    /// `startIndex` to produce indices instead.
    ///
    ///     var c = MyFancyCollection([10, 20, 30, 40, 50])
    ///     var i = c.startIndex
    ///     while i != c.endIndex {
    ///         c[i] /= 5
    ///         i = c.index(after: i)
    ///     }
    ///     // c == MyFancyCollection([2, 4, 6, 8, 10])
    @inlinable
    public var indices: Range<Index> {
        #if compiler(>=6.2)
        _storage.indices
        #else
        startIndex..<endIndex
        #endif
    }

    /// Returns the position immediately after the given index.
    ///
    /// The successor of an index must be well defined. For an index `i` into a
    /// collection `c`, calling `c.index(after: i)` returns the same index every
    /// time.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    @inlinable
    public func index(after i: Index) -> Index {
        _storage.index(after: i)
    }

    /// Returns the position immediately before the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than
    ///   `startIndex`.
    /// - Returns: The index value immediately before `i`.
    @inlinable
    public func index(before i: Index) -> Index {
        _storage.index(before: i)
    }

    /// Exchanges the values at the specified indices of the buffer.
    ///
    /// Both parameters must be valid indices of the buffer, and not
    /// equal to `endIndex`. Passing the same index as both `i` and `j` has no
    /// effect.
    ///
    /// - Parameters:
    ///   - i: The index of the first value to swap.
    ///   - j: The index of the second value to swap.
    @inlinable
    public mutating func swapAt(_ i: Index, _ j: Index) {
        _storage.swapAt(i, j)
    }
}

// MARK: Subscript
// copyable
extension VLArray {
    /// Accesses the element at the specified position.
    ///
    /// The following example uses the buffer pointer's subscript to access and
    /// modify the elements of a mutable buffer pointing to the contiguous
    /// contents of an array:
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.withUnsafeMutableBufferPointer { buffer in
    ///         for i in stride(from: buffer.startIndex, to: buffer.endIndex - 1, by: 2) {
    ///             let x = buffer[i]
    ///             buffer[i + 1] = buffer[i]
    ///             buffer[i] = x
    ///         }
    ///     }
    ///     print(numbers)
    ///     // Prints "[2, 1, 4, 3, 5]"
    ///
    /// Uninitialized memory cannot be initialized to a nontrivial type
    /// using this subscript. Instead, use an initializing method, such as
    /// `initializeElement(at:to:)`
    ///
    /// - Note: Bounds checks for `i` are performed only in debug mode.
    ///
    /// - Parameter i: The position of the element to access. `i` must be in the
    ///   range `0..<count`.
    @inlinable
    public subscript(i: Index) -> Element {
        get { _storage[i] }
        set { _storage[i] = newValue }
    }
}

// noncopyable
extension VLArray where Element: ~Copyable {
    /// Accesses the element at the specified position.
    ///
    /// The following example uses the buffer pointer's subscript to access and
    /// modify the elements of a mutable buffer pointing to the contiguous
    /// contents of an array:
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.withUnsafeMutableBufferPointer { buffer in
    ///         for i in stride(from: buffer.startIndex, to: buffer.endIndex - 1, by: 2) {
    ///             let x = buffer[i]
    ///             buffer[i + 1] = buffer[i]
    ///             buffer[i] = x
    ///         }
    ///     }
    ///     print(numbers)
    ///     // Prints "[2, 1, 4, 3, 5]"
    ///
    /// Uninitialized memory cannot be initialized to a nontrivial type
    /// using this subscript. Instead, use an initializing method, such as
    /// `initializeElement(at:to:)`
    ///
    /// - Note: Bounds checks for `i` are performed only in debug mode.
    ///
    /// - Parameter i: The position of the element to access. `i` must be in the
    ///   range `0..<count`.
    @inlinable
    public subscript(i: Index) -> Element {
        _read { yield _storage[i] }
        _modify { yield &_storage[i] }
    }
}

// MARK: Create
// copyable
extension VLArray {
    @discardableResult
    @inlinable
    public static func create<T>(
        amount: Int,
        default: Element,
        _ closure: (consuming Self) throws -> T
    ) rethrows -> T {
        return try withUnsafeTemporaryAllocation(of: Element.self, capacity: amount, { p in
            p.initialize(repeating: `default`)
            defer {
                p.deinitialize()
            }
            let array = Self(_storage: p)
            return try closure(array)
        })
    }

    @discardableResult
    @inlinable
    public static func create<T>(
        amount: Int,
        initialize: (Index) -> Element,
        _ closure: (consuming Self) throws -> T
    ) rethrows -> T {
        return try withUnsafeTemporaryAllocation(of: Element.self, capacity: amount, { p in
            for i in 0..<amount {
                p[i] = initialize(i)
            }
            defer {
                p.deinitialize()
            }
            let array = Self(_storage: p)
            return try closure(array)
        })
    }
}

// noncopyable
extension VLArray where Element: ~Copyable {
    @discardableResult
    @inlinable
    public static func create<T>(
        amount: Int,
        initialize: (Index) -> Element,
        _ closure: (consuming Self) throws -> T
    ) rethrows -> T {
        return try withUnsafeTemporaryAllocation(of: Element.self, capacity: amount, { p in
            for i in 0..<amount {
                p[i] = initialize(i)
            }
            defer {
                p.deinitialize()
            }
            let array = Self(_storage: p)
            return try closure(array)
        })
    }
}

// other
extension VLArray where Element == UInt8 {

    @discardableResult
    @inlinable
    public static func create<T>(
        string: StaticString,
        _ closure: (consuming Self) throws -> T
    ) rethrows -> T {
        return try withUnsafeTemporaryAllocation(of: Element.self, capacity: string.utf8CodeUnitCount, { p in
            string.withUTF8Buffer {
                p.initialize(fromContentsOf: $0)
            }
            defer {
                p.deinitialize()
            }
            let array = Self(_storage: p)
            return try closure(array)
        })
    }

    @discardableResult
    @inlinable
    public static func create<T>(
        string: some StringProtocol,
        _ closure: (consuming Self) throws -> T
    ) rethrows -> T {
        let utf8 = string.utf8
        return try withUnsafeTemporaryAllocation(of: Element.self, capacity: utf8.count, { p in
            let endIndexPlusOne = p.initialize(fromContentsOf: utf8)
            defer {
                p.deinitialize()
            }
            let array = Self(_storage: p)
            return try closure(array)
        })
    }

    @discardableResult
    @inlinable
    public static func create<T>(
        collection: some Collection<UInt8>,
        _ closure: (consuming Self) throws -> T
    ) rethrows -> T {
        let count = collection.count
        return try withUnsafeTemporaryAllocation(
            of: Element.self,
            capacity: count
        ) { p in
            let endIndexPlusOne = p.initialize(fromContentsOf: collection)
            defer {
                p.deinitialize()
            }
            let array = Self(_storage: p)
            return try closure(array)
        }
    }
}

// MARK: Join
#if compiler(>=6.2)
extension VLArray {
    @inlinable
    public func join<let count: Int>(
        _ arrays: consuming InlineArray<count, VLArray>,
        _ closure: (inout Joined) throws -> Void
    ) rethrows {
        try withUnsafeTemporaryAllocation(
            of: UnsafeMutableBufferPointer<Element>.self,
            capacity: 1 + count
        ) { p in
            p.initializeElement(at: 0, to: self._storage)
            for i in arrays.indices {
                p.initializeElement(at: 1 + i, to: arrays[i]._storage)
            }
            defer {
                p.deinitialize()
            }
            var joined = Joined.init(_storage: p)
            try closure(&joined)
        }
    }
}
#endif
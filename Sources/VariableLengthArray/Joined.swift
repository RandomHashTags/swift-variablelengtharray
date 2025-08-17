
#if compiler(>=6.2)

extension VLArray {
    public struct Joined: ~Copyable, @unchecked Sendable {
        public typealias Index = Int

        @usableFromInline
        let _storage:UnsafeMutableBufferPointer<UnsafeMutableBufferPointer<Element>>

        public init(repeating value: Element) {
            fatalError("not implemented")
        }

        @inlinable
        public static func create<E: Error, let count: Int>(
            _ elements: borrowing InlineArray<count, VLArray<Element>>,
            closure: (inout Self) throws(E) -> Void
        ) rethrows {
            try withUnsafeTemporaryAllocation(of: UnsafeMutableBufferPointer<Element>.self, capacity: elements.count, { pointer in
                for i in elements.indices {
                    pointer.initializeElement(at: i, to: elements[i]._storage)
                }
                var joined = Self.init(_storage: pointer)
                try closure(&joined)
            })
        }

        @inlinable
        public init(_storage: UnsafeMutableBufferPointer<UnsafeMutableBufferPointer<Element>>) {
            self._storage = _storage
        }
        
        @inlinable
        public var startIndex: Index {
            0
        }
        @inlinable public var endIndex: Index {
            count
        }

        @inlinable public var count: Int {
            _storage.count
        }

        @inlinable
        public var capacity: Int {
            var c = 0
            for i in _storage.indices {
                c += _storage[i].count
            }
            return c
        }

        @inlinable
        public var isEmpty:Bool {
            count == 0
        }
        @inlinable
        public var indices:Range<Index> {
            .init(uncheckedBounds: (0, endIndex))
        }

        @inlinable 
        public func index(after i: Index) -> Index {
            i &+ 1
        }

        @inlinable 
        public func index(before i: Index) -> Index {
            i &- 1
        }

        @inlinable
        public subscript(index: Index) -> UnsafeMutableBufferPointer<Element> {
            get {
                _storage[index]
            }
            set {
                _storage[index] = newValue
            }
        }

        @inlinable 
        public func elementAt(index: Index) -> Element {
            var previousElements = 0
            for indice in _storage.indices {
                let e = _storage[indice]
                let currentElements = e.count
                if index < previousElements + currentElements {
                    return e[index - previousElements]
                }
                previousElements += currentElements
            }
            fatalError("out-of-bounds")
        }

        @inlinable
        public mutating func setElementAt(index: Index, element: Element) {
            var previousElements = 0
            for indice in _storage.indices {
                let e = _storage[indice]
                let currentElements = e.count
                if index < previousElements + currentElements {
                    _storage[indice][index - previousElements] = element
                    break
                }
                previousElements += currentElements
            }
        }

        @inlinable
        public func forEachElement<E: Error>(
            _ yielding: (Element) throws(E) -> Void
        ) rethrows {
            for i in _storage.indices {
                let buffer = _storage[i]
                for j in buffer.indices {
                    try yielding(buffer[j])
                }
            }
        }

        //@inlinable
        //public mutating func swapAt(_ i: Index, _ j: Index) {
        //}
    }
}

#endif
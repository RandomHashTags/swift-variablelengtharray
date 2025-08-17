
import Testing
@testable import VariableLengthArray

@Suite
struct VariableLengthArrayTests {
    @Test
    func vlArrayCopyable() {
        VLArray<UInt8>.create(amount: 5, default: 0, { array in
            #expect(array.count == 5)
            for i in array.indices {
                #expect(array[i] == 0)
            }
        })
        VLArray<UInt8>.create(amount: 3, default: 1, { array in
            #expect(array.count == 3)
            for i in array.indices {
                #expect(array[i] == 1)
            }
        })
        var amount = 25
        VLArray<UInt8>.create(amount: amount, default: 65, { array in
            #expect(array.count == amount)
            for i in array.indices {
                #expect(array[i] == 65)
            }
        })
        amount /= 2
        VLArray<UInt8>.create(amount: amount, default: 128, { array in
            #expect(array.count == amount)
            for i in array.indices {
                #expect(array[i] == 128)
            }
        })

        VLArray<UInt8>.create(string: "loopy__________doopy", { array in
            #expect(array.count == 20)
            #expect(array[0] == Character("l").asciiValue)
            #expect(array[1] == Character("o").asciiValue)
            #expect(array[2] == Character("o").asciiValue)
            #expect(array[3] == Character("p").asciiValue)
            #expect(array[4] == Character("y").asciiValue)
            #expect(array[5] == Character("_").asciiValue)
            #expect(array[19] == Character("y").asciiValue)
        })
    }

    @Test
    func clArrayNonCopyable() {
        let amount = 1
        VLArray<Noncopyable>.create(amount: amount, initialize: ({ .init(bro: $0) }), { array in
            #expect(array.count == amount)
            for i in array.indices {
                #expect(i == array[i].bro)
            }
        })
    }

    @Test
    func joinedVLArrayVL() {
        VLArray<UInt8>.create(amount: 5, default: 0) { first in
            VLArray<UInt8>.create(amount: 6, default: 1) { second in
                first.join([second]) { joined in
                    #expect(joined.capacity == 11)
                    for i in first.indices {
                        #expect(joined.elementAt(index: i) == 0)
                    }
                    let offset = first.count
                    #expect(offset == 5)
                    for i in offset..<joined.capacity {
                        #expect(joined.elementAt(index: i) == 1)
                    }
                }
            }
        }
    }
}

struct Noncopyable: ~Copyable {
    let bro:Int
}
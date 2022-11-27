import SwiftUI

/**
  This is a custom layout that is a variation on VStackLayout.
  Child views are referred to as "subviews".
  Subviews that have even indexes (0, 2, ...) are left-aligned.
  Subviews that have odd indexes (1, 3, ...) are also left-aligned,
  but are indented in by the width of the widest even subview.

  The Layout protocol requires the methods `placeSubviews` and `sizeThatFits`.
  The `sizeThatFits` method determines the width and height
  required to holds all the subviews in their computed locations.
  The `placeSubviews` method places each subview
  at a computed x, y location with a proposed size.
 */
struct AlternateStackLayout: Layout {
    // This is used to share data between methods in the `Layout` protocol.
    struct Cache {
        let maxEvenWidth: CGFloat
        let maxOddWidth: CGFloat
        let sizes: [CGSize]
    }

    func makeCache(subviews: Subviews) -> Cache {
        // Get the size of each subview.
        // The type is `[CGSize]`.
        // `CGSize` has `width` and `height` properties.
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        // Get the maximum width of the even subviews
        // and the maximum width of the odd subviews.
        var maxEvenWidth = 0.0
        var maxOddWidth = 0.0
        var isEven = true
        for size in sizes {
            let width = size.width
            if isEven {
                if width > maxEvenWidth { maxEvenWidth = width }
            } else {
                if width > maxOddWidth { maxOddWidth = width }
            }
            isEven.toggle()
        }

        return Cache(
            maxEvenWidth: maxEvenWidth,
            maxOddWidth: maxOddWidth,
            sizes: sizes
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize, // seems to be the entire screen size
        subviews: Subviews,
        cache: inout Cache
    ) {
        // If there are no subviews then there is no work to be done.
        // guard !subviews.isEmpty else { return }

        // Determine the `x` values for even and odd subviews.
        let evenX = bounds.minX
        let oddX = bounds.minX + cache.maxEvenWidth

        // Determine the `y` value of the first subview.
        var y = bounds.minY

        var x = evenX
        for (subview, size) in zip(subviews, cache.sizes) {
            subview.place(
                at: CGPoint(x: x, y: y),
                anchor: .topLeading,
                proposal: ProposedViewSize(size)
            )

            // The next subview will use the other x value.
            x = x == evenX ? oddX : evenX

            // The y value for the next subview will greater than
            // the y value of this subview by the height of this subview.
            y += size.height
        }
    }

    func sizeThatFits(
        proposal: ProposedViewSize, // seems to be the entire screen size
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        subviews.isEmpty ? .zero : CGSize(
            width: cache.maxEvenWidth + cache.maxOddWidth,
            height: cache.sizes.map { $0.height }.reduce(0, +)
        )
    }
}

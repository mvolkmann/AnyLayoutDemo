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
final class AlternateStackLayout: Layout {
    private var maxEvenWidth = 0.0
    private var sizes: [CGSize] = []

    init() {}

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize, // TODO: How can this be used?
        subviews: Subviews,
        cache: inout () // TODO: How can this be used?
    ) {
        // If there are no subviews then there is no work to be done.
        guard !subviews.isEmpty else { return }

        // Determine the `x` values for even and odd subviews.
        let evenX = bounds.minX
        let oddX = bounds.minX + maxEvenWidth

        // Determine the `y` value of the first subview.
        var y = bounds.minY

        var x = evenX
        for (subview, size) in zip(subviews, sizes) {
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
        proposal: ProposedViewSize, // TODO: How can this be used?
        subviews: Subviews,
        cache: inout () // TODO: How can this be used?
    ) -> CGSize {
        // If there are no subviews then the size is zero.
        guard !subviews.isEmpty else { return .zero }

        // Get the size of each subview.
        // The type is `[CGSize]`.
        // `CGSize` has `width` and `height` properties.
        sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        // Get the maximum width of the even subviews
        // and the maximum width of the odd subviews.
        maxEvenWidth = 0.0
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

        // Return the required container size.
        return CGSize(
            width: maxEvenWidth + maxOddWidth,
            height: sizes.map { $0.height }.reduce(0, +)
        )
    }
}

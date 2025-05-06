import SwiftUI

struct SurveyCategoriesView: View {
    let categories = [
        ("Science", 0),
        ("Social", 1),
        ("Tech", 2),
        ("Gaming", 3),
        ("History", 4),
        ("Analytics", 5)
    ]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(categories, id: \.0) { (name, colorIndex) in
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.categoryColors[colorIndex])
                    .cornerRadius(16)
            }
        }
        .padding(.top, 8)
        .padding(.horizontal)
    }
}

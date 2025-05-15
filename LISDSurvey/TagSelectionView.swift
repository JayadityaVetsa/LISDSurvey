//
//  TagSelectionView.swift
//  LISDSurvey
//
//  Created by Sai venkat Veerapaneni on 5/15/25.
//

import SwiftUI

struct TagSelectionView: View {
    @ObservedObject var viewModel: TagViewModel

    var body: some View {
        List(viewModel.allTags) { tag in
            HStack {
                Text(tag.name)
                Spacer()
                if viewModel.isSelected(tag) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.toggleTag(tag)
            }
        }
        .navigationTitle("Select Tags")
    }
}

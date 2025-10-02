//
//  PrimaryButton.swift
//  Sewing Planner
//
//  Created by Art on 9/23/24.
//

import SwiftUI

struct PrimaryButton: View {
    var body: some View {
        Button("New Step") {}.buttonStyle(PrimaryButtonStyle())
            .frame(minWidth: 300, minHeight: 300)
    }
}

struct SectionViewButton<Content: View>: View {
    @State var isHovering = false
    let action: @MainActor () -> Void
    @ViewBuilder let label: () -> Content

    var body: some View {
        Button(action: action, label: label)
            .buttonStyle(SectionTertiaryButtonStyle())
            .scaleEffect(isHovering ? 1.15 : 1, anchor: .center)
            .onHover { hover in
                isHovering = hover
            }
            .animation(.easeIn(duration: 0.13), value: isHovering)
    }
}

// gist for this idea
// https://gist.github.com/arthmis/d3bde814fd0aced3adcef17df3da840a
struct PressedAction: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}

extension View {
    func onPress(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressedAction {
            onPress()
        } onRelease: {
            onRelease()
        })
    }
}

struct ImageButton: View {
    @State var isHovering = false
    @Binding var image: ProjectImage
    @Binding var selectedImages: Set<String?>
    @Binding var overlaySelectedImage: Bool
    @Binding var selectedImage: String?
    @State var isPressed = false

    var isSelectedForDeletion: Bool {
        selectedImages.contains(image.path)
    }

    var body: some View {
        Image(uiImage: image.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 100, maxWidth: .infinity,  minHeight: 200, alignment: .center)
            .clipped()
            .animation(.easeIn(duration: 0.05), value: isPressed)
//                        .padding(5)
            .background(Color(hex: 0xDDDDDD, opacity: isPressed ? 1 : 0))
            // parts of the image that were clipped still respond to the mouse events so this constrains it to the correct area
            .contentShape(Rectangle())
            .onTapGesture {
                selectedImage = image.path
                overlaySelectedImage = true
            }
            .onPress {
                isPressed = true
            } onRelease: {
                isPressed = false
            }
    }
}

struct SelectedImageButton: View {
    @State var isHovering = false
    @Binding var image: ProjectImage
    @Binding var selectedImages: Set<String?>
    @Binding var overlaySelectedImage: Bool
    @Binding var selectedImage: String?
    @State var isPressed = false

    var isSelectedForDeletion: Bool {
        selectedImages.contains(image.path)
    }

    var body: some View {
        Image(uiImage: image.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 100, maxWidth: .infinity,  minHeight: 200, alignment: .center)
            .clipped()
            .animation(.easeIn(duration: 0.05), value: isPressed)
//                        .padding(5)
            .background(Color(hex: 0xDDDDDD, opacity: isPressed ? 1 : 0))
            .background(isSelectedForDeletion ? Color.blue : Color.white)
            // parts of the image that were clipped still respond to the mouse events so this constrains it to the correct area
            .contentShape(Rectangle())
            .onTapGesture {
                if !isSelectedForDeletion {
                    selectedImages.insert(image.path)
                } else {
                    selectedImages.remove(image.path)
                }
            }
            .onPress {
                isPressed = true
            } onRelease: {
                isPressed = false
            }
    }
}

#Preview {
    SectionViewButton {} label: {
        Image(systemName: "ellipsis")
    }
}

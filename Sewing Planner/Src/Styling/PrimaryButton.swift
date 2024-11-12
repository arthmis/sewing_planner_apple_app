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
    @Binding var selectedImageForDeletion: URL?
    @Binding var overlaySelectedImage: Bool
    @Binding var selectedImage: URL?
    @State var isPressed = false

    var body: some View {
        if let img = image.image {
            if image.path == selectedImageForDeletion {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 250)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .padding(10)
                    .shadow(color: Color(hex: 0x000000, opacity: isHovering ? 0.5 : 0.25), radius: isHovering ? 5 : 3, x: 0, y: 4)
                    .scaleEffect(isHovering ? 1.03 : 1, anchor: .center)
                    .animation(.easeIn(duration: 0.05), value: isPressed)
                    .padding(5)
                    .background(Color(hex: 0xDDDDDD, opacity: isPressed ? 1 : 0))
                    .background(Color(hex: 0x780606))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .animation(.easeIn(duration: 0.05), value: isHovering)
//                    .onHover { hover in
//                        isHovering = hover
//                    }
//                    .onTapGesture {
//                        selectedImage = image.path
//                        overlaySelectedImage = true
//                    }
//                    .onLongPressGesture {
//                        selectedImageForDeletion = image.path
//                    }
//                    .onPress {
//                        isPressed = true
//                    } onRelease: {
//                        isPressed = false
//                    }
            } else {
                Button {
                    print(image.path)
                    selectedImage = image.path
                    overlaySelectedImage = true
                } label: {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 250)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                        .padding(10)
                        .shadow(color: Color(hex: 0x000000, opacity: isHovering ? 0.5 : 0.25), radius: isHovering ? 5 : 3, x: 0, y: 4)
                        .scaleEffect(isHovering ? 1.03 : 1, anchor: .center)
                        .animation(.easeIn(duration: 0.05), value: isPressed)
                        .padding(5)
                        .background(Color(hex: 0xDDDDDD, opacity: isPressed ? 1 : 0))
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                        .animation(.easeIn(duration: 0.05), value: isHovering)
                        // parts of the image that were clipped still respond to the mouse events so this constrains it to the correct area
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .onHover { hover in
                    isHovering = hover
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 2)
                        .onEnded { _ in
                            selectedImageForDeletion = image.path
                            isPressed = false
                        }
                )
                .onPress {
                    isPressed = true
                } onRelease: {
                    isPressed = false
                }
            }
        } else {
            // Place holder image if displaying an image fails or loading failed
            // TODO: think about if to use this or just display an error
            Button {
                print(image.path)
                selectedImage = image.path
                overlaySelectedImage = true
            } label: {
                Image("black_dress_sketch")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 250)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .padding(10)
                    .shadow(color: Color(hex: 0x000000, opacity: isHovering ? 0.5 : 0.25), radius: isHovering ? 5 : 3, x: 0, y: 4)
                    .scaleEffect(isHovering ? 1.03 : 1, anchor: .center)
                    .animation(.easeIn(duration: 0.05), value: isPressed)
                    .padding(5)
                    .background(Color(hex: 0xDDDDDD, opacity: isPressed ? 1 : 0))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .animation(.easeIn(duration: 0.05), value: isHovering)
                    // parts of the image that were clipped still respond to the mouse events so this constrains it to the correct area
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { hover in
                isHovering = hover
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 2)
                    .onEnded { _ in
                        selectedImageForDeletion = image.path
                        isPressed = false
                    }
            )
            .onPress {
                isPressed = true
            } onRelease: {
                isPressed = false
            }
        }
    }
}

#Preview {
    SectionViewButton {} label: {
        Image(systemName: "ellipsis")
    }
}

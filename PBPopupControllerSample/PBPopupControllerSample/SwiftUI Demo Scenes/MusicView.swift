//
//  MusicView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 8/6/20.
//

import SwiftUI
import PBPopupController

struct RandomTitleSong : Identifiable {
	var id: Int
	var imageName: String {
        String(format: "Cover%02d", id)
        
    }
	var title: String = LoremIpsum.title
	var subtitle: String = LoremIpsum.words(withNumber: 5)
}

fileprivate var songs: [RandomTitleSong] = {
	var songs: [RandomTitleSong] = []
	for idx in 1..<24 {
		songs.append(RandomTitleSong(id: idx))
	}
	return songs
}()

@available(iOS 14.0, *)
struct RandomTitlesListView : View {
	@Environment(\.presentationMode) var presentationMode
	private let title: String
	
	@Binding var isPopupPresented: Bool
	private let onSongSelect: (RandomTitleSong) -> Void
	private let onDismiss: () -> Void
    
	init(_ title: String, _ isPopupPresented: Binding<Bool>, onDismiss: @escaping () -> Void, onSongSelect: @escaping (RandomTitleSong) -> Void) {
		self.title = title
		self._isPopupPresented = isPopupPresented
		self.onDismiss = onDismiss
		self.onSongSelect = onSongSelect
	}
	
	var body: some View {
		NavigationView {
			List(songs) { song in
				Button(action: {
					onSongSelect(song)
				}) {
					HStack(spacing: 20) {
						Image(song.imageName)
							.resizable()
							.frame(width: 48, height: 48)
							.cornerRadius(8)
						
						VStack(alignment: .leading) {
							Text(song.title)
								.font(.headline)
								.lineLimit(1)
							Text(song.subtitle)
								.font(.subheadline)
								.lineLimit(1)
						}
						.multilineTextAlignment(.leading)
					}
				}
			}
			.listStyle(PlainListStyle())
			.navigationBarTitle(title)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Image(systemName: isPopupPresented ? "rectangle.bottomthird.inset.fill" : "rectangle")
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Gallery") {
						onDismiss()
					}
				}
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}

@available(iOS 14.0, *)
struct MusicView: View {
	@State var isPopupBarPresented: Bool = false
	@State var isPopupOpen: Bool = false
	
	@State var currentSong: RandomTitleSong? = nil {
		didSet {
			DispatchQueue.main.async {
				isPopupBarPresented = true
			}
		}
	}
	
	private let onDismiss: () -> Void
	    
	init(onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
    }
	
	var body: some View {
		TabView {
			RandomTitlesListView("Music", $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Music")
				Image(systemName: "play.circle.fill")
			}
			RandomTitlesListView("Artists", $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Artists")
				Image(systemName: "music.mic")
			}
			RandomTitlesListView("Composers", $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Composers")
				Image(systemName: "music.quarternote.3")
			}
			RandomTitlesListView("Recents", $isPopupBarPresented, onDismiss:onDismiss, onSongSelect: { song in
				currentSong = song
			})
			.tabItem {
				Text("Recents")
				Image(systemName: "clock.fill")
			}
		}
		.accentColor(.pink)
        
        
        .popup(isPresented: $isPopupBarPresented,
               isOpen: $isPopupOpen,
               willOpen: { print("willOpen") },
               onOpen: { print("onOpen") },
               shouldClose: { return true }
        )
        {
            if let currentSong = currentSong {
                PlayerView(song: currentSong)
            }
        }
        .isFloating(true)
		//.popupBarStyle(.compact)
		.popupBarProgressViewStyle(.top)
        //.popupPresentationStyle(.fullScreen)
        //.popupCloseButtonStyle(.none)
        //.popupContentViewCustomizer { popupBContentView in
        //    popupBContentView.popupEffectView.effect = nil
        //}
	}
}

@available(iOS 14.0, *)
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MusicView(onDismiss: {})
	}
}

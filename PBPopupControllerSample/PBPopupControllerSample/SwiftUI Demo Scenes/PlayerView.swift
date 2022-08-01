//
//  PlayerView.swift
//  LNPopupUIExample
//
//  Created by Leo Natan on 8/6/20.
//

import SwiftUI
import PBPopupController
import Combine

@available(iOS 14.0, *)
struct BlurView: UIViewRepresentable {
	var style: UIBlurEffect.Style = .systemMaterial
	func makeUIView(context: Context) -> UIVisualEffectView {
		return UIVisualEffectView(effect: UIBlurEffect(style: style))
	}
	func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
		uiView.effect = UIBlurEffect(style: style)
	}
}

@available(iOS 14.0, *)
struct PlayerView: View {
	let song: RandomTitleSong
	@State var playbackProgress: Float = Float.random(in: 0..<1)
	@State var volume: Float = Float.random(in: 0..<1)
	@State var isPlaying: Bool = true
    @State var shadowOpacity: Float = 0.8
        
    init(song: RandomTitleSong) {
		self.song = song
	}
    
	var body: some View {
        GeometryReader { geometry in
            return VStack {
                /*
                RoundShadowImage(image: UIImage(named: song.imageName)!, cornerRadius: 10, shadowColor: .black, shadowOffset: CGSize(width: 0.0, height: 20.0), shadowOpacity: shadowOpacity, shadowRadius: 20.0)
                        .aspectRatio(contentMode: .fit)
                        .padding([.leading, .trailing], 10)
                        .padding([.top], geometry.size.height * 60 / 896.0)
                */
                
                RoundShadowImage(image: UIImage(named: song.imageName)!)
                    .cornerRadius(10.0)
                    .shadowOpacity(shadowOpacity)
                    .shadowOffset(CGSize(width: 0.0, height: 20.0))
                    .shadowRadius(20.0)
                    .aspectRatio(contentMode: .fit)
                    .padding([.leading, .trailing], 10)
                    .padding([.top], geometry.size.height * 60 / 896.0)
                 
				VStack(spacing: geometry.size.height * 30.0 / 896.0) {
					HStack {
						VStack(alignment: .leading) {
							Text(song.title)
								.font(.system(size: 20, weight: .bold))
							Text(song.subtitle)
								.font(.system(size: 20, weight: .regular))
						}
						.lineLimit(1)
						.frame(minWidth: 0,
							   maxWidth: .infinity,
							   alignment: .topLeading)
						Button(action: {}, label: {
							Image(systemName: "ellipsis.circle")
								.font(.title)
						})
					}
                    ProgressView(value: playbackProgress)
                        .padding([.bottom], geometry.size.height * 30.0 / 896.0)
					HStack {
						Button(action: {}, label: {
							Image(systemName: "backward.fill")
						})
							.frame(minWidth: 0, maxWidth: .infinity)
						Button(action: {
							isPlaying.toggle()
                            shadowOpacity = isPlaying ? 0.8 : 0.0
						}, label: {
							Image(systemName: isPlaying ? "pause.fill" : "play.fill")
						})
							.font(.system(size: 50, weight: .bold))
							.frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
						Button(action: {}, label: {
							Image(systemName: "forward.fill")
						})
							.frame(minWidth: 0, maxWidth: .infinity)
					}
					.font(.system(size: 30, weight: .regular))
					.padding([.bottom], geometry.size.height * 20.0 / 896.0)
					HStack {
						Image(systemName: "speaker.fill")
						Slider(value: $volume)
						Image(systemName: "speaker.wave.2.fill")
					}
					.font(.footnote)
					.foregroundColor(.gray)
					HStack {
						Button(action: {}, label: {
							Image(systemName: "shuffle")
						})
							.frame(minWidth: 0, maxWidth: .infinity)
						Button(action: {}, label: {
							Image(systemName: "airplayaudio")
						})
							.frame(minWidth: 0, maxWidth: .infinity)
						Button(action: {}, label: {
							Image(systemName: "repeat")
						})
							.frame(minWidth: 0, maxWidth: .infinity)
					}
					.font(.body)
				}
				.padding(geometry.size.height * 40.0 / 896.0)
			}
			.frame(minWidth: 0,
				   maxWidth: .infinity,
				   minHeight: 0,
				   maxHeight: .infinity,
				   alignment: .top)
			.background({
				ZStack {
					Image(song.imageName)
						.resizable()
					BlurView()
				}
				.edgesIgnoringSafeArea(.all)
			}())
		}
		.popupTitle(song.title)
        
        //.popupImage(Image(song.imageName).resizable())
        
        .popupRoundShadowImage(UIImage(named: song.imageName)!, cornerRadius: 3.0, shadowOffset: CGSize(width: 3.0, height: 3.0), shadowOpacity: 0.5, shadowRadius: 3.0)
        
		.popupProgress(playbackProgress)
        .popupBarItems(trailing: {
            HStack(spacing: 20) {
                Button(action: {
                    print("Play")
                }) {
                    Image(systemName: "play.fill")
                }
                
                Button(action: {
                    print("Next")
                }) {
                    Image(systemName: "forward.fill")
                }
            }
            .font(.system(size: 20))
        })
	}
}

@available(iOS 14.0, *)
struct PlayerView_Previews: PreviewProvider {
	static var previews: some View {
		PlayerView(song: RandomTitleSong(id: 12))
	}
}


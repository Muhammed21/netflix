import AVFoundation
import SwiftUI

/// Lecteur vidéo sans habillage, réutilisable.
///
/// `VideoPlayer` d'AVKit est écarté : il impose des contrôles de lecture et une
/// gestion de session audio dont une animation de marque n'a pas besoin. On
/// descend donc d'un cran, sur `AVPlayerLayer`.
public struct VideoPlayerView: UIViewRepresentable {
  public enum Mode: Sendable {
    /// Joue une fois puis appelle `onFinished`.
    case once
    /// Reboucle indéfiniment ; `onFinished` n'est jamais appelé.
    case looping
  }

  private let url: URL
  private let mode: Mode
  private let onFinished: (() -> Void)?

  public init(url: URL, mode: Mode = .once, onFinished: (() -> Void)? = nil) {
    self.url = url
    self.mode = mode
    self.onFinished = onFinished
  }

  public func makeUIView(context: Context) -> PlayerContainerView {
    let view = PlayerContainerView()
    view.configure(url: url, mode: mode, onFinished: onFinished)
    return view
  }

  /// La vue est déjà configurée : reconfigurer ici recréerait l'`AVPlayer` à
  /// chaque rendu SwiftUI, ce qui saccade et fuit. On ne met à jour que le
  /// rappel, qui peut capturer un état plus récent.
  public func updateUIView(_ uiView: PlayerContainerView, context: Context) {
    uiView.updateOnFinished(onFinished)
  }

  public static func dismantleUIView(_ uiView: PlayerContainerView, coordinator: Coordinator) {
    uiView.stop()
  }
}

@MainActor
public final class PlayerContainerView: UIView {
  public override class var layerClass: AnyClass { AVPlayerLayer.self }

  private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
  private var looper: AVPlayerLooper?
  private var endObserver: NSObjectProtocol?
  private var onFinished: (() -> Void)?

  func configure(url: URL, mode: VideoPlayerView.Mode, onFinished: (() -> Void)?) {
    self.onFinished = onFinished
    backgroundColor = .black
    playerLayer.videoGravity = .resizeAspect

    switch mode {
    case .once:
      let item = AVPlayerItem(url: url)
      let player = AVPlayer(playerItem: item)
      prepare(player)
      observeEnd(of: item)
      playerLayer.player = player
      player.play()

    case .looping:
      // AVPlayerLooper enchaîne sans coupure ; revenir à zéro sur notification
      // produit un à-coup visible à chaque boucle.
      let item = AVPlayerItem(url: url)
      let queue = AVQueuePlayer()
      prepare(queue)
      looper = AVPlayerLooper(player: queue, templateItem: item)
      playerLayer.player = queue
      queue.play()
    }
  }

  /// La vidéo n'a pas de piste audio : on coupe le son et on ne touche pas à
  /// l'`AVAudioSession`, pour ne jamais interrompre la musique de l'utilisateur.
  private func prepare(_ player: AVPlayer) {
    player.isMuted = true
    player.preventsDisplaySleepDuringVideoPlayback = false
    player.actionAtItemEnd = .pause
  }

  private func observeEnd(of item: AVPlayerItem) {
    endObserver = NotificationCenter.default.addObserver(
      forName: AVPlayerItem.didPlayToEndTimeNotification,
      object: item,
      queue: .main
    ) { [weak self] _ in
      self?.onFinished?()
    }
  }

  func updateOnFinished(_ onFinished: (() -> Void)?) {
    self.onFinished = onFinished
  }

  public func pause() { playerLayer.player?.pause() }
  public func resume() { playerLayer.player?.play() }

  func stop() {
    playerLayer.player?.pause()
    playerLayer.player = nil
    looper = nil
    if let endObserver {
      NotificationCenter.default.removeObserver(endObserver)
      self.endObserver = nil
    }
  }
}

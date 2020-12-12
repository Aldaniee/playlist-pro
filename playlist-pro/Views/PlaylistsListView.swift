import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistsListView: View {
    
    @ObservedObject var spotify: Spotify = .shared
    
    @State private var playlists: [Playlist<PlaylistsItemsReference>] = []
    
    @State private var cancellables: Set<AnyCancellable> = []
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertIsPresented = false
    
    @State private var isLoadingPlaylists = false
    @State private var couldntLoadPlaylists = false
    
    static let animation = Animation.spring()

    let debug: Bool
    
    init() {
        self.debug = false
    }
/*
    /// Used only by the preview provider to provide sample data.
    fileprivate init(samplePlaylists: [Playlist<PlaylistsItemsReference>]) {
        self._playlists = State(initialValue: samplePlaylists)
        self.debug = true
    }
    */
    var body: some View {
        VStack {
            if playlists.isEmpty {
                if isLoadingPlaylists {
                    HStack {
                        ProgressView()
                                    .padding()
                        Text("Loading Playlists")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                }
                else if couldntLoadPlaylists {
                    Text("Couldn't Load Playlists")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                else {
                    Text("No Playlists Found")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            else {
                Text(
                    """
                    Tap on a playlist to play it. Tap and hold \
                    on a Playlist to remove duplicates.
                    """
                )
                .font(.caption)
                .foregroundColor(.secondary)
                List {
                    ForEach(playlists, id: \.uri) { playlist in
                        PlaylistCellView(playlist)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Playlists")
        .navigationBarItems(trailing: refreshButton)
        /*.alert(isPresented: $alertIsPresented) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage)
            )
        }*/
        .onAppear(perform: retrievePlaylists)
        .disabled(!spotify.isAuthorized)
        .modifier(LoginView())
        
    }
    
    
    var refreshButton: some View {
        Button(action: retrievePlaylists) {
            Image(systemName: "arrow.clockwise")
                .font(.title)
                .scaleEffect(0.8)
        }
        .disabled(isLoadingPlaylists)
        .modifier(LoginView())
        .alert(isPresented: $alertIsPresented) {
            Alert(title: Text(alertTitle), message: Text(alertMessage))
        }
        // Called when a redirect is received from Spotify.
        .onOpenURL(perform: handleURL(_:))
    }
    
    /**
     Handle the URL that Spotify redirects to after the user
     Either authorizes or denies authorizaion for the application.
     
     This method is called by the `onOpenURL(perform:)` view modifier
     directly above.
     */
    func handleURL(_ url: URL) {
        print("WORKING")
        // **Always** validate URLs; they offer a potential attack
        // vector into your app.
        guard url.scheme == Spotify.loginCallbackURL.scheme else {
            print("not handling URL: unexpected scheme: '\(url)'")
            return
        }

        // This property is used to display an activity indicator in
        // `LoginView` indicating that the access and refresh tokens
        // are being retrieved.
        spotify.isRetrievingTokens = true
        
        // Complete the authorization process by requesting the
        // access and refresh tokens.
        spotify.api.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            // This value must be the same as the one used to create the
            // authorization URL. Otherwise, an error will be thrown.
            state: spotify.authorizationState
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            // Whether the request succeeded or not, we need to remove
            // the activity indicator.
            self.spotify.isRetrievingTokens = false
            
            /*
             After the access and refresh tokens are retrieved,
             `SpotifyAPI.authorizationManagerDidChange` will emit a
             signal, causing `handleChangesToAuthorizationManager()` to be
             called, which will dismiss the loginView if the app was
             successfully authorized by setting the
             @Published `Spotify.isAuthorized` property to `true`.

             The only thing we need to do here is handle the error and
             show it to the user if one was received.
             */
            if case .failure(let error) = completion {
                print("couldn't retrieve access and refresh tokens:\n\(error)")
                if let authError = error as? SpotifyAuthorizationError,
                        authError.accessWasDenied {
                    self.alertTitle =
                        "You Denied The Authorization Request :("
                }
                else {
                    self.alertTitle =
                        "Couldn't Authorization With Your Account"
                    self.alertMessage = error.localizedDescription
                }
                self.alertIsPresented = true
            }
        })
        .store(in: &cancellables)
        
        // MARK: IMPORTANT: generate a new value for the state parameter
        // MARK: after each authorization request. This ensures an incoming
        // MARK: redirect from Spotify was the result of a request made by
        // MARK: this app, and not an attacker.
        self.spotify.authorizationState = String.randomURLSafe(length: 128)
        
    }

    func retrievePlaylists() {
        
        // If `debug` is `true`, then sample playlists have been provided
        // for testing purposes, so we shouldn't try to retrieve any from
        // the Spotify web API.
        if self.debug { return }
        
        self.isLoadingPlaylists = true
        self.playlists = []
        spotify.api.currentUserPlaylists()
            // Gets all pages of playlists. By default, only 20 are
            // returned per page.
            .extendPages(spotify.api)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoadingPlaylists = false
                    switch completion {
                        case .finished:
                            self.couldntLoadPlaylists = false
                        case .failure(let error):
                            self.couldntLoadPlaylists = true
                            self.alertTitle = "Couldn't Retrieve Playlists"
                            self.alertMessage = error.localizedDescription
                            self.alertIsPresented = true
                    }
                },
                // We will receive a value for each page of playlists.
                // You could use Combine's `collect()` operator to wait until
                // all of the pages have been retrieved.
                receiveValue: { playlistsPage in
                    let playlists = playlistsPage.items
                    self.playlists.append(contentsOf: playlists)
                }
            )
            .store(in: &cancellables)
        print("4")

    }
    
    
}
/*
struct PlaylistsListView_Previews: PreviewProvider {
    
    static let spotify = Spotify()
    
    static let playlists: [Playlist<PlaylistsItemsReference>] = [
        .menITrust, .modernPsychedelia, .menITrust,
        .lucyInTheSkyWithDiamonds, .rockClassics,
        .thisIsMFDoom, .thisIsSonicYouth, .thisIsMildHighClub,
        .thisIsSkinshape
    ]
    
    static var previews: some View {
        NavigationView {
            PlaylistsListView(samplePlaylists: playlists)
                .environmentObject(spotify)
        }
    }
}
*/

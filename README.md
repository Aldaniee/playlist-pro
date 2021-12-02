#  Playlist Pro
===============

[![Language](https://img.shields.io/badge/Swift-5-orange?logo=Swift&logoColor=white)](https://swift.org) 

## About
**PlaylistPro** is a YouTube music downloader and player application with Spotify library conversion capabilities.

<img src="/Images/login-screen.png" width="222" height="480"><img src="/Images/spotify-playlist.png" width="222" height="480">
<img src="/Images/empty-room-playing.png" width="222" height="480"> 

## Idea
This app was intended for Spotify users to use for customizing their playlists. Users can easily import a playlist they already made in Spotify and add music that isn't on Spotify or modify the audio files with cropping and custom transitions. Due to issues with [XCDYouTubeKit](https://github.com/0xced/XCDYouTubeKit), development is largely halted.

## Features
- Download any video's audio from YouTube and listen freely offline.
- Build and manage multiple playlists.
- Login with Spotify and import existing Spotify playlists.
- Firebase authentication system and realtime database allows users to login on any device and download their music library.
- Add fade transitions between songs, crop songs, change song speed

## Implementation
- UIKit driven programatic front-end
- MVC design pattern
- Firebase user authentication and database management
- Alamofire networking with Youtube API

## Installation
1. Clone/Download the repo
2. Open `playlist-pro.xcodeproj` in Xcode
3. Configure code signing
4. Build & run

## Issues
- [XCDYouTubeKit](https://github.com/0xced/XCDYouTubeKit) currently facing an issue with downloading music
- Google Developer API quota is very small. This app is functional to the extent of a "proof of concept".

## Resources
- Downloading and playback based on: [YouTag](https://github.com/youstanzr/YouTag/blob/master/README.md?plain=1)
- Spotify import based on: [Spotify-iOS](https://github.com/AfrazCodes/Spotify-iOS)
- Slide down dismiss animation based on: [SlideOverTutorial](https://github.com/aivars/SlideOverTutorial)
- Song Encoding based on [CodableFirebase](https://github.com/alickbass/CodableFirebase)
- Generation of Waveform Diagram based on [DSWaveformImage](https://github.com/dmrschmidt/DSWaveformImage)

## Spotify Playlist Import Feature
1. User logs in with their Spotify account.
2. User selects the Playlist they wish to import.
3. App searches for every song in the playlist and downloads a YouTube equivalent audio.
4. Playlist is remade locally in the app sourcing all media from YouTube.

## Screenshots

Users can search for any song on YouTube, download that song, and play it locally. The song can be edited in the "Edit Panel". The wave form is generated from the audio and the fornt and end of the song can be cropped, speed can be changed, and transitions can be added to the start or finish.

<img src="/Images/pride-yt-search.png" width="222" height="480"><img src="/Images/pride-playing.png" width="222" height="480"> 
<img src="/Images/waves-waveform.png" width="222" height="480">

Using a Firebase account system, users can make an account and login on any device to retain their progress. A library of their music is tied to their account by storing YouTube links in Firebase. When a user logs into their account those links are accessed to download all of their music locally.

<img src="/Images/home-screen.png" width="222" height="480"><img src="/Images/login-screen.png" width="222" height="480">
![login flow](https://media4.giphy.com/media/xykTra3eghRnd35odr/giphy.gif?cid=790b76118ecfefca952335a7c8d883dc63b88d4d399d3737&rid=giphy.gif&ct=g)

The music player runs on a fully functional queue system. They are auto generated when a song is pressed on and can be added to and removed from. This works alongside a playlist system that allows for playlist management and customization. Both systems are modeled off of Spotify and behave similarly for ease of use.

<img src="/Images/empty-room-queue.png" width="222" height="480"><img src="/Images/honey-queue.png" width="222" height="480"> 
<img src="/Images/spotify-import.png" width="222" height="480">

More examples of the user interface in action.

<img src="/Images/on-hold-playing.png" width="222" height="480"><img src="/Images/on-hold-waveform.png" width="222" height="480">
![playlist-animations](https://media1.giphy.com/media/nVuIPqMNzKRI5cHFE0/giphy.gif?cid=790b7611c06c74840cb7d6e490862ffaa5a056e48e9f5ee5&rid=giphy.gif&ct=g)


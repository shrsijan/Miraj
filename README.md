# Project 2 - *Miraj*

Submitted by: **Sijan Shrestha**

**Miraj** is a social media app that allows users to share photos with captions, like and comment on posts, and connect with others through a clean, minimalist interface.

Time spent: **8** hours spent in total

## Required Features

The following **required** functionality is completed:

- [x] Users see an app icon in the home screen and a styled launch screen.
- [x] User can register a new account
- [x] User can log in with newly created account
- [x] App has a feed of posts when user logs in
- [x] User can upload a new post which takes in a picture from photo library and an optional caption	
- [x] User is able to logout	
 
The following **optional** features are implemented:

[] Users can pull to refresh their feed and see a loading indicator
- [x] Users can infinite-scroll in their feed to see past the 10 most recent photos
- [x] Users can see location and time of photo upload in the feed	
- [x] User stays logged in when app is closed and open again	


The following **additional** features are implemented:

- [x] Like posts with heart animation and like count
- [x] Comment on posts with inline display (up to 3 comments shown)
- [x] Inline comment input below posts
- [x] Edit profile (change username and email)
- [x] Edit post captions
- [x] Delete own posts
- [x] Custom inline photo gallery picker 
- [x] Location metadata extraction from photos using GPS data
- [x] Variable photo dimension support

## Video Walkthrough

https://github.com/user-attachments/assets/0691104b-6acb-4dcb-9b48-7251c82eeb85



## Notes

Challenges encountered while building the app:
- Configuring Parse SDK initialization to avoid SIGKILL crashes (solved by using AppDelegate)
- Setting up Back4App class-level permissions for user signup and post creation
- Handling variable photo dimensions while maintaining consistent UI layout
- Extracting and displaying location metadata from photo assets
- Implementing inline photo gallery picker instead of system PhotosPicker popup

## License

    Copyright 2026 Sijan Shrestha

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

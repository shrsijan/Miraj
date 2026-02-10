# Project 3 - *Miraj*

Submitted by: **Sijan Shrestha**

**Miraj** is a social media app that allows users to share photos with captions, like and comment on posts, and connect with others through a clean, minimalist interface.

Time spent: **12** hours spent in total

## Required Features

The following **required** functionality is completed:

- [x] Users are able to use the back camera to take a photo and upload it to the server OR user uploads unique photo from photo album
- [x] Posts have comment section, which displays commentor's username and comment context
- [x] Posts have a time and location attached to them
- [x] Get Photo Metadata (GPS location extracted from photo library assets; device location captured for camera photos)
- [x] Users are not able to see other users' photos until they upload their own
- [x] Fetch the 10 most recent photos within the last 24 hours from the server
- [x] Of those returned in the response, only show the post if the createdAt property is within 24 hours of the logged in user's last post
- [x] Posts outside the 24-hour window are blurred with a "Post to reveal" overlay

The following **stretch** features are implemented:

- [x] Users receive a local notification reminder to post every 8 hours
- [x] Notification permissions requested after successful login/signup
- [x] Notifications unregistered on logout

The following **additional** features are implemented:

- [x] Like posts with heart animation and like count
- [x] Comment on posts with inline display (up to 3 comments shown)
- [x] Full comment thread view
- [x] Edit profile (change username and email)
- [x] Edit post captions
- [x] Delete own posts
- [x] Custom inline photo gallery picker
- [x] Variable photo dimension support
- [x] Pull to refresh feed
- [x] User stays logged in when app is closed and opened again
- [x] Custom `lastPostedAt` property added to User model via Parse-Swift

## Video Walkthrough


https://github.com/user-attachments/assets/663afac2-7f40-4fcc-aa2e-3e91919299e6


## Notes

Challenges encountered while building the app:
- Configuring Parse SDK initialization to avoid SIGKILL crashes (solved by using AppDelegate)
- Setting up Back4App class-level permissions for user signup and post creation
- Handling variable photo dimensions while maintaining consistent UI layout
- Extracting and displaying location metadata from photo assets
- Implementing inline photo gallery picker instead of system PhotosPicker popup
- Wrapping UIImagePickerController in a SwiftUI UIViewControllerRepresentable for camera access
- Capturing device GPS location at camera capture time using CLLocationManager
- Implementing 24-hour post visibility window with blur overlay for restricted posts
- Scheduling repeating local notifications with UNTimeIntervalNotificationTrigger

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

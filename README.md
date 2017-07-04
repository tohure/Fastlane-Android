<h1 align="center">Fastlane for Android with Docker</h1>

<p align="center">
    <img src="http://i.imgur.com/zhIhbvw.png" alt="fastlane-docker" width="30%"/>
</p>

# Docker + Fastlane + Android 
Dockerfile for run fastlane image with config only for deploy Android Apps based in a Ubuntu Image

# Setup
For use this image, change your Android SDK path in [YOUR HOME ANDROID PATH] (<a target="_blank" href="https://github.com/Tohure/Fastlane-Android/blob/master/Dockerfile#L75">Line 75</a>), for something like: 
 - /Users/USER/Library/Android/ (In Mac)
 - /home/USER/Android/    (In some Linux)
 - Or your /path/path/AndroidSDK
 
 You can use the path indicate in your Android Project.
 
Remember that you can add or change the _android api levels_ that you want to download. For this example, only version 25 is used. (<a target="_blank" href="https://github.com/Tohure/Fastlane-Android/blob/master/Dockerfile#L81">Line 81</a>)


# Build
docker build . -t fastlane-docker (Or the name you like)


# Run
docker run -ti -v /YOUR_ANDROID_PROJECT_PATH/:/usr/local/share fastlane-docker bash


# Test
In the bash of your container you can run _fastlane test_ to "test" that fastlane works correctly.

Remember that only the first time, the command may take a little time, depending on your internet connection, since fastlane downloads additional libraries such as _graddle_ in the case of Android.

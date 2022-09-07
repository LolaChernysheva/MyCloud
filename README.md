# MyCloud
## _Prototype cloud file storage service_

![Cocoapods platforms](https://img.shields.io/cocoapods/p/ios?color=g)

✨MyCloud is a prototype cloud file storage service.✨

## Features

- Create an account
- Create folders, add files and photos from your iPhone
- Rename and delete previously added folders, files and photos
- Filter the displayed items: folders, files and photos

The service contains validation of the size and extension of files: the maximum possible size of the uploaded file - 20Mb, there is a restriction on the download of files with the extension .txt and livePhotos (they will be converted to JPG format)

## Tech

MyCloud uses a number of open source projects to work properly:

- [Realm](https://github.com/realm) - a mobile database
- [SnapKit](https://github.com/SnapKit/SnapKit) - a DSL to make Auto Layout easy on both iOS and OS X.

The main interface is a table with a list of downloaded items.

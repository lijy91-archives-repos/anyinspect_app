
#

## Mac

Guide: <https://retroportalstudio.medium.com/creating-dmg-file-for-flutter-macos-apps-e448ff1cb0f>

Installing the Node Package for creating the .dmg:
Package Link: <https://www.npmjs.com/package/appdmg>

For installing, we need to go to the terminal and use the command

npm install -g appdmg
At root folder project

```sh
flutter build macos
cd /build/macos/Build/Products/dmg_creator
```

We will create a new file called config.json in dmg_creator folder which will contain the configuration for the .dmg, contents of the config.json

```json
{
    "title": "Flutter Tips",
    "icon": "app_icon.png",
    "contents": [
      { "x": 448, "y": 344, "type": "link", "path": "/Applications" },
      { "x": 192, "y": 344, "type": "file", "path": "../Release/anyinspect_app.app" }
    ]
}
```

Creating the .dmg file:
Once we have the config.json in place, we can use the appdmg executable to proceed further. for this you need to use the following command in the terminal:

```sh
appdmg ./config.json ./anyinspect_app.dmg
```

Once this program executes, we will have the result file in our dmg_creator folder.

# Courier-Market-Mobile

Courier Market Mobile Application, written in Flutter

### Install

- Install flutter, <https://flutter.dev/docs/get-started/install>
- Git Clone
- Open Xcode, make sure development profile is set and set schema to debug
- cd to route of project
- Run
    - `flutter pub get`
    - `flutter pub run build_runner build`
    - `flutter run --no-sound-null-safety --dart-define=env=stage --dart-define=SERVER_URL=http://courier-market-web.test/api`
- Build
    - `flutter build [apk|appbundle] --no-sound-null-safety`
    - Nb: appbundle allows google play to repackage more efficiently per ABI, however, they cannot easily be installed
      to ones device locally.<br/>
      As such, it's recommended to use appbundle when distributing, but apk whilst testing

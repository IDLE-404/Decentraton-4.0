
```markdown
# InDrive Car Condition Checker

Приложение для анализа состояния автомобиля по фотографиям (чистота и целостность).

## Структура проекта

```

project/
├─ android/
│  ├─ app/
│  ├─ build.gradle.kts
│  └─ key.properties
├─ lib/
│  ├─ screens/
│  ├─ widgets/
│  └─ models/
├─ pubspec.yaml
└─ ...

````

## Установка зависимостей

```bash
flutter pub get
````

## Настройка подписи APK (Release)

1. Keystore уже создан и лежит в `android/release-key.jks`.

2. Файл `android/key.properties` содержит:

```properties
storePassword=storePassword
keyPassword=storePassword
keyAlias=release
storeFile=android/release-key.jks
```

3. В `android/app/build.gradle.kts` используется:

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String?
    }
}

buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = false
        isShrinkResources = false
    }
}
```

## Сборка APK

```bash
flutter clean
flutter pub get
flutter build apk --release
```

APK будет доступен:

```
build/app/outputs/flutter-apk/app-release.apk
```

## Установка на Android

1. Передать APK на устройство.
2. Разрешить установку из «неизвестных источников».
3. Установить APK.

## Запуск проекта (Debug)

```bash
flutter run
```

## Требования

* Flutter 3.10+
* Android SDK 36+
* JDK 11

```



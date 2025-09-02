<<<<<<< HEAD
<<<<<<< HEAD
# fog_of_life_mvp
Fog :)
=======
=======
>>>>>>> 83208a69b400d77fa4721ca0aef04d98ab6a8ac6
# Fog of Life MVP (Flutter + MapLibre + Drift)

Este esqueleto incluye:
- Mapa (MapLibre) y capa de "niebla"
- Tracking de ubicación en primer plano con throttling
- Conversión lat/lon -> tile (z/x/y)
- Persistencia local en SQLite (Drift)
- 3 pantallas: Mapa, Progreso, Ajustes

## Requisitos en macOS
- Flutter SDK (3.x): https://docs.flutter.dev/get-started/install/macos
- Xcode (para iPhone) y/o Android Studio (para Android)

## Pasos rápidos
```bash
# 1) En una carpeta local
unzip fog_of_life_mvp.zip
cd fog_of_life_mvp

# 2) Instala dependencias
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# 3) Genera plataformas (si no existen)
flutter create .

# 4) Permisos
# iOS: edita ios/Runner/Info.plist y añade:
# <key>NSLocationWhenInUseUsageDescription</key>
# <string>Necesitamos tu ubicación para revelar el mapa mientras usas la app.</string>
#
# Android: edita android/app/src/main/AndroidManifest.xml y añade (dentro de <manifest>):
# <uses-permission android:name="android.permission.INTERNET"/>
# <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
# <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

# 5) Conecta tu dispositivo y ejecuta
flutter devices
flutter run
```

> Nota: el estilo del mapa usa `https://demotiles.maplibre.org/style.json`. Requiere internet.

## Siguientes pasos
- Añadir seguimiento en segundo plano (permisos Always/Background).
- Medir batería y ajustar sampling.
<<<<<<< HEAD
- Cálculo de % descubierto por área administrativa.
>>>>>>> 83208a6 (init: MVP funcionando con Stadia + fog)
=======
- Cálculo de % descubierto por área administrativa.
>>>>>>> 83208a69b400d77fa4721ca0aef04d98ab6a8ac6

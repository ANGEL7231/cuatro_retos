# Cuatro Retos

Una sola app Flutter con 4 pestañas, una por reto, con la misma arquitectura,
seguridad y TDD de *Dolores Hoy*:

| Reto | API | Clave | Qué hace |
|------|-----|-------|----------|
| 1 Películas | TMDB | **Sí** (gratis) | Película al azar según tu estado de ánimo o tendencias |
| 2 Gatos | Cataas | No | Gato aleatorio con tu frase encima y filtros (URL dinámica) |
| 3 Clima | OpenWeatherMap | **Sí** (gratis) | Clima actual de cualquier ciudad (por defecto, Dolores Hidalgo) |
| 4 Cripto | CoinGecko | No | Precio de BTC/ETH/SOL y cuántas fracciones compras con X USD |

## Claves (gratis)
- TMDB: https://www.themoviedb.org/settings/api (usa la "API Key (v3 auth)").
- OpenWeatherMap: https://home.openweathermap.org/api_keys (la clave nueva puede tardar
  unos minutos u horas en activarse; mientras tanto devuelve 401).

Ponlas en `secrets.json` (ignorado por git; la plantilla es `secrets.json.example`).
Si falta una clave, solo esa pestaña muestra "Falta configurar la clave ..." y las demás funcionan.

## Puesta en marcha
```bash
flutter create . --project-name cuatro_retos --org mx.edu.utng
flutter pub get
flutter test
flutter run --dart-define-from-file=secrets.json
```
Verifica que `android/app/src/main/AndroidManifest.xml` tenga el permiso
`<uses-permission android:name="android.permission.INTERNET"/>` y NO active `usesCleartextTraffic`.

## Estructura
- `lib/dominio/`: excepciones con mensajes seguros y modelos (Pelicula, ClimaCiudad, PreciosCripto...).
- `lib/datos/`: `ClienteSeguro` (https obligatorio, timeout, límite de tamaño, JSON validado,
  `redactar` oculta `api_key` y `appid`), `ConfigClaves` y un servicio por API.
- `lib/presentacion/`: un ViewModel y una pantalla por reto + navegación inferior.
- `test/`: pruebas por reto, de seguridad y de los ViewModels (sin internet, con MockClient).

## Decisiones de seguridad
- Todo texto del usuario (frase del gato, ciudad, monto) se valida y se codifica con
  `pathSegments` / `Uri.https`, nunca se pega a mano en la URL.
- Las rutas de póster de TMDB solo se aceptan con la forma `/abc.jpg`.
- Los precios <= 0 se rechazan para no dividir entre cero; el monto se valida (sin NaN/∞/negativos).
- Las claves entran con `--dart-define`, no están en el código ni en git.

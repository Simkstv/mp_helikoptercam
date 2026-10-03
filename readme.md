# MP HelikopterCam

Eine konfigurierbare Helikopterkamera für FiveM.

Das Script stellt eine Kamerafunktion für definierte Helikopter bereit und eignet sich beispielsweise für Polizei-, Rettungsdienst- oder andere Einsatzhubschrauber.

## Features

- Konfigurierbare Kameras für verschiedene Fahrzeugmodelle
- Frei definierbare Kameraposition am Fahrzeug
- Schwenkbare Kamera
- Konfigurierbarer horizontaler und vertikaler Schwenkbereich
- Stufenloser Kamera-Zoom
- Normaler Kameramodus
- Night Vision
- Thermal Vision
- Kamera-HUD
- Anzeige von:
  - Sichtmodus
  - Flugrichtung (HDG)
  - Kamerarotation (CAM ROT)
  - Geschwindigkeit in Knoten
  - Flughöhe in Fuß
  - Zoomstufe
- Pilot kann die Kamera nicht verwenden
- Kamera wird automatisch geschlossen, wenn das Fahrzeug verlassen wird
- Unterstützung mehrerer Helikopter über die Config
- Standalone

## Installation

1. Resource in den `resources`-Ordner des FiveM-Servers kopieren.

## Dependencies
- [OxMySQL](https://github.com/overextended/oxmysql)
- Framework OxCore, ESX oder QB für die Fahrzeugauslese bennötigt.

Beispiel:

```text
resources/
└── mp_helikoptercam/
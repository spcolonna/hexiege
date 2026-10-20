# Hexiege — App Store Connect / TestFlight

Datos fijos del build: bundle `com.spcolonna.hexiege`, team RZGQPAGH53 (Sebastian Perez,
personal), versión 1.0.0 (build 1), iOS 13+, iPhone y iPad, cifrado exento ya declarado
en Info.plist (`ITSAppUsesNonExemptEncryption = NO`).

## 1. Bundle ID (developer.apple.com → Identifiers)
Si no existe todavía: **+** → App IDs → App.
- Description: `Hexiege`
- Bundle ID (Explicit): `com.spcolonna.hexiege`
- Capabilities: ninguna.

## 2. Crear la app (App Store Connect → Apps → + → Nueva app)
| Campo | Valor |
|---|---|
| Plataformas | iOS |
| Nombre | `Hexiege` |
| Idioma principal | English (U.S.) |
| ID de paquete | `com.spcolonna.hexiege` |
| SKU | `HEXIEGE-IOS` |
| Acceso de usuarios | Acceso completo |

Inglés como idioma principal porque es el que se muestra en los países sin traducción.
Después se agregan las localizaciones Spanish (Mexico) y Chinese (Simplified).

## 3. Información de la app (General → Información de la app)
| Campo | Valor |
|---|---|
| Subtítulo en | `Surround the enemy leader` |
| Subtítulo es-MX | `Rodeá al líder enemigo` |
| Subtítulo zh-Hans | `包围敌方首领` |
| Categoría principal | Juegos → Estrategia |
| Categoría secundaria | Juegos → Juegos de mesa |
| Derechos de contenido | No contiene contenido de terceros |
| Clasificación por edad | Todo "Ninguno" / "No" → 4+ |

## 4. Privacidad de la app
- URL de la política: `https://spcolonna.github.io/hexiege/privacidad.html`
- Prácticas de datos → **No, no recopilamos datos de esta app** → "Datos no recopilados".

## 5. Precio y disponibilidad
- Precio: Gratis (USD 0). Países: dejarlo para el lanzamiento.

## 6. Subir el build
El archivo ya está generado: `build/ios/archive/Runner.xcarchive`.
`flutter build ipa` no puede exportarlo desde la terminal (Xcode tiene la cuenta, la CLI no).
1. `open build/ios/archive/Runner.xcarchive` → abre el Organizer de Xcode.
2. Distribute App → App Store Connect → **Export** (o Upload directo, si preferís).
3. Signing automático, equipo Sebastian Perez → Export → carpeta con `hexiege.ipa`.
4. Transporter → arrastrar el `.ipa` → Deliver.

Cada build nuevo necesita subir el número: `version: 1.0.0+2` en `pubspec.yaml`, y
`flutter build ipa --release`.

## 7. TestFlight
- Información de prueba: descripción beta, email de feedback `orakigames.uy@gmail.com`.
- Grupo interno (ej. `Oraki`) → agregarte. Los internos no pasan revisión de beta.
- Para externos: grupo externo + revisión de beta de Apple (usa la info de prueba).

## 8. Compra dentro de la app: historia completa (USD 1,99)
El juego es gratis; el Acto I de cada campaña (12 batallas) también. Una compra única
desbloquea los Actos II–IV y El Sello. Sin servidor: StoreKit confirma y la app guarda
el desbloqueo; "Restaurar compras" está en Ajustes y en la hoja de desbloqueo.

1. App Store Connect → la app → **Monetización → Compras dentro de la app → +**.
   - Tipo: **No consumible**.
   - Nombre de referencia: `Historia completa`.
   - ID de producto: **`hexiege_story`** (tiene que coincidir con `Purchases.storyId`).
2. Precio: USD 1,99 (nivel equivalente; Apple calcula el resto de los países).
3. Localizaciones (nombre visible y descripción):
   - es: *Historia completa* · "Los Actos II a IV de las dos campañas y El Sello, el verdadero final."
   - en: *Full story* · "Acts II to IV of both campaigns and The Seal, the true ending."
   - zh-Hans: *完整故事* · "两场战役的第二至第四幕，以及真正的结局《封印》。"
4. Revisión: captura de la hoja de desbloqueo (aparece al ganar la batalla 6) y nota:
   "Unlocks battles 7–24 of both campaigns and the finale. Restore purchases is in
   Settings."
5. La primera compra se envía **junto con una versión nueva** del build (en la página de la
   versión, sección "Compras dentro de la app", agregarla).
6. Contratos: **Acuerdos, impuestos y banca** tienen que estar firmados (Apps de pago) o
   la tienda no devuelve el producto.
7. Privacidad: comprar no agrega recopilación de datos por parte de la app (StoreKit es
   de Apple); se mantiene "Datos no recopilados".

**Probar sin App Store Connect:** `ios/Runner/Hexiege.storekit` tiene el producto.
En Xcode: Product → Scheme → Edit Scheme → Run → Options → **StoreKit Configuration** →
`Hexiege.storekit`, y correr desde Xcode. Para TestFlight se usa la cuenta sandbox.

## Para el lanzamiento (después)
- Copyright: `2026 Oraki Games`
- Capturas iPhone 6.9" y iPad 13" (soporte iPad activo).
- Descripción, palabras clave, URL de soporte (puede ser la misma página de GitHub Pages).
- Revisar el texto de la política si se agrega online o anuncios.

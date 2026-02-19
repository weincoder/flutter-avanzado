---
sidebar_position: 1
---

# 🎷 Backend Driven UI

Backend Driven UI (BDUI) es un paradigma donde el servidor controla qué componentes y layouts se renderizan en la aplicación móvil.

## ¿Qué es Backend Driven UI?

En lugar de que la app tenga layouts hardcodeados, el backend envía una descripción de la interfaz que la app interpreta y renderiza dinámicamente.

```json
{
  "type": "screen",
  "children": [
    {
      "type": "header",
      "props": { "title": "Bienvenido", "color": "#1976D2" }
    },
    {
      "type": "card_list",
      "props": { "orientation": "horizontal" },
      "children": [
        { "type": "product_card", "props": { "id": "123", "name": "Producto A" } }
      ]
    }
  ]
}
```

## ¿Por qué usarlo?

- 🚀 **Actualizaciones sin deploy**: Cambia la UI sin publicar nueva versión
- 🧪 **A/B Testing**: Prueba diferentes layouts por segmento de usuarios
- 🎯 **Personalización**: UI diferente según el usuario
- ⚡ **Velocidad de iteración**: Los cambios son inmediatos
- 📱 **Consistencia multi-plataforma**: Un solo backend controla iOS, Android, Web

## Empresas que lo usan

- **Airbnb**: Ghost Platform
- **Uber**: RIBs + Server-Driven
- **Instagram/Meta**: Server-Driven Rendering
- **Rappi**: BDUI para home screen

## Temas que cubriremos

1. Fundamentos de BDUI
2. Diseño del contrato JSON/Protobuf
3. Widget Registry y Widget Factory
4. Navegación dinámica
5. Manejo de acciones y eventos
6. Caching y performance
7. Testing de componentes dinámicos

## Recursos

- [Server-Driven UI - Airbnb](https://medium.com/airbnb-engineering)
- [Flutter Dynamic Widget](https://pub.dev/packages/dynamic_widget)

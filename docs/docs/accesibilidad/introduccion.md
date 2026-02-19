---
sidebar_position: 1
---

# 🐦 Accesibilidad en Flutter

La accesibilidad es un aspecto fundamental del desarrollo de aplicaciones. Crear apps accesibles no solo es una buena práctica, sino que en muchos países es un requisito legal.

## ¿Qué es la Accesibilidad?

La accesibilidad (a11y) se refiere a diseñar y desarrollar aplicaciones que puedan ser utilizadas por todas las personas, incluyendo aquellas con discapacidades visuales, auditivas, motoras o cognitivas.

## ¿Por qué importa?

- 🌍 Más del **15% de la población mundial** tiene algún tipo de discapacidad
- ⚖️ Cumplimiento legal (WCAG, ADA, etc.)
- 📈 Mayor alcance de usuarios
- 💡 Mejora la UX para todos los usuarios

## Semantics en Flutter

Flutter utiliza el widget `Semantics` para proporcionar información a los lectores de pantalla:

```dart
Semantics(
  label: 'Botón de búsqueda',
  hint: 'Toca dos veces para buscar',
  child: IconButton(
    icon: Icon(Icons.search),
    onPressed: () {},
  ),
)
```

## Herramientas de Flutter para Accesibilidad

- **Semantics Widget**: Etiquetas para lectores de pantalla
- **ExcludeSemantics**: Excluir elementos decorativos
- **MergeSemantics**: Agrupar elementos relacionados
- **SemanticsDebugger**: Visualizar el árbol semántico

## Temas que cubriremos

1. Semantics y lectores de pantalla (TalkBack/VoiceOver)
2. Contraste de colores y tamaños de fuente
3. Navegación por teclado y focus management
4. Testing de accesibilidad
5. Mejores prácticas y checklist de a11y

## Recursos

- [Flutter Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/TR/WCAG21/)

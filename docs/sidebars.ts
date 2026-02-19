import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    'intro',
    {
      type: 'category',
      label: '🐦 Accesibilidad',
      items: [
        'accesibilidad/introduccion',
      ],
    },
    {
      type: 'category',
      label: '🧶 Isolates',
      items: [
        'isolates/introduccion',
        'isolates/basico',
        'isolates/avanzado',
      ],
    },
    {
      type: 'category',
      label: '📍 Platform Channels',
      items: [
        'platform-channels/introduccion',
      ],
    },
    {
      type: 'category',
      label: '🎷 Backend Driven UI',
      items: [
        'backend-driven-ui/introduccion',
      ],
    },
    {
      type: 'category',
      label: '🐵 Seguridad',
      items: [
        'seguridad/introduccion',
      ],
    },
    {
      type: 'category',
      label: '😎 Estructurar Grandes Proyectos',
      items: [
        'estructurar-proyectos/introduccion',
      ],
    },
    {
      type: 'category',
      label: '⏳ Performance',
      items: [
        'performance/optimizacion',
        'performance/profiling',
        'performance/memory',
      ],
    },
    {
      type: 'category',
      label: '🌊 Inteligencia Artificial',
      items: [
        'inteligencia-artificial/introduccion',
      ],
    },
    {
      type: 'category',
      label: '🎷 Super Apps',
      items: [
        'super-apps/introduccion',
      ],
    },
    {
      type: 'category',
      label: '🗂 Telemetría',
      items: [
        'telemetria/introduccion',
      ],
    },
    {
      type: 'category',
      label: '🏞 Desarrollador de Alto Impacto',
      items: [
        'desarrollador-alto-impacto/introduccion',
      ],
    },
    {
      type: 'category',
      label: '🏀 ¿Qué sigue?',
      items: [
        'que-sigue/introduccion',
      ],
    },
  ],
};

export default sidebars;

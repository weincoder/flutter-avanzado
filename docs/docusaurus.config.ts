import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'Flutter Avanzado',
  tagline: 'Aprende Flutter con conceptos avanzados y casos de uso reales',
  favicon: 'img/favicon.png',

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: 'https://weincoder.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/flutter-avanzado/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'weincoder', // Usually your GitHub org/user name.
  projectName: 'flutter-avanzado', // Usually your repo name.
  trailingSlash: false,

  onBrokenLinks: 'throw',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'es',
    locales: ['es'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        },
        blog: {
          showReadingTime: true,
          feedOptions: {
            type: ['rss', 'atom'],
            xslt: true,
          },
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
          // Useful options to enforce blogging best practices
          onInlineTags: 'warn',
          onInlineAuthors: 'warn',
          onUntruncatedBlogPosts: 'warn',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'Flutter Avanzado',
      logo: {
        alt: 'Flutter Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Documentación',
        },
        {to: '/blog', label: 'Blog', position: 'left'},
        {
          href: 'https://github.com/flutter',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentación',
          items: [
            {
              label: 'Introducción',
              to: '/docs/intro',
            },
            {
              label: 'Isolates',
              to: '/docs/isolates/introduccion',
            },
            {
              label: 'Platform Channels',
              to: '/docs/platform-channels/introduccion',
            },
            {
              label: 'Performance',
              to: '/docs/performance/optimizacion',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'Flutter Community',
              href: 'https://flutter.dev/community',
            },
            {
              label: 'Discord',
              href: 'https://discord.gg/flutter',
            },
            {
              label: 'Stack Overflow',
              href: 'https://stackoverflow.com/questions/tagged/flutter',
            },
          ],
        },
        {
          title: 'Más',
          items: [
            {
              label: 'Blog',
              to: '/blog',
            },
            {
              label: 'Flutter.dev',
              href: 'https://flutter.dev',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Flutter Avanzado — Weincode. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['dart', 'bash', 'json', 'yaml', 'kotlin', 'swift'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;

import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero', styles.heroBanner)}>
      <div className="container">
        <div className={styles.heroInner}>
          <div className={styles.heroText}>
            <span className={styles.heroBadge}>🚀 Curso Avanzado</span>
            <Heading as="h1" className={styles.heroTitle}>
              Flutter{' '}
              <span className={styles.heroTitleAccent}>Avanzado</span>
            </Heading>
            <p className={styles.heroSubtitle}>
              {siteConfig.tagline}
            </p>
            <p className={styles.heroDescription}>
              Domina <strong>12 temas avanzados</strong> de Flutter: Isolates, Platform Channels, 
              Backend Driven UI, Seguridad, IA, Super Apps y mucho más.
            </p>
            <div className={styles.heroButtons}>
              <Link
                className={clsx('button button--lg', styles.heroButtonPrimary)}
                to="/docs/intro">
                📚 Comenzar el Curso
              </Link>
              <Link
                className={clsx('button button--lg', styles.heroButtonSecondary)}
                href="https://discord.gg/mtJWZFZE7R">
                💬 Unirse al Discord
              </Link>
            </div>
          </div>
          <div className={styles.heroVisual}>
            <div className={styles.heroCard}>
              <div className={styles.heroCardHeader}>
                <span className={styles.dot} style={{background: '#FF5F56'}} />
                <span className={styles.dot} style={{background: '#FFBD2E'}} />
                <span className={styles.dot} style={{background: '#27C93F'}} />
              </div>
              <pre className={styles.heroCode}>
                <code>
{`import 'dart:isolate';

Future<void> main() async {
  final result = await Isolate.run(() {
    // Heavy computation 🧶
    return fibonacci(42);
  });
  print('Result: \$result'); // 🚀
}`}
                </code>
              </pre>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}

function StatsSection() {
  return (
    <section className={styles.stats}>
      <div className="container">
        <div className={styles.statsGrid}>
          <div className={styles.statItem}>
            <span className={styles.statNumber}>12</span>
            <span className={styles.statLabel}>Temas Avanzados</span>
          </div>
          <div className={styles.statItem}>
            <span className={styles.statNumber}>100%</span>
            <span className={styles.statLabel}>Práctico</span>
          </div>
          <div className={styles.statItem}>
            <span className={styles.statNumber}>🆓</span>
            <span className={styles.statLabel}>Gratuito</span>
          </div>
          <div className={styles.statItem}>
            <span className={styles.statNumber}>ES/EN</span>
            <span className={styles.statLabel}>Bilingüe</span>
          </div>
        </div>
      </div>
    </section>
  );
}

function CTASection() {
  return (
    <section className={styles.cta}>
      <div className="container">
        <div className={styles.ctaInner}>
          <Heading as="h2" className={styles.ctaTitle}>
            ¿Listo para dominar Flutter? 🎯
          </Heading>
          <p className={styles.ctaText}>
            Únete a la comunidad de desarrolladores que están llevando sus habilidades de Flutter al siguiente nivel.
          </p>
          <div className={styles.ctaButtons}>
            <Link
              className={clsx('button button--lg', styles.heroButtonPrimary)}
              to="/docs/intro">
              Explorar la Documentación
            </Link>
            <Link
              className={clsx('button button--lg', styles.heroButtonSecondary)}
              href="https://youtube.com/@weincode">
              📺 Ver en YouTube
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title="Aprende Flutter Avanzado"
      description="Curso completo de Flutter avanzado: Isolates, Platform Channels, Backend Driven UI, Seguridad, IA, Super Apps, Telemetría y más.">
      <HomepageHeader />
      <StatsSection />
      <main>
        <HomepageFeatures />
      </main>
      <CTASection />
    </Layout>
  );
}

import type {ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import Link from '@docusaurus/Link';
import styles from './styles.module.css';

type FeatureItem = {
  emoji: string;
  title: string;
  description: ReactNode;
  link: string;
};

const FeatureList: FeatureItem[] = [
  {
    emoji: '🐦',
    title: 'Accesibilidad',
    description: 'Crea apps inclusivas para todos los usuarios con Semantics, lectores de pantalla y más.',
    link: '/docs/accesibilidad/introduccion',
  },
  {
    emoji: '🧶',
    title: 'Isolates',
    description: 'Programación concurrente y multi-hilo en Dart para operaciones pesadas sin bloquear la UI.',
    link: '/docs/isolates/introduccion',
  },
  {
    emoji: '📍',
    title: 'Platform Channels',
    description: 'Comunica Flutter con código nativo iOS y Android usando MethodChannel, EventChannel y Pigeon.',
    link: '/docs/platform-channels/introduccion',
  },
  {
    emoji: '🎷',
    title: 'Backend Driven UI',
    description: 'Interfaces dinámicas controladas desde el servidor. Actualiza la UI sin publicar nueva versión.',
    link: '/docs/backend-driven-ui/introduccion',
  },
  {
    emoji: '🐵',
    title: 'Seguridad',
    description: 'Protege tu app y los datos de tus usuarios con encriptación, SSL pinning y más.',
    link: '/docs/seguridad/introduccion',
  },
  {
    emoji: '😎',
    title: 'Estructurar Proyectos',
    description: 'Arquitectura escalable con monorepos, Clean Architecture y modularización para equipos grandes.',
    link: '/docs/estructurar-proyectos/introduccion',
  },
  {
    emoji: '⏳',
    title: 'Performance',
    description: 'Optimización, profiling y gestión de memoria para apps Flutter de alto rendimiento.',
    link: '/docs/performance/optimizacion',
  },
  {
    emoji: '🌊',
    title: 'Inteligencia Artificial',
    description: 'Integra modelos de IA (Gemini, GPT, TensorFlow Lite) en tus apps Flutter.',
    link: '/docs/inteligencia-artificial/introduccion',
  },
  {
    emoji: '🎷',
    title: 'Super Apps',
    description: 'Construye aplicaciones todo-en-uno con módulos dinámicos y arquitectura de mini-apps.',
    link: '/docs/super-apps/introduccion',
  },
  {
    emoji: '🗂',
    title: 'Telemetría',
    description: 'Monitoreo, analytics y observabilidad para entender el comportamiento de tu app en producción.',
    link: '/docs/telemetria/introduccion',
  },
  {
    emoji: '🏞',
    title: 'Desarrollador de Alto Impacto',
    description: 'Habilidades profesionales que marcan la diferencia: code reviews, comunicación y liderazgo técnico.',
    link: '/docs/desarrollador-alto-impacto/introduccion',
  },
  {
    emoji: '🏀',
    title: '¿Qué sigue?',
    description: 'Próximos pasos en tu carrera: open source, Dart backend, Flutter Web, Desktop y más.',
    link: '/docs/que-sigue/introduccion',
  },
];

function Feature({emoji, title, description, link}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <Link to={link} className={styles.featureLink}>
        <div className={styles.featureCard}>
          <div className={styles.featureEmoji}>{emoji}</div>
          <Heading as="h3" className={styles.featureTitle}>{title}</Heading>
          <p className={styles.featureDescription}>{description}</p>
          <span className={styles.featureArrow}>Explorar →</span>
        </div>
      </Link>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className={styles.sectionHeader}>
          <Heading as="h2" className={styles.sectionTitle}>
            📚 Temario del Curso
          </Heading>
          <p className={styles.sectionSubtitle}>
            12 temas avanzados diseñados para convertirte en un desarrollador Flutter profesional
          </p>
        </div>
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}

export const SITE = {
  name: 'SetupCol',
  tagline: 'Setups para estudiar y trabajar desde casa, sin gastar de más',
  description:
    'Guías y comparativas de sillas, escritorios, monitores y accesorios para estudiantes y home office en Colombia.',
  lang: 'es-CO',
};

export const CATEGORIES = {
  sillas: 'Sillas',
  escritorios: 'Escritorios',
  monitores: 'Monitores',
  perifericos: 'Teclados y mouse',
  iluminacion: 'Iluminación',
  accesorios: 'Accesorios',
  guias: 'Setups completos',
} as const;

export type CategoryKey = keyof typeof CATEGORIES;

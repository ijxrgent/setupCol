import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

const producto = z.object({
  nombre: z.string(),
  etiqueta: z.string().optional(), // "Mejor calidad/precio", "Más barato"...
  precioAprox: z.string().optional(), // texto libre: "$180.000 aprox." — revísalo seguido
  imagen: z.string().optional(),
  resumen: z.string(),
  pros: z.array(z.string()).default([]),
  contras: z.array(z.string()).default([]),
  linkMercadoLibre: z.string().url().optional(),
  linkTemu: z.string().url().optional(),
});

const articulos = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/articulos' }),
  schema: z.object({
    titulo: z.string(),
    descripcion: z.string().max(160), // meta description para Google
    categoria: z.enum(['sillas', 'escritorios', 'monitores', 'perifericos', 'iluminacion', 'accesorios', 'guias']),
    publicado: z.coerce.date(),
    actualizado: z.coerce.date().optional(),
    destacado: z.boolean().default(false),
    borrador: z.boolean().default(false),
    productos: z.array(producto).default([]),
  }),
});

export const collections = { articulos };

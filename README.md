# SetupCol

Sitio de afiliados (Mercado Libre y Temu) sobre setups para estudiantes y home office.
Hecho con **Astro + Tailwind**, desplegado en **AWS (S3 + CloudFront)** con **Terraform** y **GitHub Actions**.

## Arquitectura

```
 Usuario ──HTTPS──▶ CloudFront (CDN, edge en Bogotá)
                      │  CloudFront Function: /guias/x/ → /guias/x/index.html
                      ▼
                    S3 (bucket privado, solo CloudFront lee vía OAC)
                      ▲
 git push main ──▶ GitHub Actions ──OIDC──▶ rol IAM (mínimo privilegio)
                    npm run build → s3 sync → invalidación de caché
```

Costo esperado con poco tráfico: casi $0 (S3 y CloudFront tienen capa gratuita).
Si agregas dominio: ~USD 0,50/mes por la zona de Route 53 más el costo anual del dominio.

## 1. Correr en local

```bash
npm install
npm run dev        # http://localhost:4321
npm run build      # genera dist/
```

Los artículos viven en `src/content/articulos/*.md`. El nombre del archivo es la URL:
`mejores-soportes-para-laptop.md` → `/guias/mejores-soportes-para-laptop/`.
Los productos se definen en el frontmatter (`productos:`) y se pintan como tarjetas con tus links de afiliado.

> ⚠️ El artículo incluido trae productos de EJEMPLO. Reemplázalos por productos reales con tus links.

## 2. Infraestructura (una sola vez)

Requisitos: cuenta AWS, AWS CLI configurado con un usuario administrador (`aws configure`), Terraform ≥ 1.6.

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars   # edita github_repo y budget_email
terraform init
terraform plan      # lee el plan antes de aplicar: qué se crea y por qué
terraform apply
```

Al terminar, Terraform imprime 4 outputs. Los tres últimos van a GitHub.

## 3. Conectar GitHub

En el repo: **Settings → Secrets and variables → Actions → Variables** y crea:

| Variable | Valor |
|---|---|
| `AWS_ROLE_ARN` | output `github_deploy_role_arn` |
| `S3_BUCKET` | output `s3_bucket` |
| `CLOUDFRONT_DISTRIBUTION_ID` | output `cloudfront_distribution_id` |

Son variables, no secretos: con OIDC no guardas ninguna access key en GitHub.
Desde ahora, cada `git push` a `main` construye y publica el sitio solo.

## 4. Dominio propio (fase 2)

1. Compra el dominio (en Route 53 o en otro registrador y delega los NS a Route 53).
2. En `terraform.tfvars` llena `domain_name` y `hosted_zone_id`.
3. `terraform apply` crea el certificado HTTPS (ACM), lo valida por DNS y apunta el dominio a CloudFront.
4. Cambia `site` en `astro.config.mjs` y la línea `Sitemap` de `public/robots.txt`.

## Qué aprendes con cada archivo

| Archivo | Concepto |
|---|---|
| `s3.tf` | Bucket privado, bloqueo de acceso público, cifrado, bucket policy con condición `SourceArn` |
| `cloudfront.tf` | CDN, OAC, CloudFront Functions, políticas de caché, páginas de error |
| `github-oidc.tf` | Federación OIDC, trust policy, mínimo privilegio |
| `domain.tf` | ACM, validación DNS, registros alias en Route 53, `count` y `for_each` condicionales |
| `budget.tf` | Control de costos |
| `deploy.yml` | CI/CD, cabeceras `Cache-Control`, invalidaciones |

## Actividades

1. **Lee el plan.** Antes de `apply`, explica con tus palabras por qué el bucket policy depende de la distribución.
2. **Rompe y observa.** Entra a `https://xxxx.cloudfront.net/no-existe/` y luego intenta abrir el objeto directo por la URL de S3. ¿Qué responde cada uno y por qué?
3. **Estado remoto.** Crea un bucket para el estado de Terraform y activa el bloque `backend "s3"` de `providers.tf`. Ejecuta `terraform init -migrate-state`.
4. **Calidad en CI.** Agrega un job que corra `terraform fmt -check` y `terraform validate` en cada pull request.

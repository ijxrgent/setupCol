variable "project" {
  description = "Nombre corto del proyecto, se usa en nombres y tags"
  type        = string
  default     = "setupcol"
}

variable "aws_region" {
  description = "Región principal (déjala en us-east-1 por el certificado de CloudFront)"
  type        = string
  default     = "us-east-1"
}

variable "github_repo" {
  description = "Repositorio que puede desplegar, formato usuario/repo"
  type        = string
}

variable "create_github_oidc_provider" {
  description = "false si tu cuenta AWS ya tiene el proveedor OIDC de GitHub creado"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Dominio propio (ej. www.tudominio.com). Vacío = usar el dominio *.cloudfront.net"
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "ID de la zona de Route 53 del dominio. Obligatorio si usas domain_name"
  type        = string
  default     = ""
}

variable "budget_email" {
  description = "Correo para alertas de presupuesto. Vacío = no crear alerta"
  type        = string
  default     = ""
}

variable "budget_limit_usd" {
  description = "Límite mensual en USD antes de avisarte"
  type        = string
  default     = "5"
}

variable "github_owner_id" {
  description = "ID numérico del dueño del repo (sub: dueño@ID). Vacío = formato clásico"
  type        = string
  default     = ""
}

variable "github_repo_id" {
  description = "ID numérico del repo (sub: repo@ID). Vacío = formato clásico"
  type        = string
  default     = ""
}

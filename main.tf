resource "aws_ecr_repository" "alumni_database_ecr" {
  for_each             = var.repository_names
  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository" "eks-ecr" {
  name                 = var.ecr_name
  image_tag_mutability = var.ecr_image_tag_mutability
  force_delete         = var.ecr_force_delete
  

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }
}

resource "aws_codecommit_repository" "kjw-test" {
  repository_name = var.source_repo_name
  description     = "This is the App Repository"
}

output "source_repo_clone_url_http" {
  value = aws_codecommit_repository.kjw-test.clone_url_http
}

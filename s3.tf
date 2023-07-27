
#1. S3 Bucket 만들기 
resource "aws_s3_bucket" "team01_bucket" {
  bucket = "team01-bucket"
  object_lock_enabled = false
  
  tags = {
    Name        = "team01 bucket"
    Environment = "Dev"
  }
}

#2. 퍼블릭 액세스 차단(버킷 설정) 비활성 설정  <- 외부에서 접속 가능하게 설정 
resource "aws_s3_bucket_public_access_block" "team01_bucket" {
  bucket = aws_s3_bucket.team01_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_object" "team01-mp4" {
  bucket = aws_s3_bucket.team01_bucket.id
  key    = "team01.mp4"
  source = "team01.mp4"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("team01.mp4")
}

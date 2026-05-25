variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region (where the Okta token + reviewer_email secrets/params live)."
}

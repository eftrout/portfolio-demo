Deploy Static Webstie (AWS + Terraform + GitHub Actions)

This project deploys a static website hosted on AWS S3 bucket via a workflow on GitHub Actions.
Cloudfront CDN used to improve site security, speed, and flexibility.

The S3 bucket is fully managed by Terraform.
Any changes implemented on the static site "index.html" file will be implemented via GitHub Actions workflow once committed and pushed.

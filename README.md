Deploy Static Webstie (AWS + Terraform + GitHub Actions)

This project deploys a static website hosted on AWS S3 bucket via a workflow on GitHub Actions.
Cloudfront CDN used to improve site security, speed, and flexibility.

The S3 bucket is fully managed by Terraform.
Any changes implemented on the static site "index.html" file will be implemented via GitHub Actions workflow once committed and pushed.


Key Accomplishments & Problem-Solving

Throughout the project, I encountered and successfully resolved several common challenges, demonstrating my ability to research, troubleshoot, and implement solutions.


Infrastructure as Code (IaC) with Terraform

Resolved IAM credential issues: Initially, I was confused by the missing "programmatic access" option for new IAM users. I learned that the AWS console had changed its workflow. I adapted by manually creating the user and then generating the access key under the Security Credentials tab, allowing me to successfully configure GitHub Actions.

Corrected S3 bucket access: My initial Terraform configuration deployed the S3 bucket, but I received "Access Denied" errors when trying to view the website. I diagnosed this as a permissions issue and updated my Terraform code to explicitly set a bucket policy that allowed public read access. I also learned to use CloudFront to serve the content, keeping the S3 bucket more secure.

Managed Terraform state: When I tried to change the name of my S3 bucket, Terraform kept trying to create the old one. I learned this was due to the Terraform state file holding onto the old resource. I used “terraform state rm” to remove the old bucket from the state and then updated my configuration to reflect the new bucket name, ensuring a clean deployment.

Automated content updates: Initially, changes to “index.html” were not being detected by Terraform. I discovered that Terraform doesn't automatically track file content changes unless configured to do so. The solution was to manage the file as an aws_s3_bucket_object resource and use the “etag” attribute to trigger an update, ensuring my website always reflects the latest content.


CI/CD with GitHub Actions

Established a reliable CI/CD workflow: I defined a clear, repeatable process for my development cycle. I would make changes locally, use “terraform plan” to preview the changes, and then commit and push to GitHub. This triggered a GitHub Actions pipeline that performed the same plan and apply steps in an automated fashion, ensuring consistency and preventing manual errors.

Handled caching and propagation delays: To ensure website updates were visible immediately, I integrated a CloudFront invalidation step into my GitHub Actions pipeline. This automatically clears the cache whenever the website content changes, guaranteeing that users see the latest version of the site without delay.

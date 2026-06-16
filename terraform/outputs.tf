# =============================================================
# Cloud Security Lab - Outputs
# =============================================================

output "vulnerable_bucket_name" {
  value = aws_s3_bucket.vulnerable_bucket.id
}

output "low_priv_user_name" {
  value = aws_iam_user.low_priv_user.name
}

output "lab_summary" {
  value = <<-EOT
    ╔══════════════════════════════════════════╗
    ║       Cloud Security Lab CTF - Hazır!    ║
    ╠══════════════════════════════════════════╣
    ║  Aşama 1 -> S3 Nesne Deposu Analizi      ║
    ║  Aşama 2 -> IAM Yetki Yükseltme Geçişi   ║
    ║  Aşama 3 -> Konteyner İzolasyon Bypass   ║
    ╚══════════════════════════════════════════╝
  EOT
}

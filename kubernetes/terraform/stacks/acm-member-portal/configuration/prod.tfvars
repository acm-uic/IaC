deployment_env = "prod"

redirect_uris = [
  "https://portal.acmuic.org/api/auth/callback/microsoft",
]

logout_uris = [
  "https://portal.acmuic.org",
]

kubernetes_namespace = "acm-portal"

additional_owner_ids = [
  "21ec2c63-534d-4cfb-bc43-83773ce40e54", # terraform-svc
  "920bf583-cb9b-4365-a61e-bb33988c5484"  # clee231
]

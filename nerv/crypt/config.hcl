vault {
  address = "https://vault.acmuic.org"

  ssl {
    enabled = true
    verify = false
  }
    
}

template {
  source = "./template.yml"
  destination = "./temp.yml"
  error_on_missing_key = true

  exec {
    command = "sops encrypt --output enc.yml temp.yml" 
  }
}

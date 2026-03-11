stack {
  name        = "eu"
  description = "eu"
  id          = "5e3cba58-0f42-423a-9ab1-5c82631206ac"
  tags        = ["tlpsk", "eu"]
}

terramate {
  config {
    run {
      env {
        TF_VAR_vcp_api_key = tm_file("~/.keys/venafi/tlspc/demons-eu/admin-api-key.txt")
      }
    }
  }
}
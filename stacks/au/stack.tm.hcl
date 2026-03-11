stack {
  name        = "au"
  description = "au"
  id          = "1e45dfa1-89ec-461c-ad32-9a8e9e72a1f8"
  tags        = ["au", "tlspk"]
}

terramate {
  config {
    run {
      env {
        TF_VAR_vcp_api_key = tm_file("~/.keys/venafi/tlspc/demons-au/admin-api-key.txt")
      }
    }
  }
}

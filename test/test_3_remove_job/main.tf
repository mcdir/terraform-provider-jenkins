provider "jenkins" {
  server_url = "http://localhost:8080/"
  ca_cert    = false
  username   = "admin"
  password   = "admin"
}

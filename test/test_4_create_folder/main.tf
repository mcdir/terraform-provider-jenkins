provider "jenkins" {
  server_url = "http://localhost:8080/"
  ca_cert    = false
  username   = "admin"
  password   = "admin"
}

resource "jenkins_folder" "things" {
  name = "things"
}

resource "jenkins_folder" "my_folder" {
  name = "things/my_folder"

  depends_on = [
    "jenkins_folder.things",
  ]
}

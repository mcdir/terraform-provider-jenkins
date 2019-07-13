provider "jenkins" {
  server_url = "http://localhost:8080/"
  ca_cert    = false
  username   = "admin"
  password   = "admin"
}

resource "jenkins_job" "my_job" {
  name         = "Example 2"                                            # New name for the job
  display_name = "Example Job Display Name"
  description  = "The job is created from a file on disk via Terraform"
  disabled     = true

  parameters = {
    KeepDependencies               = true
    GitLabConnection               = "http://gitlab.example.com/my-second-project/project.git"
    TriggerOnPush                  = true
    TriggerOnMergeRequest          = true
    TriggerOpenMergeRequestOnPush  = "never"
    TriggerOnNoteRequest           = true
    NoteRegex                      = "Jenkins please retry a build"
    CISkip                         = true
    SkipWorkInProgressMergeRequest = true
    SetBuildDescription            = true
    BranchFilterType               = "All"
    SecretToken                    = "{AQAAABAAAAAQwt1GRY9q3ZVQO3gt3epgTsk5dMX+jSacfO7NOzm5Eyk=}"
    UserRemoteConfig               = "https://gitlab.example.com/confmgmt/user-web.git"
    BranchSpec                     = "*/master"
    GenerateSubmoduleConfiguration = false
  }

  template = "file://./job_template.xml"
}

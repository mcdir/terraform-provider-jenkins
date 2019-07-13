# Terraform Jenkins 

[![CircleCI](https://circleci.com/gh/dihedron/terraform-provider-jenkins.svg?style=svg)](https://circleci.com/gh/dihedron/terraform-provider-jenkins)

## Installation

You can easily install the latest version with the following :

```
#master
go get -u github.com/dihedron/terraform-provider-jenkins
# fork
go get -u -v github.com/charlieegan3/terraform-provider-jenkins
#
go get github.com/hashicorp/terraform
#
go list github.com
#
/home/mcdir/go/src/github.com/terraform-provider-jenkins/bin
#
cd ~/go/src/github.com
git clone https://github.com/charlieegan3/terraform-provider-jenkins
make
```

Then add the plugin to your local `.terraformrc` :

```
cat >> ~/.terraformrc <<EOF
providers {
    jenkins = "${GOPATH}/bin/terraform-provider-jenkins"
}
EOF
```


#!/usr/bin/env bash

set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function run_test () {
  name=$1
  expected=$2

  echo $(pwd)
  cp ../../bin/terraform-provider-jenkins .

  terraform init > init.output
  terraform plan -state ../terraform.tfstate > plan.output
  terraform apply -auto-approve -state ../terraform.tfstate > apply.output

  if grep -q "$expected" apply.output; then
    printf "${GREEN}Passed:${NC} $name\n"
  else
    cat init.output
    cat plan.output
    cat apply.output

    printf "${GREEN}Failed:${NC} $name - missing $expected in output\n"
  fi
}

# Run a jenkins instance to test against
docker kill terraform-jenkins-test > /dev/null 2>&1 || true
JENKINS_CONTAINER=$(docker run --rm --name terraform-jenkins-test -d -p 50000:50000 -p 8080:8080 tarmak-jenkins:latest)
echo "Waiting for Jenkins container"
until (curl --silent http://localhost:8080 | grep -o "Welcome to Jenkins" > /dev/null); do
  sleep 1
done

if [ -z $TESTCASE ]; then
  echo "No TESTCASE specified, running all testcases"

  find . -maxdepth 1 -type d | grep test_ | sort | while read test_case_folder; do
    name=$(cat $test_case_folder/test_case_name)
    expected=$(cat $test_case_folder/expected_output)

    (cd $test_case_folder && run_test "$name" "$expected")
  done
else
  echo "Running testcase: $TESTCASE"

  name=$(cat $TESTCASE/test_case_name)
  expected=$(cat $TESTCASE/expected_output)

  (cd $TESTCASE && run_test "$name" "$expected")
fi

# Clean up
docker rm -f $JENKINS_CONTAINER > /dev/null 2>&1 || true

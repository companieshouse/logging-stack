# logging-stack-configuration

## Introduction

These scripts are used to configure the logging stack

## Roles

- Kibana - Configure Kibana using the API

### Kibana Role

Makes requests against the Kibana API to manage an environments space and its index patterns.
If an environment has not been defined within this role it will be removed from the logging-stack.

## Running

The playbooks are run within Concourse.

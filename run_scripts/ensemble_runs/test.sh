#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 [arg1] [arg2]" >&2
  exit 1
}

# Display help if no arguments are provided or if the user specifies --help
if [[ $# -eq 0 || "$1" == "--help" ]]; then
  usage
fi

# Display positional arguments
echo "Positional arguments: $@"

# Your script logic goes here


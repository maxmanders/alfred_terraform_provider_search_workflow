#!/bin/bash

query=${1}

base_url="https://www.terraform.io/docs/providers/q_provider/q_type/q_thing.html"

#
# Split search term into provider and resource
#
q_provider=$(echo ${query} | cut -d"_" -f1)
q_thing=$(echo ${query} | cut -d"_" -f2-)
q_type="r"

#
# Replace placeholders with search term
#
url=$(echo ${base_url} \
| sed "s/q_provider/${q_provider}/g" \
| sed "s/q_thing/${q_thing}/g" \
| sed "s/q_type/r/g")

#
# Check if a resource exists, otherwise try a data type
#
status_code=$(curl -s -o /dev/null -w "%{http_code}" ${url})

if [ "${status_code}" -eq "404" ]; then
  #
  # We can't find a resource, try a data source
  #
  url=$(echo ${base_url} \
  | sed "s/q_provider/${q_provider}/g" \
  | sed "s/q_thing/${q_thing}/g" \
  | sed "s/q_type/d/g")

  retry_status_code=$(curl -s -o /dev/null -w "%{http_code}" ${url})
  if [ "${status_code}" -eq "404" ]; then
    #
    # We can't find a resource or data source, so fail
    #
    exit
  else
    echo ${url}
  fi
else
  echo -n ${url}
fi

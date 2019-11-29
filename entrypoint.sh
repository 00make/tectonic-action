#!/bin/sh -l

set -e

echo "Compiling $1"
tectonic $1

OUTPUT_PDF="${1%.*}.pdf"

echo '{
  "message": "'"update $OUTPUT_PDF"'",
  "committer": {
    "name": "Tectonic Action",
    "email": "tectonic-action@github.com"
  },
  "content": "'"$(base64 -w 0 $OUTPUT_PDF)"'",
  "sha": '$(curl -X GET -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/${GITHUB_REPOSITORY}/contents/$OUTPUT_PDF | jq .sha)'
}' >> payload.json

STATUSCODE=$(curl --silent --output /dev/stderr --write-out "%{http_code}" \
            -i -X PUT -H "Authorization: token $GITHUB_TOKEN" -d @payload.json \
            https://api.github.com/repos/${GITHUB_REPOSITORY}/contents/$OUTPUT_PDF)

if [ $((STATUSCODE/100)) -ne 2 ]; then
  echo "Github's API returned $STATUSCODE"
  exit 22;
fi

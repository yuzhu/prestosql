#!/bin/bash

set -euo pipefail

AWS_S3_BUCKET=presto-ci-test

# Create a dedicated profile for this action to avoid conflicts with past/future actions.
aws configure --profile upload_artifacts <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${S3_BUCKET_REGION}
text
EOF

function cleanup {
    # Clear out credentials after we're done.
    # We need to re-run `aws configure` with bogus input instead of
    # deleting ~/.aws in case there are other credentials living there.
    # https://forums.aws.amazon.com/thread.jspa?threadID=148833
    aws configure --profile upload_artifacts <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
}

trap cleanup EXIT

function s3_sync {
    aws s3 sync "$1" "s3://${S3_BUCKET}/${SHA}/" \
        --profile upload_artifacts \
        --no-progress \
        --endpoint-url ${S3_BUCKET_ENDPOINT}
}

s3_sync **/target/*-reports
s3_sync **/target/*-reports/*
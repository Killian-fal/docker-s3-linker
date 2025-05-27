#!/bin/bash

BUCKETS_DIR="/mnt/buckets"

if [ ! -d "$BUCKETS_DIR" ]; then
  echo "Error : $BUCKETS_DIR not found"
  echo "Check your docker-compose.yml"
  exit 1
fi

sync_folder() {
  local folder_name="$1"
  local folder_path="$BUCKETS_DIR/$folder_name"
  local s3_bucket_name="$folder_name" # folder_name == bucket name

  while true; do

    if [ "${2,,}" = "true" ]; then
      aws_sync "s3://$s3_bucket_name/" "$folder_path/" 
    else
      aws_sync "$folder_path/" "s3://$s3_bucket_name/"
    fi

    if [ $? -eq 0 ]; then
      echo "[$folder_path] Success for '$folder_name'"
    else
      echo "[$folder_path] Fail for '$folder_name'. Return code: $?"
    fi
    sleep $DELAY
  done
}

aws_sync() {
  local source="$1"
  local destination="$2"

  echo "[$folder_path] Synchronize '$folder_path' from 's3://$s3_bucket_name/'"

  if [ "${DEBUG,,}" = "true" ]; then
    echo "[DEBUG - $folder_path] AWS command : aws s3 sync \"s3://$s3_bucket_name/\" \"$folder_path/\" $SYNC_ARGUMENTS"
  fi

  aws s3 sync "$source" "$destination" $SYNC_ARGUMENTS
}

IFS=';' read -ra FROM_S3 <<< "$LINK_FROM_S3_BUCKET"
IFS=';' read -ra TO_S3 <<< "$LINK_TO_S3_BUCKET"
is_in_list() {
  local item="$1"
  shift
  for val in "$@"; do
    if [ "$item" = "$val" ]; then
      return 0
    fi
  done
  return 1
}

cd "$BUCKETS_DIR"

for dir in */; do
  folder_name=${dir%/}

  echo "Start the '$folder_name' folder synchronization process"

  if is_in_list "$folder_name" "${FROM_S3[@]}"; then
    sync_folder "$folder_name" "true" &
  elif is_in_list "$folder_name" "${TO_S3[@]}"; then
    sync_folder "$folder_name" "false" &
  else
    echo "ERROR: '$folder_name' is not configured in LINK_FROM_S3_BUCKET or LINK_TO_S3_BUCKET — skipping synchronization."
  fi

done

wait
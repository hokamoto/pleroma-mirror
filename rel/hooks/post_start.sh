set +e

echo "Starting pleroma."
echo -n "Waiting for node"

while true; do
  nodetool ping > /dev/null
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 0 ]; then
    echo " up!"
    break
  fi
  echo -n "."
done

set -e
bin/pleroma migrate

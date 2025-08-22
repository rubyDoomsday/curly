CURLY_HOME=$HOME/_my_projects/curly
REQUEST_CONFIG=$CURLY_HOME/_request_config.json
RESPONSE=$CURLY_HOME/_response.json

# ensure environment on source
cd $CURLY_HOME
mkdir -p history/requests history/responses
touch $REQUEST_CONFIG
touch $RESPONSE

# Initialize default request config if it doesn't exist
if [ ! -s $REQUEST_CONFIG ]; then
  cat > $REQUEST_CONFIG << EOF
{
  "host": "http://localhost:3000",
  "path": "/",
  "payload": {},
  "headers": []
}
EOF
fi

clear
cat .manpage

# Load current request config
loadRequestConfig() {
  CURLY_HOST=$(jq -r '.host' $REQUEST_CONFIG 2>/dev/null || echo "http://localhost:3000")
  CURLY_PATH=$(jq -r '.path' $REQUEST_CONFIG 2>/dev/null || echo "/")
  CURLY_PAYLOAD=$(jq -c '.payload' $REQUEST_CONFIG 2>/dev/null || echo "{}")
  CURLY_HEADERS=$(jq -r '.headers[]?' $REQUEST_CONFIG 2>/dev/null || echo "")
}

# Load initial config
loadRequestConfig

alias curlyHelp="cat .manpage"
alias setRequest="vim $REQUEST_CONFIG"
alias showLast="vim $RESPONSE -c 'vsplit $REQUEST_CONFIG'"
alias showLastNoPayload="vim -O $REQUEST_CONFIG $RESPONSE"
alias reload="reloadConfig"

# inspects current or a saved request
showRequest() {
  if [ -z "$1" ]
  then
    echo "\nCurrent Request Configuration:"
    cat $REQUEST_CONFIG | jq '.'
  else
    # Check if argument starts with history/requests/
    if [[ "$1" != history/requests/* ]]; then
      echo "ERROR: Argument must start with 'history/requests/'"
      echo "Usage: showRequest history/requests/YYYY-MM-DD/request_name.json"
      return 1
    fi
    
    # Remove the history/requests/ prefix
    FILENAME="${1#history/requests/}"
    
    # Remove .json extension if present
    FILENAME="${FILENAME%.json}"
    
    # Check if the request configuration exists
    if [ ! -f "history/requests/$FILENAME.json" ]; then
      echo "ERROR: Request configuration not found: history/requests/$FILENAME.json"
      return 1
    fi
    
    echo "\nSaved Request: $FILENAME"
    echo "\nConfiguration:"
    cat "history/requests/$FILENAME.json" | jq '.'
    
    # Show response if it exists and has content
    if [ -s "history/responses/$FILENAME.json" ]; then
      echo "\nResponse Preview:"
      cat "history/responses/$FILENAME.json" | jq '.' | head -20
      echo "..."
    fi
  fi
}

# saves request
saveRequest() {
  if [ -z "$1" ]
  then
    # Auto-generate filename based on current request
    today=`date '+%Y-%m-%d'`
    mkdir -p history/requests/$today
    mkdir -p history/responses/$today
    
    host=$(echo $CURLY_HOST | sed -e 's/http[s]*\:\/.*\///g')
    FILENAME="$CURLY_ACTION--$host--${CURLY_PATH//\//.}"
    
    # Save the current request configuration
    cp "$REQUEST_CONFIG" "history/requests/$today/$FILENAME.json"
    
    # Save the response if it exists and has content
    if [ -s "$RESPONSE" ]; then
      cp "$RESPONSE" "history/responses/$today/$FILENAME.json"
    else
      echo "{}" > "history/responses/$today/$FILENAME.json"
    fi
    
    echo "\nSaved Request: $today/$FILENAME"
    echo "  Config: history/requests/$today/$FILENAME.json"
    echo "  Response: history/responses/$today/$FILENAME.json"
  else
    # Handle explicit filename argument
    # Check if argument starts with history/requests/
    if [[ "$1" != history/requests/* ]]; then
      echo "ERROR: Argument must start with 'history/requests/'"
      echo "Usage: saveRequest history/requests/YYYY-MM-DD/request_name.json"
      return 1
    fi
    
    # Remove the history/requests/ prefix
    FILENAME="${1#history/requests/}"
    
    # Remove .json extension if present
    FILENAME="${FILENAME%.json}"
    
    # Extract date directory from filename
    date_dir=$(echo "$FILENAME" | cut -d'/' -f1)
    
    # Create directories
    mkdir -p "history/requests/$date_dir"
    mkdir -p "history/responses/$date_dir"
    
    # Save the current request configuration
    cp "$REQUEST_CONFIG" "history/requests/$FILENAME.json"
    
    # Save the response if it exists and has content
    if [ -s "$RESPONSE" ]; then
      cp "$RESPONSE" "history/responses/$FILENAME.json"
    else
      echo "{}" > "history/responses/$FILENAME.json"
    fi
    
    echo "\nSaved Request: $FILENAME"
    echo "  Config: history/requests/$FILENAME.json"
    echo "  Response: history/responses/$FILENAME.json"
  fi
}

# load request
loadRequest() {
  # Check if argument starts with history/requests/
  if [[ "$1" != history/requests/* ]]; then
    echo "ERROR: Argument must start with 'history/requests/'"
    echo "Usage: loadRequest history/requests/YYYY-MM-DD/request_name.json"
    return 1
  fi
  
  # Remove the history/requests/ prefix
  FILENAME="${1#history/requests/}"
  
  # Remove .json extension if present
  FILENAME="${FILENAME%.json}"
  
  # Check if the request configuration exists
  if [ ! -f "history/requests/$FILENAME.json" ]; then
    echo "ERROR: Request configuration not found: history/requests/$FILENAME.json"
    return 1
  fi
  
  # Load the request configuration
  cp "history/requests/$FILENAME.json" "$REQUEST_CONFIG"
  
  # Load the response if it exists
  if [ -f "history/responses/$FILENAME.json" ]; then
    cp "history/responses/$FILENAME.json" "$RESPONSE"
  else
    echo "{}" > "$RESPONSE"
  fi
  
  # Reload the configuration
  loadRequestConfig
  
  echo "\nLOADED: $FILENAME"
  showRequest
}

deleteRequest() {
  FILENAME="${1#history/}"
  rm history/requests/$FILENAME'.json'
  rm payloads/$FILENAME'.json'
  rm responses/$FILENAME'.json'
  rm paths/$FILENAME'.string'
  rm hosts/$FILENAME'.string'
  echo "\nDeleted Request: $FILENAME"
}

eraseDay() {
  DAY="${1#history/}"
  
  # Check if the date directory exists
  if [ ! -d "history/requests/$DAY" ]; then
    echo "ERROR: Date directory not found: history/requests/$DAY"
    return 1
  fi
  
  # Remove the entire date directory for both requests and responses
  rm -rf "history/requests/$DAY"
  rm -rf "history/responses/$DAY"
  
  echo "\nErased: $DAY"
  echo "  Removed: history/requests/$DAY"
  echo "  Removed: history/responses/$DAY"
}

# clears current request
clearRequest() {
  cat > $REQUEST_CONFIG << EOF
{
  "host": "http://localhost:3000",
  "path": "/",
  "payload": {},
  "headers": []
}
EOF
  rm $RESPONSE && touch $RESPONSE
  loadRequestConfig
  echo "\nCleared Request Params"
  showRequest
}

# completely wipes out cache files
curlyReset() {
  echo -n "Are you sure you want to clear all history and settings (y/n)?"
  read answer
  if echo "$answer" | grep -iq "^y"; then
    # clear current containers
    cat > $REQUEST_CONFIG << EOF
{
  "host": "http://localhost:3000",
  "path": "/",
  "payload": {},
  "headers": [
    "Accept: application/json",
    "Authorization: Basic aG9NRmlyeHJQWjFUNjBRcjpRdFNYOHRVdkdDbVVYZ0p6c1JEQ0dheVpOMGNPM2JSMw=="
  ]
}
EOF
    rm $RESPONSE && touch $RESPONSE
    # clear history
    /bin/rm -f -R history/requests/*
    /bin/rm -f -R history/responses/*
    # reset defaults
    loadRequestConfig
    echo "\nReset Curly"
    showRequest
  else
    echo "Canceled"
  fi
}

loadHeaders() {
  headers=""
  jq -r '.headers[]?' $REQUEST_CONFIG 2>/dev/null | while read line ; do
    if [ -n "$line" ]; then
      headers=("${headers[@]} -H '$line'")
    fi
  done
  echo $headers
}

loadFormData() {
  data=""
  # Convert JSON payload to form data if it exists and is not empty
  if [ -n "$CURLY_PAYLOAD" ] && [ "$CURLY_PAYLOAD" != "{}" ]; then
    echo "$CURLY_PAYLOAD" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' 2>/dev/null | while read line ; do
      if [ -n "$line" ]; then
        data=("${data[@]} --data-urlencode '$line'")
      fi
    done
  fi
  echo $data
}

# makes a post call with headers and payload to the supplied url
post() {
  CURLY_ACTION="POST"
  headers=`loadHeaders`

  post_path=${1:-$CURLY_PATH}
  CURLY_PATH=$post_path
  POST_URL=$CURLY_HOST$CURLY_PATH

  # Create temporary payload file from JSON config
  temp_payload=$(mktemp)
  echo "$CURLY_PAYLOAD" > "$temp_payload"

  cmd="curl -d '@$temp_payload' $headers -X POST '$POST_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLast
  saveRequest
  
  # Clean up temp file
  rm -f "$temp_payload"
}

# makes a get call with headers to the supplied url
get() {
  CURLY_ACTION="GET"
  headers=`loadHeaders`

  get_path=${1:-$CURLY_PATH}
  CURLY_PATH=$get_path
  GET_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl $headers -X GET '$GET_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLastNoPayload
  saveRequest
}

# makes a get call with headers to the supplied url
openStream() {
  CURLY_ACTION="STREAM"
  headers=`loadHeaders`

  get_path=${1:-$CURLY_PATH}
  CURLY_PATH=$get_path
  GET_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl $headers -X GET '$GET_URL' --http1.1"

  echo "\n"$cmd"\n"
  eval $cmd

  saveRequest
}

# makes a put call with headers and payload to the supplied url
put() {
  CURLY_ACTION="PUT"
  headers=`loadHeaders`

  put_path=${1:-$CURLY_PATH}
  CURLY_PATH=$put_path
  PUT_URL=$CURLY_HOST$CURLY_PATH

  # Create temporary payload file from JSON config
  temp_payload=$(mktemp)
  echo "$CURLY_PAYLOAD" > "$temp_payload"

  cmd="curl -d '@$temp_payload' $headers -X PUT '$PUT_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLast
  saveRequest
  
  # Clean up temp file
  rm -f "$temp_payload"
}

# makes a patch call with headers and payload to the supplied url
patch() {
  CURLY_ACTION="PATCH"
  headers=`loadHeaders`

  patch_path=${1:-$CURLY_PATH}
  CURLY_PATH=$patch_path
  PATCH_URL=$CURLY_HOST$CURLY_PATH

  # Create temporary payload file from JSON config
  temp_payload=$(mktemp)
  echo "$CURLY_PAYLOAD" > "$temp_payload"

  cmd="curl -d '@$temp_payload' $headers -X PATCH '$PATCH_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLast
  saveRequest
  
  # Clean up temp file
  rm -f "$temp_payload"
}

# makes a delete call with headers and payload to the supplied url
delete() {
  CURLY_ACTION="DELETE"
  headers=`loadHeaders`

  delete_path=${1:-$CURLY_PATH}
  CURLY_PATH=$delete_path
  DELETE_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl $headers -X DELETE '$DELETE_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLastNoPayload
  saveRequest
}

postForm() {
  CURLY_ACTION="POST"
  headers=`loadHeaders`

  data=`loadFormData`

  post_path=${1:-$CURLY_PATH}
  CURLY_PATH=$post_path
  POST_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl $data $headers -X POST '$POST_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > $RESPONSE && showLast
  saveRequest
}

# Reload request config after changes
reloadConfig() {
  loadRequestConfig
  echo "Request configuration reloaded"
  showRequest
}

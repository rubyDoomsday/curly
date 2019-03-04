# ensure environement on source
mkdir -p headers history hosts paths payloads responses
touch _headers.list
touch _payload.json
clear
cat .manpage

PAYLOAD=@_payload.json
host_default="http://localhost:3000"
path_default="/"
CURLY_HOST=$host_default
CURLY_PATH=$path_default
setHost() { CURLY_HOST=$1 }
setPath() { CURLY_PATH=$1 }

alias curlyHelp="cat .manpage"
alias setPayload="vim _payload.json"
alias setHeaders="vim _headers.list"
alias showLast="vim _response.json -c 'vsplit _payload.json' -c 'split _headers.list'"
alias showLastNoPayload="vim -O _headers.list _response.json"

# inspects current or a saved request
showRequest() {
  if [ -z "$1" ]
  then
    echo "\nHOST: $CURLY_HOST"
    echo "PATH: $CURLY_PATH"
    echo "HEADERS:"
    cat _headers.list

    if [ -s _payload.json ]
    then
      echo "\nPAYLOAD:"
      cat _payload.json
    else
      echo ""
    fi
  else
    FILENAME="${1#history/}"
    echo "\nHOST:"
    cat hosts/$FILENAME'.string'
    echo "PATH:"
    cat paths/$FILENAME'.string'

    echo "HEADERS:"
    cat headers/$FILENAME'.list'

    if [ -s payloads/$FILENAME'.json' ]
    then
      echo "\nPAYLOAD:"
      cat payloads/$FILENAME'.json'
    else
      echo ""
    fi
  fi
}

# saves request
saveRequest() {
  today=`date '+%Y-%m-%d'`
  mkdir -p history/$today
  mkdir -p headers/$today
  mkdir -p payloads/$today
  mkdir -p paths/$today
  mkdir -p hosts/$today
  mkdir -p responses/$today

  if [ -z "$1" ]
  then
    host=$(echo $CURLY_HOST | sed -e 's/http[s]*\:\/.*\///g')
    FILENAME="$CURLY_ACTION--$host--${CURLY_PATH//\//.}"
  else
    FILENAME=$1
  fi
  touch history/$today/$FILENAME
  cp _headers.list headers/$today/$FILENAME'.list'
  cp _payload.json payloads/$today/$FILENAME'.json'
  cp _response.json responses/$today/$FILENAME'.json'
  echo $CURLY_HOST > hosts/$today/$FILENAME'.string'
  echo $CURLY_PATH > paths/$today/$FILENAME'.string'
  echo "\nSaved Request: $today/$FILENAME"
}

# load request
loadRequest() {
  FILENAME="${1#history/}"
  cp headers/$FILENAME'.list' _headers.list
  cp payloads/$FILENAME'.json' _payload.json
  cp responses/$FILENAME'.json' _response.json
  CURLY_HOST=$(cat hosts/$FILENAME'.string')
  CURLY_PATH=$(cat paths/$FILENAME'.string')
  echo "\nLOADED: $FILENAME"
  showRequest
}

deleteRequest() {
  FILENAME="${1#history/}"
  rm history/$FILENAME
  rm headers/$FILENAME'.list'
  rm payloads/$FILENAME'.json'
  rm responses/$FILENAME'.json'
  rm paths/$FILENAME'.string'
  rm hosts/$FILENAME'.string'
  echo "\nDeleted Request: $FILENAME"
}

eraseDay() {
  DAY="${1#history/}"
  rm -r -f history/$DAY
  rm -r -f headers/$DAY
  rm -r -f payloads/$DAY
  rm -r -f responses/$DAY
  rm -r -f paths/$DAY
  rm -r -f hosts/$DAY
  echo "\nErased: $DAY"
}

# clears current request
clearRequest() {
  cp .default_headers.list _headers.list
  rm _payload.json && touch _payload.json
  rm _response.json && touch _response.json
  CURLY_HOST=$host_default
  CURLY_PATH=$path_default
  echo "\nCleared Request Params"
  showRequest
}

# completely wipes out cache files
curlyReset() {
  echo -n "Are you sure you want to clear all history and settings (y/n)?"
  read answer
  if echo "$answer" | grep -iq "^y"; then
    # clear current containers
    cp .default_headers.list _headers.list
    rm _payload.json && touch _payload.json
    rm _response.json && touch _response.json
    # clear history
    /bin/rm -f -R headers/*
    /bin/rm -f -R history/*
    /bin/rm -R hosts/*
    /bin/rm -R paths/*
    /bin/rm -R payloads/*
    /bin/rm -R responses/*
    # reset defaults
    CURLY_HOST=$host_default
    CURLY_PATH=$path_default
    echo "\nReset RubyPost"
    showRequest
  else
    echo "Canceled"
  fi
}

loadHeaders() {
  headers=""
  while read line ; do
    headers=("${headers[@]} -H '$line'")
  done < _headers.list
  echo $headers
}

# makes a post call with headers and payload to the supplied url
post() {
  CURLY_ACTION="POST"
  headers=`loadHeaders`

  post_path=${1:-$CURLY_PATH}
  CURLY_PATH=$post_path
  POST_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl -d $PAYLOAD $headers -X POST '$POST_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > _response.json && showLast
  saveRequest
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
  eval $cmd | jq . > _response.json && showLastNoPayload
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

  cmd="curl -d $PAYLOAD $headers -X PUT '$PUT_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > _response.json && showLast
  saveRequest
}

# makes a put call with headers and payload to the supplied url
patch() {
  CURLY_ACTION="PUT"
  headers=`loadHeaders`

  patch_path=${1:-$CURLY_PATH}
  CURLY_PATH=$patch_path
  PATCH_URL=$CURLY_HOST$CURLY_PATH

  cmd="curl -d $PAYLOAD $headers -X PATCH '$PATCH_URL'"

  echo "\n"$cmd"\n"
  eval $cmd | jq . > _response.json && showLast
  saveRequest
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
  eval $cmd | jq . > _response.json && showLastNoPayload
  saveRequest
}

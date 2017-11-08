PAYLOAD=@_payload.json
host_default="http://localhost:3000"
path_default="/"
RP_HOST=$host_default
RP_PATH=$path_default

alias rpHelp="cat .manpage"

alias showHistory="ls -1 history"
alias showPayload="cat _payload.json"
alias showHeaders="cat _headers.list"
alias showLast="vim _response.json -c 'vsplit _payload.json' -c 'split _headers.list'"

alias setPayload="vim _payload.json"
alias setHeaders="vim _headers.list"

setHost() {
  RP_HOST=$1
}

setPath() {
  RP_PATH=$1
}

# inspects current or a saved request
showRequest() {
  if [ -z "$1" ]
  then
    echo "\nHOST: $RP_HOST"
    echo "PATH: $RP_PATH"
    echo "HEADERS:"
    cat _headers.list
    echo "\nPAYLOAD:"
    cat _payload.json
  else
    FILENAME="${1#history/}"
    echo "\nHOST:" cat hosts/$FILENAME'.string'
    echo "PATH:" cat paths/$FILENAME'.string'
    echo "HEADERS:"
    cat headers/$FILENAME'.list'
    echo "\nPAYLOAD:"
    cat payloads/$FILENAME'.json'
  fi
}

# saves request
saveRequest() {
  if [ -z "$1" ]
  then
    FILENAME="$RP_ACTION${RP_PATH//\//-}-"`date '+%Y-%m-%d-%H-%M'`
  else
    FILENAME=$1
  fi
  touch history/$FILENAME
  cp _headers.list headers/$FILENAME'.list'
  cp _payload.json payloads/$FILENAME'.json'
  cp _response.json responses/$FILENAME'.json'
  echo $RP_HOST > hosts/$FILENAME'.string'
  echo $RP_PATH > paths/$FILENAME'.string'
  echo "\nSaved Request: $FILENAME"
}

# load request
loadRequest() {
  FILENAME="${1#history/}"
  cp headers/$FILENAME'.list' _headers.list
  cp payloads/$FILENAME'.json' _payload.json
  cp responses/$FILENAME'.json' _response.json
  RP_HOST=$(cat hosts/$FILENAME'.string')
  RP_PATH=$(cat paths/$FILENAME'.string')
  echo "\nLOADED: $FILENAME"
  showRequest
}

deleteRequest() {
  FILENAME="${1#history/}"
  rm headers/$FILENAME'.list'
  rm payloads/$FILENAME'.json'
  rm responses/$FILENAME'.json'
  rm paths/$FILENAME'.string'
  rm hosts/$FILENAME'.string'
  echo "\nDeleted Request: $FILENAME"
}

# clears current request
clearRequest() {
  cp .default_headers.list _headers.list
  rm _payload.json && touch _payload.json
  rm _response.json && touch _response.json
  RP_HOST=$host_default
  RP_PATH=$path_default
  echo "\nCleared Request Params"
  showRequest
}

# completely wipes out cache files
rpReset() {
  echo -n "Are you sure you want to clear all history and settings (y/n)?"
  read answer
  if echo "$answer" | grep -iq "^y"; then
    # clear current containers
    cp .default_headers.list _headers.list
    rm _payload.json && touch _payload.json
    rm _response.json && touch _response.json
    # clear history
    rm headers/*.*
    rm history/*
    rm hosts/*.*
    rm paths/*.*
    rm payloads/*.*
    rm responses/*.*
    # reset defaults
    RP_HOST=$host_default
    RP_PATH=$path_default
    echo "\nReset RubyPost"
    showRequest
  else
    echo "Canceled"
  fi
}

# makes a post call with headers and payload to the supplied url
post() {
  RP_ACTION="POST"
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  POST_PATH=${1:-$RP_PATH}
  RP_PATH=$POST_PATH
  POST_URL=$RP_HOST$RP_PATH

  curl -v -d $PAYLOAD "${headers[@]}" -X POST $POST_URL | json_pp > _response.json &&
    vim _response.json -c 'vsplit _payload.json' -c 'split _headers.list'

  saveRequest
}

# makes a get call with headers to the supplied url
get() {
  RP_ACTION="GET"
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  GET_PATH=${1:-$RP_PATH}
  RP_PATH=$GET_PATH
  GET_URL=$RP_HOST$RP_PATH

  curl -v "${headers[@]}" -X GET $GET_URL | json_pp > _response.json &&
    vim -O _headers.list _response.json

  saveRequest
}

# makes a get call with headers to the supplied url
openStream() {
  RP_ACTION="STREAM"
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  GET_PATH=${1:-$RP_PATH}
  RP_PATH=$GET_PATH
  GET_URL=$RP_HOST$RP_PATH

  curl -v "${headers[@]}" -X GET $GET_URL

  saveRequest
}

# makes a put call with headers and payload to the supplied url
put() {
  RP_ACTION="PUT"
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  PUT_PATH=${1:-$RP_PATH}
  RP_PATH=$PUT_PATH
  PUT_URL=$RP_HOST$RP_PATH

  curl -v -d $PAYLOAD "${headers[@]}" -X PUT $PUT_URL | json_pp > _response.json &&
    vim _response.json -c 'vsplit _payload.json' -c 'split _headers.list'

  saveRequest
}

# makes a put call with headers and payload to the supplied url
delete() {
  RP_ACTION="DELETE"
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  DELETE_PATH=${1:-$RP_PATH}
  RP_PATH=$DELETE_PATH
  DELETE_URL=$RP_HOST$RP_PATH

  curl -v "${headers[@]}" -X DELETE $DELETE_URL | json_pp > _response.json &&
    vim -O _headers.list _response.json

  saveRequest
}

mkdir -p headers history hosts paths payloads responses
clear
cat .manpage

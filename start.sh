PAYLOAD=@_payload.json
host_default="http://localhost:3000"
path_default="/"
RP_HOST=$host_default
RP_PATH=$path_default

alias rp_help="cat .manpage"
alias rp_history="ls -1 hosts | sed -e 's/\.string$//'"

alias payload="cat _payload.json"
alias set_payload="vim _payload.json"

alias headers="cat _headers.list"
alias set_headers="vim _headers.list"

alias inspect_last="vim _response.json -c 'vsplit _payload.json' -c 'split _headers.list'"

set_host() {
  RP_HOST=$1
}

set_path() {
  RP_PATH=$1
}

# inspects current or a saved request
show_request() {
  if [ -z "$1" ]
  then
    echo "\nHOST: $RP_HOST"
    echo "PATH: $RP_PATH"
    echo "HEADERS:"
    cat _headers.list
    echo "\nPAYLOAD:"
    cat _payload.json
  else
    echo "\nHOST:" cat hosts/$1'.string'
    echo "PATH:" cat paths/$1'.string'
    echo "HEADERS:"
    cat headers/$1'.list'
    echo "\nPAYLOAD:"
    cat payloads/$1'.json'
  fi
}

# saves request
save_request() {
  cp _headers.list headers/$1'.list'
  cp _payload.json payloads/$1'.json'
  cp _response.json responses/$1'.json'
  echo $RP_HOST > hosts/$1'.string'
  echo $RP_PATH > paths/$1'.string'
  echo "\nSaved Request: $1"
}

# load request
load_request() {
  cp headers/$1'.list' _headers.list
  cp payloads/$1'.json' _payload.json
  cp responses/$1'.json' _response.json
  RP_HOST=$(cat hosts/$1'.string')
  RP_PATH=$(cat paths/$1'.string')
  echo "\nLOADED: $1"
  echo "HOST:  $RP_HOST"
  echo "PATH:  $RP_PATH"
  echo "HEADERS:"
  cat _headers.list
  echo "\nPAYLOAD:"
  cat _payload.json
}

delete_request() {
  rm headers/$1'.list'
  rm payloads/$1'.json'
  rm responses/$1'.json'
  rm urls/$1'.string'
  echo "\nDeleted Request: $1"
}

# clears current request
clear_request() {
  rm _headers.list && touch _headers.list
  rm _payload.json && touch _payload.json
  rm _response.json && touch _response.json
  RP_HOST=$host_default
  RP_PATH=$path_default
  echo "\nCleared Request Params"
  echo "HOST: $RP_HOST"
}

# completely wipes out cache files
reset_rubypost() {
  echo -n "Are you sure you want to clear all history and settings (y/n)?"
  read answer
  if echo "$answer" | grep -iq "^y"; then
    rm _headers.list && touch _headers.list
    rm _payload.json && touch _payload.json
    rm _response.json && touch _response.json
    rm headers/*.*
    rm payloads/*.*
    rm responses/*.*
    RP_HOST=$host_default
    RP_PATH=$path_default
    echo "\nReset RubyPost"
    echo "HOST:  $RP_HOST"
  else
    echo "Canceled"
  fi
}

# makes a post call with headers and payload to the supplied url
post() {
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  POST_PATH=${1:-$RP_PATH}
  RP_PATH=$POST_PATH
  POST_URL=$RP_HOST$RP_PATH

  curl -v -d $PAYLOAD "${headers[@]}" -X POST $POST_URL | json_pp > _response.json &&
    vim _response.json -c 'vsplit _payload.json' -c 'split _headers.list'
}

# makes a get call with headers to the supplied url
get() {
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  GET_PATH=${1:-$RP_PATH}
  RP_PATH=$GET_PATH
  GET_URL=$RP_HOST$RP_PATH

  curl -v "${headers[@]}" -X GET $GET_URL | json_pp > _response.json &&
    vim -O _headers.list _response.json
}

# makes a get call with headers to the supplied url
open_stream() {
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  GET_PATH=${1:-$RP_PATH}
  RP_PATH=$GET_PATH
  GET_URL=$RP_HOST$RP_PATH

  curl -v "${headers[@]}" -X GET $GET_URL
}

clear
cat .manpage

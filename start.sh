PAYLOAD=@_payload.json
url_default="http://localhost:3000/"
URL=$url_default

alias history="cat history.list"
alias rubypost_help="cat .manpage"
alias payload="cat _payload.json"
alias headers="cat _headers.list"

show_request() {
  echo "URL:  $URL"
  echo "HEADERS:"
  cat _headers.list
  echo "\nPAYLOAD:"
  cat _payload.json
}
# saves request
save_request() {
  cp _headers.list headers/$1'.list'
  cp _payload.json payloads/$1'.json'
  cp _response.json responses/$1'.json'
  echo $URL >> urls/$1'.string'
  echo $1 >> .history | uniq -u .history >> history.list
  echo "saved $1"
}

# load request
load_request() {
  cp headers/$1'.list' _headers.list
  cp payloads/$1'.json' _payload.json
  cp responses/$1'.json' _response.json
  URL=$(cat urls/$1'.string')
  echo "LOADED: $1"
  echo "URL:  $URL"
  echo "HEADERS:"
  cat _headers.list
  echo "\nPAYLOAD:"
  cat _payload.json
}

# clears current request
clear_request() {
  rm _headers.list && touch _headers.list
  rm _payload.json && touch _payload.json
  rm _response.json && touch _response.json
  URL=$url_default
  echo "cleared request params"
  echo "URL:  $URL"
}

# completely wipes out cache files
reset_rubypost() {
  rm _headers.list && touch _headers.list
  rm _payload.json && touch _payload.json
  rm _response.json && touch _response.json
  rm headers/*.*
  rm payloads/*.*
  rm responses/*.*
  URL=$url_default
  echo "reset RubyPost"
  echo "URL:  $URL"
}

# makes a post call with headers and payload to the supplied url
post() {
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  POST_URL=${1:-$URL}
  URL=$POST_URL

  curl -v -d $PAYLOAD "${headers[@]}" -X POST $POST_URL | json_pp > _response.json &&
    vim _response.json -c 'vsplit _payload.json' -c 'split _headers.list'
}

# makes a get call with headers to the supplied url
get() {
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  GET_URL=${1:-$URL}
  URL=$GET_URL

  curl -v "${headers[@]}" -X GET $GET_URL | json_pp > _response.json &&
    vim -O _headers.list _response.json
}

# makes a get call with headers to the supplied url
open_stream() {
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  GET_URL=${1:-$URL}
  URL=$GET_URL

  curl -v "${headers[@]}" -X GET $GET_URL
}

cat .manpage

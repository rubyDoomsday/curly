# first run 'source ./start.sh'
PAYLOAD=@_payload.json
URL="http://localhost:3000/"
cat .manpage

# save request
save() {
  cp _headers.list headers/$1'.list' &&
    cp _payload.json payloads/$1'.json' &&
    cp _response.json responses/$1'.json' &&
    echo $URL >> urls/$1'.string' &&
    echo $1 >> .history | uniq -u .history >> history.list
}

# load request
load() {
  cp headers/$1'.list' _headers.list &&
    cp payloads/$1'.json' _payload.json &&
    cp responses/$1'.json' _response.json &&
    echo > .history &&
    echo > histor.list &&
    URL=$(cat urls/$1'.string')
}

alias history="cat history.list"

reset() {
  rm headers/*.* &&
    rm payloads/*.* &&
    rm responses/*.* &&
    URL="http://localhost:3000/"
}

# use to post a JSON payload to the url
post() {
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  POST_URL=${1:-$URL}

  curl -v -d $PAYLOAD "${headers[@]}" -X POST $POST_URL | json_pp > _response.json &&
    vim _response.json -c 'vsplit _payload.json' -c 'split _headers.list'
}

get() {
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  GET_URL=${1:-$URL}
  curl -v "${headers[@]}" -X GET $GET_URL | json_pp > _response.json &&
    vim -O _headers.list _response.json
}

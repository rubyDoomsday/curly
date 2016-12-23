# first run 'source ./start.sh'
PAYLOAD=@_payload.json
cat .manpage

# save request
save() {
  cp _headers.list headers/$1'.list' &&
  cp _payload.json payloads/$1'.json' &&
  cp _response.json responses/$1'.json' &&
  echo $1 >> .history | uniq -u .history >> history.list
}

# load request
load() {
  cp headers/$1'.list' _headers.list &&
  cp payloads/$1'.json' _payload.json &&
  cp responses/$1'.json' _response.json
}

alias history="cat history.list"

# uset to post a json payload to the saved $URL
post() {
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  curl -v -d $PAYLOAD "${headers[@]}" -X POST $1 | json_pp >> _response.json && vim _response.json
}

get() {
  headers=""
  while read line ; do
  headers=("${headers[@]}" -H "$line")
  done < _headers.list

  curl -v "${headers[@]}" -X GET $1 | json_pp >> _response.json && vim _response.json
}

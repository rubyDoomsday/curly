# RubyPost v0.1
Designed to be a intuitive wrapper for building curl requests on the fly. Uses vim/vi to display and interact with the RESTful responses. Once loaded `payload`, `headers`, and `URL` can be set once and reused acrosse basic commands.

### To Load RubyPost
execute `source ./start.sh` from the rubypost project directory

### Setting Params
Setting up RESTful calls may require editing one or all of the following settings.

| File             | Use                                 |
| ---------------- | ----------------------------------- |
| `_headers.list`  | List of headers one header per line |
| `_payload.json`  | JSON of payload used for POST calls |
| `_response.json` | Saved response from last call       |
| `URL`            | Optionally saved url string         |

### Making Calls
`post` will build/send a curl request to the saved `URL` if no url is specified

`get` will build/send a curl request to the saved `URL` if no url is specified

`open_stream` will build/send a curl request to open a SSE event stream to the saved `URL` if no url is specified


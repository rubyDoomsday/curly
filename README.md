# Curly v0.1
Designed to be a intuitive stateful wrapper for building, saving and recalling curl requests by providing a series of "helper" commands (not quite full shell commands). This allows for `payload`, `headers` and `response` inspection along with easy request editing via terminal commands and vim editor. Supports GET, POST, PUT and DELETE requests in addition to establishing a long lived SSE connection to a server.

## Requirements
* Vim/Vi
* JQ or JSON_PP

Vim/Vi: requests are piped out to a vim editor for inspection and editing. It is recommended that you have basic understanding of Vim in order to navigate the buffer.
```
> brew install vim
```

JQ: All curl responses make use of JQ parser to pretty print JSON into the vim console. Alternatively you could us JSON_PP in place of all JQ commands within the scripts to effect the same result. Simply swap all `jq .` snippets with `json_pp`
```
> brew install jq
or
> brew install json_pp
```

### To Install Curly
The scripts are meant to be installed to and used from the local repo directory. It is recommended to run this in it's own terminal rather than installing it into `/user/bin` to limit interference with standard bash commands. On first load the helper commands will be displayed to get you started and can be recalled at any time with the `rpHelp` helper.
```
> git clone git@github.com:rubyDoomsday/curly.git curly
> cd curly
> chmod 777 start.sh
> source ./start.sh
```

## Quick Start
Building a request is done by setting the various parts of a request individually to support making multiple and varying calls to the same server. Each request is automatically saved into a datestamp folder and can be recalled using `loadRequest history/[date]/[request]`. Active requests can be edited with various helper commands (Setting Params).
```
> setHost https://myapi.com
> setHeaders
> get /path/to/endpoint
> get '/path/to/endpoint?with=param'
```

### Setting Params
Setting up RESTful calls may require editing one or all of the following settings.

| Setting          | Helper           | Use                                                           |
| ---------------- | ---------------- | ------------------------------------------------------------- |
| headers          | `setHeaders`     | Opens a vim editor to set list of headers one header per line |
| payload          | `setPayload`     | Opens a vim editor to set JSON of payload used for POST calls |
| HOST             | `setHost [host]` | Stores the host domain of the server                          |
| PATH             | `setPath [path]` | Stores the URL path along with any URL params                 |

### Making Calls
To simplify making multiple calls to the same host server, you can optionally provide the path as an argument to any of the following REST commands rather than setting each time with the `setPath` helper.
* `post (path)` will build/send a curl request to the provided host/path
* `get (path)` will build/send a curl request to the provided host/path
* `put (path)` will build/send a curl request to the provided host/path
* `get (path)` will build/send a curl request to the provided host/path
* `openStream (path)` will build/send a curl request to open a SSE event stream to the provided host/path


# Curly v0.2
Designed to be an intuitive stateful wrapper for building, saving and recalling curl requests by providing a series of "helper" commands (not quite full shell commands). This allows for `payload`, `headers` and `response` inspection along with easy request editing via terminal commands and vim editor. Supports GET, POST, PUT, PATCH, DELETE requests in addition to establishing a long lived SSE connection to a server.

## Requirements
* Homebrew

**Vim/Vi**: Requests are piped out to a vim editor for inspection and editing. It is recommended that you have basic understanding of Vim in order to navigate the buffer.

**JQ**: All curl responses make use of JQ parser to pretty print JSON into the vim console. JQ is also used for JSON configuration parsing and CSV generation.

**curl**: HTTP client for making API requests (usually pre-installed on macOS).

### To Install Curly
The scripts are meant to be installed to and used from the local repo directory. It is recommended to run this in its own terminal rather than installing it into `/usr/bin` to limit interference with standard bash commands. On first load the helper commands will be displayed to get you started and can be recalled at any time with the `curlyHelp` helper.

```bash
git clone git@github.com:rubyDoomsday/curly.git curly
cd curly
make bootstrap
```

## Quick Start
Building a request is done by configuring the various parts of a request in a single JSON configuration file. Each request is automatically saved into a datestamp folder and can be recalled using `loadRequest history/[date]/[request]`. Active requests can be edited with the `setRequest` helper command.

```bash
setRequest                    # Edit JSON configuration
get /path/to/endpoint        # Make GET request
post /path/to/endpoint       # Make POST request with payload
```

### Configuration
Setting up RESTful calls is done through a single JSON configuration file that contains all request parameters.

| Setting          | Helper           | Use                                                           |
| ---------------- | ---------------- | ------------------------------------------------------------- |
| **setRequest**   | `setRequest`     | Opens vim editor to edit the complete JSON configuration     |
| **reload**       | `reload`         | Reloads configuration after manual edits                      |

### Configuration Format
The configuration file (`_request_config.json`) uses this schema:
```json
{
  "host": "https://api.example.com",
  "path": "/v1/users",
  "payload": {
    "name": "John Doe",
    "email": "john@example.com"
  },
  "headers": [
    "Content-Type: application/json",
    "Authorization: Bearer your-token-here"
  ]
}
```

### Making Calls
To simplify making multiple calls to the same host server, you can optionally provide the path as an argument to any of the following REST commands rather than setting it in the configuration each time.

* `get (path)` will build/send a curl request to the configured host/path
* `post (path)` will build/send a curl request to the configured host/path with payload
* `put (path)` will build/send a curl request to the configured host/path with payload
* `patch (path)` will build/send a curl request to the configured host/path with payload
* `delete (path)` will build/send a curl request to the configured host/path
* `postForm (path)` will build/send a form-encoded POST request to the configured host/path
* `openStream (path)` will build/send a curl request to open a SSE event stream to the configured host/path

## Additional Scripts
Curly includes several specialized scripts for API data extraction:

* **`script/parse_dbt_jobs`** - Extract DBT Cloud job data to CSV
* **`script/parse_fivetran_connectors`** - Extract Fivetran connector data to CSV  
* **`script/zoom_engagements`** - Extract Zoom Contact Center engagement data to CSV

Each script follows the same design principles:
- CLI arguments or JSON configuration files
- Dedicated audit directories for outputs
- Reusable curl command generation
- Robust error handling and cleanup


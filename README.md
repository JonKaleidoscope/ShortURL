# ShortURL

A short URL generator for wrapping long URL's developed using [Kitura](https://github.com/IBM-Swift/Kitura). 

## Usage

Create new URL using `POST` method on the `/` path.
Scructure your payload with the following `JSON`.
```JSON
{
	"redirectURL": "https://myawsomewebsite.com"
}
```

An example curl command:

```
curl -X "POST" "http://localhost:8080/" \
     -H 'Accept: application/json' \
     -H 'Content-Type: application/json' \
     -d $'{
  "redirectURL": "https://apple.com"
}'
```

This should derive a similar result like the following: 

```
HTTP/1.1 201 Created
Date: Tue, 13 Nov 2018 02:18:31 GMT
Content-Type: application/json
Content-Length: 56
Connection: Close

{
    "redirectURL": "https:\/\/apple.com",
    "shortURL":"6czJg"
}
```

The new usable *shortURL* will be: `localhost:8080/6czJg`.

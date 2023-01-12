# HttpFileStorage.swift

A simple http server that stores, serves and deletes files

`PUT http://[ip]:[port]/{filename}`

`GET http://[ip]:[port]/{filename}`

`DELETE http://[ip]:[port]/{filename}`

```
swift build -j 1
./build/debug/HttpFileStorage port=8080 workingDir=/home/pi/tmp
```

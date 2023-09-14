# go-gtp5gnl

go-gtp5gnl provides a netlink library about gtp5g for Go.

## License

This software is released under the Apache 2.0 License, see LICENSE

## Usage

### Build the executable file
```
# build gtp5g-link
cd cmd/gogtp5g-link
go build -o ../../tools/gtp5g-link

# build gtp5g-tunnel
cd cmd/gogtp5g-tunnel
go build -o ../../tools/gtp5g-tunnel

```

### Run script
* Simple UP Test
```
sudo ./run.sh SimpleUPTest
```

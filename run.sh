goimports -w -v .
gofmt -d -w -s .
clear
go build
./cuteify
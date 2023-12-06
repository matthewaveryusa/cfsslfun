.PHONY: all
all: ca.pem makecerts

ca.pem:
	cfssl gencert -initca ca-csr.json | cfssljson -bare ca

.PHONY: makecerts
makecerts: ca.pem
	cfssl genkey foo-csr.json | cfssljson -bare foo
	cfssl genkey foo-csr-with-sni.json | cfssljson -bare foosni
	cfssl genkey foo-csr-clientonly.json | cfssljson -bare fooclient

	cfssl sign -ca ca.pem -ca-key ca-key.pem -config ca-config.json -profile server foo.csr | cfssljson -bare foo
	cfssl sign -ca ca.pem -ca-key ca-key.pem -config ca-config.json -profile server foosni.csr | cfssljson -bare foosni
	cfssl sign -ca ca.pem -ca-key ca-key.pem -config ca-config.json -profile client fooclient.csr | cfssljson -bare fooclient

.PHONY: certinfo
certinfo: 
	cfssl certinfo -cert foo.pem
	cfssl certinfo -cert foosni.pem
	cfssl certinfo -cert fooclient.pem

.PHONY: csrinfo
csrinfo: 
	cfssl certinfo -csr foo.csr
	cfssl certinfo -csr foosni.csr
	cfssl certinfo -csr fooclient.csr

.PHONY: curl
curl:
	#with san, keyusage server
	curl --resolve foo.com:8000:127.0.0.1 --cacert ca.pem https://foo.com:8000 -vvv
	#with cn only, keyusage server
	curl --resolve foo.com:8001:127.0.0.1 --cacert ca.pem https://foo.com:8001 -vvv
	#with cn only, keyusage client only
	curl --resolve foo.com:8002:127.0.0.1 --cacert ca.pem https://foo.com:8002 -vvv

.PHONY: server
server:
	python3 server.py

.PHONY: clean
clean:
	rm *.pem *.csr

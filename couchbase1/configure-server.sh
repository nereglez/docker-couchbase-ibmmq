set -x
set -m

/entrypoint.sh couchbase-server &

sleep 20

couchbase-cli cluster-init -c 127.0.0.1 --cluster-name cluster1 --cluster-username Administrator \
 --cluster-password password --services data --cluster-ramsize 1024

# Setup index and memory quota
curl -v -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=600 -d indexMemoryQuota=200

# Setup services
curl -v http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2Cn1ql%2Cindex

# Setup credentials
curl -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=Administrator -d password=password

couchbase-cli bucket-create -c 127.0.0.1 --bucket=dev1 --bucket-type=couchbase --bucket-ramsize=200 -u Administrator -p password

sleep 15

cbdocloader -u Administrator -p password -c 127.0.0.1:8091 -b dev1 -m 200 /opt/couchbase/data1.zip

sleep 15

couchbase-cli xdcr-setup -c 127.0.0.1 -u Administrator -p password --create --xdcr-cluster-name replica --xdcr-hostname 172.16.101.14 --xdcr-username Administrator --xdcr-password password

sleep 10

couchbase-cli xdcr-replicate -c 127.0.0.1 \
-u Administrator \
-p password \
--create \
--xdcr-cluster-name replica \
--xdcr-from-bucket dev1 \
--xdcr-to-bucket dev3 \

fg 1
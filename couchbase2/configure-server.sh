set -x
set -m

/entrypoint.sh couchbase-server &

sleep 20
couchbase-cli cluster-init -c 127.0.0.1 --cluster-name cluster2 --cluster-username Administrator \
 --cluster-password password --services data --cluster-ramsize 1024

# Setup index and memory quota
curl -v -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=500 -d indexMemoryQuota=200

# Setup services
curl -v http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2Cn1ql%2Cindex

# Setup credentials
curl -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=Administrator -d password=password

couchbase-cli bucket-create -c 127.0.0.1 --bucket=dev2 --bucket-type=couchbase --bucket-ramsize=200 -u Administrator -p password

sleep 15

cbdocloader -u Administrator -p password -c 127.0.0.1:8091 -b dev2 -m 200 /opt/couchbase/data2.zip

fg 1
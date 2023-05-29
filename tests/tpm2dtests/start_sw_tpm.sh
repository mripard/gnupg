#!/bin/bash

# remove any prior TPM contents
rm -f NVChip h*.bin *.permall

DIR=$(mktemp -d)

if [ -x "${SWTPM}" ]; then
    PIDFILE=${DIR}/swtpm.pid

    swtpm_setup \
	    --tpm2 \
            --tpmstate ${DIR} \
            --createek --decryption \
            --pcr-banks sha1,sha256 \
            --display \
            > /dev/null

    ${SWTPM} socket \
           --tpm2 \
           --daemon \
           --pid file=${PIDFILE} \
           --server type=tcp,port=2321 \
           --ctrl type=tcp,port=2322 \
           --tpmstate dir=${DIR} \
           --flags startup-clear

    pid=$(cat ${PIDFILE})

else
    ${TPMSERVER} > /dev/null 2>&1  &
    pid=$!
fi

echo -n $pid

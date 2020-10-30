#!/usr/bin/env bash

if [[ "$*" == *outputCompressedDomains* ]] ; then
    exec minion $*
fi

if [[ "$*" == *findallsols* ]] ; then
    GRAPHFLAGS="--print-all-solutions"
fi

rm -f fifo.A fifo.B
mkfifo fifo.A
mkfifo fifo.B

minion $MS_MINION_OPTS $* -command-list fifo.A fifo.B &

glasgow_subgraph_solver $GRAPHFLAGS \
    --pattern-format csvname:find-f.csv --target-format csv \
    given-pat.csv given-tgt.csv \
    --send-to-lackey fifo.A --receive-from-lackey fifo.B \
    $MS_GSS_OPTS \
    | tee gss.out
ret=$?

wait

exit $?

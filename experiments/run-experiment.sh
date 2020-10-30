#!/usr/bin/env bash

results=$1
alg=$2
instance=$3
pattern=$4
target=$5

problem=$(echo ${alg} | sed -n -e 's,.*si-\([^-]*\)-.*,\1,p' )
solver=
MS_SR_OPTS=
MS_GSS_OPTS=
if echo ${alg} | grep -q -- '-gss-' ; then
    solver=gss
else
    if echo ${alg} | grep -q -- '-minion-' ; then
        solver=minion
    elif echo ${alg} | grep -q -- '-hybrid-' ; then
        solver=hybrid
        if echo ${alg} | grep -q -- '-comm-checker-' ; then
            MS_GSS_OPTS='--propagate-using-lackey never'
        elif echo ${alg} | grep -q -- '-comm-test-' ; then
            MS_GSS_OPTS='--propagate-using-lackey never --send-partials-to-lackey'
        elif echo ${alg} | grep -q -- '-comm-propagate-' ; then
            MS_GSS_OPTS='--propagate-using-lackey always --send-partials-to-lackey'
        elif echo ${alg} | grep -q -- '-comm-rollback-' ; then
            MS_GSS_OPTS='--propagate-using-lackey root-and-backjump'
        fi
    fi

    if echo ${alg} | grep -q -- '-preprocess-none-' ; then
        MS_SR_OPTS='-preprocess None'
    elif echo ${alg} | grep -q -- '-preprocess-gac-' ; then
        MS_SR_OPTS='-preprocess GAC'
    fi
fi

[[ -n $problem ]] && [[ -n $solver ]] || exit 1

export MS_SR_OPTS
export MS_GSS_OPTS

mkdir -p ${results}/${alg}/${instance} || exit 1
cd ${results}/${alg}/${instance} || exit 1

cat <<END > run-experiment.params
alg=$alg
problem=$problem
solver=$solver
pattern=$pattern
target=$target
instance=$instance
MS_GSS_OPTS=$MS_GSS_OPTS
MS_SR_OPTS=$MS_SR_OPTS
END

kill_descendants ()
{
    local children=$(ps -o pid= --ppid "$1")
    for pid in $children ; do
        kill_descendants "$pid"
    done
    echo killing $pid $(ps -q $pid -o comm= )
    kill $pid
}

retcode=x
started=$(date +'%s.%N' )
if [[ $solver == gss ]] ; then
    glasgow_subgraph_solver --format lad --timeout ${TIMEOUT} ../../../../${pattern} ../../../../${target} > >(tee gss.out)
    retcode=$?
else
    cp ../../../../code/si-${problem}.essence . || exit 1
    ../../../ladtoessence ../../../../${pattern} ../../../../${target} > instance.param || exit 1
    if [[ $solver == minion ]] ; then
        parallel --timeout $(( TIMEOUT )) <<<"conjure solve --savilerow-options=\"$MS_SR_OPTS\" si-${problem}.essence instance.param"
        retcode=$?
    elif [[ $solver == hybrid ]] ; then
        parallel --timeout $(( TIMEOUT )) <<<"conjure solve --graph-solver --savilerow-options=\"-minion-bin ../../../../code/minion-subgraph.sh $MS_SR_OPTS\" si-${problem}.essence instance.param"
        retcode=$?
    fi
fi
finished=$(date +'%s.%N' )

cat <<END > run-experiment.out
started=$started
finished=$finished
retcode=$retcode
END


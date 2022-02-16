#!/bin/bash
#
# Generic python environment for OpenFIDO
#
TESTED=0
FAILED=0
FILES=
for OPENFIDO_INPUT in $(find $PWD/autotest -name 'input_*' -print); do
    echo "Processing $OPENFIDO_INPUT..."
    export OPENFIDO_INPUT
    export OPENFIDO_OUTPUT=${OPENFIDO_INPUT/autotest\/input_/autotest\/output_}
    mkdir -p $OPENFIDO_OUTPUT
    rm -rf $OPENFIDO_OUTPUT/{*,.??*}
    cp $OPENFIDO_INPUT/* $OPENFIDO_OUTPUT
    cd $OPENFIDO_OUTPUT
    if [ -f gridlabd.rc ]; then
        OPTIONS=$(cat gridlabd.rc | tr '\n' ' ')
    else
        OPTIONS=$(ls -1 | tr '\n' ' ')
    fi
    if ! gridlabd $OPTIONS --redirect all ; then
        FAILED=$(($FAILED+1)) 
        FILES="$FILES ${OPENFIDO_OUTPUT/$PWD\//}"
        echo "ERROR: $OPENFIDO_INPUT test failed"
    fi
    TESTED=$(($TESTED+1))
done

echo "Tests completed"
echo "---------------"
echo "$TESTED tests completed"
echo "$FAILED tests failed"
echo "Runtime analysis"
echo -n "----------------"
time
echo "Result"
echo "------"
if [ $FAILED -gt 0 ]; then
    tar cfz autotest-errors.tar.gz $FILES
    echo "Failure artifacts saved to autotest-errors.tar.gz"
    exit 1
else
    echo "Success"
    exit 0
fi
#!/bin/bash

run_dune() {
  dune $1 --root=.. ${@:2}
}

declare -i passes
declare -i fails

declare -i verbose
verbose=0

check_diff() {
    if [ $verbose -ne 0 ]; then
      diff "tests/$1" "tests/out/$1"
    else
      diff "tests/$1" "tests/out/$1" > /dev/null
    fi
    local STATUS=$?
    if [ $STATUS -ne 0 ]; then
      echo "FAILED: $1 does not match expected output"
      fails=fails+1
    else
      echo "PASSED: $1 matches expected output"
      passes=passes+1
    fi
}

run_test() {
  run_dune exec dsl/meja.exe -- --ml "tests/out/$1.ml.ignore" --ast "tests/out/$FILENAME.ast" "tests/$1.meja"
  if [ $? -ne 0 ]; then
    if [ -e "tests/$1.fail" ]; then
      echo "PASSED: Got expected failure building from $1.mega"
      passes=passes+1
    else
      echo "FAILED: Building from $1.mega"
      fails=fails+1
    fi
  else
    if [ -e "tests/$1.fail" ]; then
      echo "FAILED: Expected failure building from $1.mega; got success"
      fails=fails+1
    else
      echo "PASSED: Building from $1.mega"
      passes=passes+1
    fi
  fi
  verbose_temp=$verbose
  verbose=1
  check_diff $1.ml.ignore
  verbose=$verbose_temp
  check_diff $1.ast
}

run_tests() {
  for test in tests/*.meja; do
    local FILENAME=$(basename -- "$test")
    local FILENAME="${FILENAME%.*}"
    run_test "$FILENAME"
  done
  declare -i total
  total=passes+fails
  if [[ "$fails" -ne 0 ]]; then
    echo "FAILED $fails/$total"
    return 1
  else
    echo "PASSED $passes/$total"
    return 0
  fi
}

run_tests_verbose() {
  verbose=1
  run_tests
}

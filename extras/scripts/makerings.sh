#!/usr/bin/env bash

cd "$(dirname "$0")"/../..
gimp -i --batch-interpreter=python-fu-eval -b - < "${0%%sh}py"

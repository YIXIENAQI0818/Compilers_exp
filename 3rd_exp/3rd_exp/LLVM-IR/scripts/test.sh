#!/bin/bash
cd "$(dirname "$0")/.."
cd workspace
./mc ../example/test.sy && llc output.ll -o output.s && gcc output.s runtime.o -o program

#!/bin/bash
cd "$(dirname "$0")/.."
cd workspace
./mc ../example/test.sy && gcc assemble.s -o program

#!/bin/bash
solc ./contracts/Sort.sol 2>&1 | grep Error
set -e
solc --optimize --optimize-runs 200 --asm ./contracts/Sort.sol > ./contracts/Sort.asm 2> /dev/null
yarn test test/Sort.js  2> /dev/null

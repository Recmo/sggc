#!/bin/bash
solc ./contracts/IndexOf.sol 2>&1 | grep Error
set -e
solc --optimize --optimize-runs 200 --asm ./contracts/IndexOf.sol > ./contracts/IndexOf.asm 2> /dev/null
yarn test test/IndexOf.js

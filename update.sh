#!/bin/bash
solc ./contracts/HexDecoder.sol 2>&1 | grep Error
set -e
solc --optimize --optimize-runs 200 --asm ./contracts/HexDecoder.sol > ./contracts/HexDecoder.asm 2> /dev/null
yarn test test/HexDecoder.js

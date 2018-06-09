#!/bin/sh
solc --optimize --optimize-runs 200 ./contracts/Test.sol --gas --asm > ./Test.asm
solc --optimize --optimize-runs 200 ./contracts/IndexOf.sol --gas --asm > ./IndexOf.asm
yarn test test/IndexOf.js

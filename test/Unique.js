/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

var Unique = artifacts.require("../contracts/Unique");
var IUnique = artifacts.require("../contracts/IUnique");
var testdata = require('../data/Unique.json');

contract('Unique', function(accounts) {
    var instanceFuture = Unique.new();
    testdata.vectors.forEach(function(v, i) {
        it("Passes test vector " + i, async function() {
            var instance = await instanceFuture;
            var abi = IUnique.at(instance.address);
            var result = await abi.uniquify(v.input[0], {gas: v.gas});
            assert.deepEqual(result.map(x => x.toNumber()), v.output[0]);
        });
    });

    after(async function() {
        var totalGas = 0;
        var instance = await instanceFuture;
        var abi = IUnique.at(instance.address);
        for(var v of testdata.vectors) {
            totalGas += await abi.uniquify.estimateGas(v.input[0], {gas: v.gas}) - 21000;
        }
        console.log("Total gas for Unique: " + totalGas);
    });
});

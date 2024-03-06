const Counters = artifacts.require("Counters");

module.exports = function (deployer) {
    deployer.deploy(Counters);
};
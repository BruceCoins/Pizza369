const {expect} = require("chai");
const { ethers } = require("hardhat");

describe("Calculator contract", async function(){
    
    //部署合约
    async function deployCalculator(){
        const Calculator = await ethers.getContractFactory("Calculator");
        const calculator = await Calculator.deploy();
        return {calculator};
    };

    it("should add two numbers correctly", async function(){
        const {calculator} = await deployCalculator();
        const result = await calculator.add(5,3);
        expect(result).to.equal(8);
    });
    it("should subtract two numbers correctly", async function(){
        const {calculator} = await deployCalculator();
        const result  = await calculator.sub(10,4);
        expect(result).to.equal(6);
    });
});



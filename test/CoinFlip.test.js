const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
describe("CoinFlipTesting", function() {    
    async function deployCoinFlip() {
        const [owner, player, otherAccount] = await ethers.getSigners();
        const CoinFlip = await ethers.getContractFactory("CoinFlip");
        const coinFlip = await CoinFlip.deploy();
        const GameToken = await ethers.getContractFactory("GameToken");
        const gameToken = await GameToken.deploy();
        return { coinFlip, owner, player, otherAccount };
    }

    describe("Intialization", function() {
        it("Test for constructor", async function() {
            const { coinFlip} = await loadFixture(deployCoinFlip);
            const coeff = 195;
            const minDepositAmount = 100;
            const maxDepositAmount = BigInt(1e18);
            expect(await coinFlip.coeff()).to.equal(coeff);
            expect(await coinFlip.minDepositAmount()).to.equal(minDepositAmount);
            expect(await coinFlip.maxDepositAmount()).to.equal(maxDepositAmount);
        });
    });

    describe("changeCoeff", function() {
        it("Test for changeCoeff", async function() {
            const { coinFlip} = await loadFixture(deployCoinFlip);
            await coinFlip.changeCoeff(123);
            expect(await coinFlip.coeff()).to.equal(123);
        });
    });

    describe("ChangeMaxMinBet", () => {
        it("Test for changeMaxMinBet", async () => {
            const { coinFlip} = await loadFixture(deployCoinFlip);
            await coinFlip.changeMaxMinBet(1, 2);

            expect(await coinFlip.minDepositAmount()).to.equal(1);
            expect(await coinFlip.maxDepositAmount()).to.equal(2);

        });
    });

    describe("PLay", () => {
        const depAmount = 12;
        const choice = 1;
        it("check for correct transfer", async () => {
            const { coinFlip, owner, player } = await loadFixture(deployCoinFlip);
            await coinFlip.mint(14);
            // const token = coinFlip.GameToken();
            const playerBalance = coinFlip.balanceOf(player.address);
            const ownerBalance = coinflip.balanceOf(owner.address);
            await coinFlip.play(depAmount, choice);
            await coinFlip.transferFrom(payer.address, owner.address, depAmount);

            expect(await coinFlip.balanceOf(player.address)).to.equal(playerBalance - depAmount);
            expect(await coinFlip.balanceOf(owner.address)).to.equal(ownerBalance + depAmount);

        });

    });

    it("Should revert a message when there is not enough funds to withdraw ", async () => {
        const { coinFlip, owner, caller } = await loadFixture(deployCoinFlip);

        await expect(coinFlip.withdraw(10000000000000))
            .to.be.revertedWith('Not enough funds');
    });
});
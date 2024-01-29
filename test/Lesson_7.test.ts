import { loadFixture, expect, ethers } from "./setup";

describe('Lesson_7', () => {
    async function deploy(){
        const [owner, anotherUser] = await ethers.getSigners();

        const Factory = await ethers.getContractFactory("Lesson_7");
        const payments = await Factory.deploy();
        await payments.waitForDeployment();

        return {owner, anotherUser, payments}
    }

    async function sendMoney(){
        const {anotherUser, payments} = await loadFixture(deploy);

        const amount = 100;
        const txData = {
            to: payments.target,
            value: amount
        }

        const tx = await anotherUser.sendTransaction(txData);
        await tx.wait();
        return [tx, amount];
    }

    it("should allow to send money", async () => {
        const {anotherUser, payments} = await loadFixture(deploy)
    
        const currentBlock = await ethers.provider.getBlock(
            await ethers.provider.getBlockNumber()
        );

        const [sendMoneyTx, amount] = await sendMoney();
    
    
        console.log(sendMoneyTx);
        expect(sendMoneyTx).to.changeEtherBalance(payments, amount);
    
        expect(sendMoneyTx).to
            .emit(payments, "Paid")
                .withArgs(anotherUser.address, amount, currentBlock?.timestamp);
    
    })

    it("should withdraw only the owner", async () => {
        const {owner, payments} = await loadFixture(deploy);

        const [_, amount] = await sendMoney();

        const tx = await payments.withdraw(owner.address);

        expect(tx).to.changeEtherBalance([payments, owner], [-amount, amount]);
    })

    it("should not allow other accounts to withdraw funds", async () => {
        const {anotherUser, payments} = await loadFixture(deploy);
        await sendMoney();

        expect(payments.connect(anotherUser).withdraw(anotherUser.address)).to.be.revertedWith("you are not an owner");
    })
})
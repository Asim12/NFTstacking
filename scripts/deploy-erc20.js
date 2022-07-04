
require('dotenv').config();
const {totalSupply} = process.env;
async function main() {
    const Contract = await ethers.getContractFactory("erc20Supply")
    const contractInstance = await Contract.deploy(
        totalSupply,
        
    )
    console.log(`Contract deployed to "${contractInstance.address}"`);
}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
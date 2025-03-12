import { ethers, network, run, upgrades } from 'hardhat'

async function main() {
  const factory = await ethers.getContractFactory('Merv')
  const proxyAddress =
    network.name === 'testnet'
      ? '0x53D084eCCb71BaFfaC16AC3a91717F0122850003'
      : '0xdf65A4E7DAE495Cb42F5A1E9A7f89032542684Ba'
  console.log('Upgrading Merv...')
  const contract = await upgrades.upgradeProxy(proxyAddress as string, factory)
  console.log('Merv upgraded')
  console.log(
    await upgrades.erc1967.getImplementationAddress(
      await contract.getAddress()
    ),
    ' getImplementationAddress'
  )
  console.log(
    await upgrades.erc1967.getAdminAddress(await contract.getAddress()),
    ' getAdminAddress'
  )
  console.log('Wait for 1 minute to make sure blockchain is updated')
  await new Promise((resolve) => setTimeout(resolve, 60 * 1000))
  // Try to verify the contract on Etherscan
  console.log('Verifying contract on Etherscan')
  try {
    await run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        await contract.getAddress()
      ),
      constructorArguments: [],
    })
  } catch (err) {
    console.log(
      'Error verifying contract on Etherscan:',
      err instanceof Error ? err.message : err
    )
  }
  // Print out the information
  console.log(`Done!`)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

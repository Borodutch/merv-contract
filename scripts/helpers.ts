import { ethers } from 'hardhat'

export async function printSignerInfo() {
  const [deployer] = await ethers.getSigners()
  const address = await deployer.getAddress()
  const balance = await ethers.provider.getBalance(deployer)
  console.log('Deploying contracts with the account:', address)
  console.log('Account balance:', ethers.formatEther(balance))
}

export async function waitOneMinute() {
  console.log('Wait for 1 minute to make sure blockchain is updated')
  await new Promise((resolve) => setTimeout(resolve, 60 * 1000))
}

export async function printChainInfo() {
  const provider = ethers.provider
  const { name: chainName } = await provider.getNetwork()
  console.log('Deploying to chain:', chainName)
}

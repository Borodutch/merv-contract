import { ethers, upgrades } from 'hardhat'
import { expect } from 'chai'

describe('Merv contract tests', () => {
  let Merv, merv, owner

  before(async function () {
    ;[owner] = await ethers.getSigners()
    Merv = await ethers.getContractFactory('Merv')
    merv = await upgrades.deployProxy(Merv, [
      owner.address,
      '$MERV',
      'MERV',
      ethers.parseUnits('1000', 18),
      1,
      ethers.parseUnits('1000000', 18),
    ])
  })

  describe('Initialization', function () {
    it('should have correct initial values', async function () {
      expect(await merv.name()).to.equal('$MERV')
      expect(await merv.symbol()).to.equal('MERV')
    })
  })
})

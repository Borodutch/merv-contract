// ░▒▓██████████████▓▒░░▒▓████████▓▒░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░
// ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░
// ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒▒▓█▓▒░
// ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░ ░▒▓███████▓▒░ ░▒▓█▓▒▒▓█▓▒░
// ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▓█▓▒░
// ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▓█▓▒░
// ░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░  ░▒▓██▓▒░

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20FlashMintUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/// @custom:security-contact merv@bdut.ch
contract Merv is
  Initializable,
  ERC20Upgradeable,
  ERC20BurnableUpgradeable,
  ERC20PausableUpgradeable,
  OwnableUpgradeable,
  ERC20PermitUpgradeable,
  ERC20VotesUpgradeable,
  ERC20FlashMintUpgradeable,
  ReentrancyGuardUpgradeable
{
  // State
  uint256 public mintRate;
  uint256 public supplyCap;
  uint256 public amountMinted;

  // Events
  event MintRateSet(uint256 newMintRate);
  event SupplyCapSet(uint256 newSupplyCap);
  event Merved(address indexed merver);
  event LookedIntoAbyss(address indexed looker);
  event Redeemed(
    address indexed redeemer,
    uint256 mervAmount,
    uint256 ethAmount
  );

  function initialize(
    address initialOwner,
    string calldata name,
    string calldata symbol,
    uint256 premintAmount,
    uint256 initialMintRate,
    uint256 initialSupplyCap
  ) public initializer {
    mintRate = initialMintRate;
    supplyCap = initialSupplyCap;

    __ERC20_init(name, symbol);
    __ERC20Burnable_init();
    __ERC20Pausable_init();
    __Ownable_init(initialOwner);
    __ERC20Permit_init(name);
    __ERC20Votes_init();
    __ERC20FlashMint_init();
    __ReentrancyGuard_init();

    _mint(initialOwner, premintAmount);
    amountMinted += premintAmount;
  }

  function setMintRate(uint256 newMintRate) public onlyOwner {
    mintRate = newMintRate;
    emit MintRateSet(newMintRate);
  }

  function setSupplyCap(uint256 newSupplyCap) public onlyOwner {
    supplyCap = newSupplyCap;
    emit SupplyCapSet(newSupplyCap);
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  function withdraw() public onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  function redeem(uint256 mervAmount) public nonReentrant {
    require(mervAmount > 0, "No MERV tokens to redeem");
    require(balanceOf(msg.sender) >= mervAmount, "Insufficient MERV balance");
    require(mintRate > 0, "Mint rate not set");

    uint256 ethAmount = mervAmount / (mintRate * 2);
    require(ethAmount > 0, "Redeem amount too small");
    require(
      address(this).balance >= ethAmount,
      "Insufficient contract ETH balance"
    );

    // Burn the MERV tokens first (this updates state)
    _burn(msg.sender, mervAmount);

    // Transfer ETH to the redeemer (external call last)
    (bool success, ) = payable(msg.sender).call{value: ethAmount}("");
    require(success, "ETH transfer failed");

    emit Redeemed(msg.sender, mervAmount, ethAmount);
  }

  function merv() public {
    emit Merved(msg.sender);
  }

  function lookIntoAbyss() public {
    emit LookedIntoAbyss(msg.sender);
  }

  // The following functions are overrides required by Solidity.

  function _update(
    address from,
    address to,
    uint256 value
  )
    internal
    override(ERC20Upgradeable, ERC20PausableUpgradeable, ERC20VotesUpgradeable)
  {
    super._update(from, to, value);
  }

  function nonces(
    address owner
  )
    public
    view
    override(ERC20PermitUpgradeable, NoncesUpgradeable)
    returns (uint256)
  {
    return super.nonces(owner);
  }
}

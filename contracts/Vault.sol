// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./interfaces/ILido.sol";

contract Vault is ReentrancyGuard, Ownable {
  address private operator;
  address public depositTokenAddress;
  address public withdrawTokenAddress;
  address public strategyAddress;
  mapping (address => uint256) balances;
  uint256 public fee;
  uint256[2] public feeInterval;
  uint256 private total;
  bool public isVaultOpen = false;
  bool public isVaultERC20;
  bool public isStrategyWithdrawable = false;
  ILido public lido;

  constructor(address _operator, address _depositTokenAddress, address _withdrawTokenAddress,  address _strategyAddress, uint256 _fee, uint256 _lowerFeeBound, uint256 _upperFeeBound, bool _isERC20) {
    operator = _operator;
    depositTokenAddress = _depositTokenAddress;
    withdrawTokenAddress = _withdrawTokenAddress;
    strategyAddress = _strategyAddress;
    lido = ILido(_strategyAddress);
    fee = _fee;
    feeInterval = [_lowerFeeBound, _upperFeeBound];
    isVaultERC20 = _isERC20;
  }

  fallback() external payable {
    depositETH();
  }

  function lockVault() public onlyOwner {
    isVaultOpen = false;
  }

  function openVault() public onlyOwner {
    isVaultOpen = true;
  }

  function openWithdraws() public onlyOwner {
    isStrategyWithdrawable = true;
  }

  function closeWithdraws() public onlyOwner {
    isStrategyWithdrawable = false;
  }

  function changeFee(uint256 newFee) public onlyOwner {
    require(newFee >= feeInterval[0] && newFee <= feeInterval[1], "Invalid fee value");
    fee = newFee;
  }

  function changeFeeInterval(uint256 lowerBound, uint256 upperBound) public onlyOwner {
    feeInterval = [lowerBound, upperBound];
  }

  function depositETH() public payable nonReentrant {
    balances[msg.sender] += msg.value;
    total += msg.value;
    (bool sent, bytes memory data) = address(lido).call{value: msg.value}("");
    require(sent, "Failed to send Ether");
  }

  function depositERC20(uint256 amount) public nonReentrant{
    require(isVaultOpen, "Vault is closed");
    uint256 feeAmount = amount * (fee / 100);
    require(IERC20(depositTokenAddress).balanceOf(msg.sender) >= amount + feeAmount, "Insufficient token balance");
    require(IERC20(depositTokenAddress).approve(address(this), amount + feeAmount));
    require(IERC20(depositTokenAddress).transferFrom(msg.sender, address(this), amount + feeAmount));

    balances[msg.sender] += amount;
    total += amount;
  }

  function withdraw(uint256 amount) public nonReentrant returns(uint256, address) {
    require(isVaultOpen, "Vault is closed");
    require(balances[msg.sender] < amount, "Amount is too big");

    bool isSuccessApprove = IERC20(tokenAddress).approve(msg.sender, amount);
    bool isSuccessTransferFrom = IERC20(tokenAddress).transferFrom(address(this), msg.sender, amount);

    if (isSuccessApprove && isSuccessTransferFrom) {
      balances[msg.sender] -= amount;
      total -= amount;
      return (amount, tokenAddress);
    }

    revert("Failed to withdraw");
  }

  function getBalance(address account) external view returns(uint256) {
    return balances[account];
  }

  function getFee() external view returns(uint256) {
    return fee;
  }

  function getTotal() external view returns(uint256) {
    return total;
  }
}
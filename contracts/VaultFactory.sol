// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./Vault.sol";

contract VaultFactory is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    address[] private vaults;

    function initialize() public initializer {
        __Ownable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function createChild(
        address _operator,
        address _depositTokenAddress,
        address _withdrawTokenAddress,
        address _strategyAddress,
        uint256 _fee,
        uint256 _lowerFeeBound,
        uint256 _upperFeeBound
    ) public {
        Vault vault = new Vault(
            _operator,
            _depositTokenAddress,
            _withdrawTokenAddress,
            _strategyAddress,
            _fee,
            _lowerFeeBound,
            _upperFeeBound
        );
        address vaultAddress = address(vault);
        vaults.push(vaultAddress);

        emit VaultCreated(vaultAddress);
    }

    event VaultCreated(address newVaultAddress);

    function getVaults() public view returns (address[] memory) {
        return vaults;
    }
}

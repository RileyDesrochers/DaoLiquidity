// SPDX-License-Identifier: UNLICENSED

// Written by: Riley Desrochers
pragma solidity =0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './DaoLiquidityPool.sol';

import "hardhat/console.sol";

contract DaoLiquidityFactory {
    mapping(address => address[]) public tokenAddresstoPoolAddress;
    address[] public allTokens;

    constructor() {
    }

    function createPool(address token) public returns(address pair){
        uint32 ind = 0;
        bytes memory bytecode = type(DaoLiquidityPool).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token, ind));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
    }
}

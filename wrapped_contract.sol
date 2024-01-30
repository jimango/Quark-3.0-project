// SPDX-License-Identifier: MIT
// (c)2024 Atlas (atlas@cryptolink.tech)
pragma solidity =0.8.19;

import "@cryptolink/contracts/message/MessageClient.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract HelloERC20 is ERC20Burnable, MessageClient {

    IERC20 private _quarkToken;
    address private _quarkTokenAddress;

    constructor(
        address quarkTokenAddress
    ) ERC20("WrappedQuark", "WQuark") {
        _quarkTokenAddress = address(quarkTokenAddress);
        _quarkToken = IERC20(_quarkTokenAddress);
    }
    
    function bridge(
        uint _destChainId, 
        address _recipient, 
        uint _amount
    ) external onlyActiveChain(_destChainId) {
        // burn tokens
        _burn(msg.sender, _amount);
        // send cross chain message
        _sendMessage(_destChainId, abi.encode(_recipient, _amount));
    }

    function messageProcess(
        uint, 
        uint _sourceChainId, 
        address _sender, 
        address, uint, 
        bytes calldata _data
    ) external override  onlySelf(_sender, _sourceChainId)  {
        // decode message
        (address _recipient, uint _amount) = abi.decode(_data, (address, uint));
        // mint tokens
        _mint(_recipient, _amount);
    }

    function depositQuark(
        uint256 amountToDeposit
    ) public {
        require(_quarkToken.balanceOf(msg.sender) >= amountToDeposit, "Insufficient Quark tokens!");
        _quarkToken.transferFrom(msg.sender, address(this), amountToDeposit);
        _mint(address(this), amountToDeposit);
    }

    function wrapQuark(
        uint256 amountToWrap
    ) public {
        require(_quarkToken.balanceOf(msg.sender) >= amountToWrap, "Insufficient Quark tokens!");
        _quarkToken.transferFrom(msg.sender, address(this), amountToWrap);
        _mint(msg.sender, amountToWrap);
    }

    function unwrapQuark(
        uint256 amountToUnwrap
    ) public {
        require(balanceOf(msg.sender) >= amountToUnwrap, "");
        _quarkToken.transferFrom(address(this), msg.sender, amountToUnwrap);
        _burn(msg.sender, amountToUnwrap);
    }

}
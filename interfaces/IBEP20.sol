// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// Interface para o contrato do token (padrão BEP-20)
interface IBEP20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
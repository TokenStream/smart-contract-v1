// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SalaryStreaming} from "../src/SalaryStreaming.sol";
import {Token} from "../src/Token.sol";


contract SalaryStreamingTest is Test {
    SalaryStreaming public salaryStreaming;
    Token public erc20;


    address A = address(0xa);
    address B = address(0xb);
    address owner = address(0xc);

    function setUp() public {
        erc20 = new Token();
        // Mint some tokens for testing
        erc20.mint();

        salaryStreaming = new SalaryStreaming(address(erc20));  
       
        erc20.approve(address(salaryStreaming), 10000 * (10 ** 18)); 
        // erc20.transfer(address(salaryStreaming), 100);      
    }

 function test_StartStream() public { 
    owner = mkaddr("owner");
    A = mkaddr("recipient1"); 

    // Ensure the owner has enough tokens
    erc20.approve(address(owner), 10000 * (10 ** 18));
    erc20.transfer(owner, 10 * (10 ** 18)); // Assuming 18 decimals

    uint256 bal = erc20.balanceOf(owner);
    
    console.log("owner balance: ", bal);

    vm.prank(owner); 
    salaryStreaming.startStream(A, 10, 1);
    (, , , bool active) = salaryStreaming.getStream(A);
    assertEq(active, true);
}
    // function test_pauseStream(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }
}

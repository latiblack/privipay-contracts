// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import {FHE} from "@fhevm/solidity/lib/FHE.sol";

contract ConfidentialPayroll {
    address public owner;
    bytes32 public orgId;

    mapping(address => uint256) public salaries;
    mapping(address => uint256) public bonuses;
    mapping(address => uint256) public voteCounts;

    address[] private employeeList;
    mapping(address => bool) public isEmployee;
    mapping(address => bool) public pendingRequests;

    address public relayer;

    event SalarySet(address indexed employee, uint256 amount);
    event BonusDistributed(address indexed employee, uint256 amount);
    event VoteCasted(address indexed voter, address indexed candidate);
    event JoinRequested(address indexed user);
    event JoinApproved(address indexed user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(bytes32 _orgId) {
        owner = msg.sender;
        orgId = _orgId;
    }

    function requestJoin() external {
        require(!isEmployee[msg.sender], "Already employee");
        require(!pendingRequests[msg.sender], "Already requested");
        pendingRequests[msg.sender] = true;
        emit JoinRequested(msg.sender);
    }

    function approveJoin(address user) external onlyOwner {
        require(pendingRequests[user], "No request");
        pendingRequests[user] = false;
        isEmployee[user] = true;
        employeeList.push(user);
        emit JoinApproved(user);
    }

    function setSalary(address employee, uint256 amount) external onlyOwner {
        salaries[employee] = amount;
        emit SalarySet(employee, amount);
    }

    function setBonus(address employee, uint256 amount) external onlyOwner {
        bonuses[employee] = amount;
        emit BonusDistributed(employee, amount);
    }

    function getSalary(address employee) external view returns (uint256) {
        require(msg.sender == employee || msg.sender == owner, "Not allowed");
        return salaries[employee];
    }

    function getBonus(address employee) external view returns (uint256) {
        require(msg.sender == employee || msg.sender == owner, "Not allowed");
        return bonuses[employee];
    }

    function castVoteFor(address voter, address candidate) external onlyOwner {
        require(isEmployee[voter], "Not employee");
        voteCounts[candidate] += 1;
        emit VoteCasted(voter, candidate);
    }

    function distributeBonuses(uint256 threshold) external onlyOwner {
        for (uint i = 0; i < employeeList.length; i++) {
            address emp = employeeList[i];

            if (voteCounts[emp] >= threshold) {
                bonuses[emp] = 100000;
                emit BonusDistributed(emp, 100000);
            }
        }
    }

    function getTotalPayroll() external view onlyOwner returns (uint256) {
        uint256 total;

        for (uint i = 0; i < employeeList.length; i++) {
            total += salaries[employeeList[i]];
        }

        return total;
    }

    function withdrawSalary() external {
        require(isEmployee[msg.sender], "Not employee");

        uint256 amount = salaries[msg.sender];
        require(amount > 0, "No salary");

        salaries[msg.sender] = 0;

        emit SalarySet(msg.sender, 0);
    }

    function getEmployeeCount() external view returns (uint256) {
        return employeeList.length;
    }

    function getEmployee(uint256 index) external view returns (address) {
        require(index < employeeList.length, "Invalid index");
        return employeeList[index];
    }
}

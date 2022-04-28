pragma solidity ^0.5.0;

import './RWD.sol';
import './Tether.sol';

contract DecentralBank {
    address public owner;
    string public name = 'Decentral Bank';
    RWD public rwd;
    Tether public tether;

    address[] public stakers;

    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaked;

    modifier isOwner {
        if (msg.sender == owner) _;
    }

    constructor(RWD _rwd, Tether _tether) public {
        rwd = _rwd;
        tether = _tether;
        owner = msg.sender;
    }

    function depositTokens(uint256 amount) public {
        //Require staking amount to be > 0.
        // require(amount > 0, 'Amount should be more than 0.');

        //Transfer tether tokens to this contract address for staking.
        tether.transferFrom(msg.sender, address(this), amount);

        //Update stackers.
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        //Update stakingBalance.
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + amount;

        //Update isStacked.
        isStaked[msg.sender] = true;

        //Update hasStacked.
        hasStaked[msg.sender] = true;
    }

    function unstakeTokens() public {
        // require(isStaked[msg.sender] == false, 'You need to stake first!'); //ERROR HERE WHEN RUNNING TESTS.
        require(stakingBalance[msg.sender] > 0, 'Unstake amount should be bigger than 0');

        //Transfer from contract address to msg.sender address.
        tether.transfer(msg.sender, stakingBalance[msg.sender]);

        //Update isStacked.
        isStaked[msg.sender] = false;

        //Update stakingBalance.
        stakingBalance[msg.sender] -= stakingBalance[msg.sender];

        //Update stakers.
        for (uint i = 0; i < stakers.length; i++) {
            if (stakers[i] == msg.sender) {
                delete stakers[i];
                break;
            }
        }
    }

    function issueRewards() public isOwner {
        for (uint256 index = 0; index < stakers.length; index++) {
            uint balance = stakingBalance[stakers[index]];

            if (balance > 0) {
                //Transfer to stakers[index] address with 1 % of the tokens he staked.
                rwd.transfer(stakers[index], stakingBalance[stakers[index]] / 100);
            }
        }
    }

    function withdraw() public {
        require(hasStaked[msg.sender], "You can't withdraw before staking.");
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Crowdfunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint minimumcontribution;
    uint deadline;
    uint target;
    uint raisedamt;
    uint noofcontributors;
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noofvoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequests;
    constructor(uint _deadline,uint _target){
        manager=msg.sender;
        deadline=block.timestamp+_deadline;
        target=_target;
        minimumcontribution=100 wei;
    }
    function sendeth() payable public{
        require(block.timestamp>target,"Time up");
        require(msg.value>=minimumcontribution,"Minimum contribution not met");
        if(contributors[msg.sender]==0)
        {
            noofcontributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedamt+=msg.value;
    }
    function getcontractbalance() public view returns(uint){
        require(msg.sender==manager);
        return address(this).balance;
    }
    function refund() public{
        require(raisedamt<target && block.timestamp>deadline,"You are not eligible");
        require(contributors[msg.sender]>0,"You have not contributed");
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier onlyManager(){
        require(msg.sender==manager);
        _;
    }
    function createRequests(string memory _description,address payable _recipient,uint _value) onlyManager public{
        Request storage newRequest=requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noofvoters=0;
    }
    function voterequest(uint _requestno) public{
        require(contributors[msg.sender]>0,"You have to be a contributor");
        Request storage thisRequest=requests[_requestno];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noofvoters++;
    }
    function makepayment(uint _requestno) public onlyManager{
        require(raisedamt>=target,"The target is not reached");
        Request storage thisRequest=requests[_requestno];
        require(thisRequest.completed==false);
        require(thisRequest.noofvoters>noofcontributors/2,"Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }

}
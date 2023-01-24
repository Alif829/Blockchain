pragma solidity >=0.4.22 <=0.8.17;

contract GreedyBanker {
    uint256 constant fee = 1000 wei;

    mapping(address => uint256) balances;
    mapping(address => uint256) depositCount;

    uint256 feesCollected;

    address owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        uint256 depositFee;
        if (depositCount[msg.sender] >= 1) {
            require(msg.value >= fee, "amount is not enough to cover the fee");
            depositFee = fee;
        }

        balances[msg.sender] += msg.value - depositFee;
        feesCollected += depositFee;
        depositCount[msg.sender]++;
    }

    fallback() external payable {
        feesCollected += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient balance");
        balances[msg.sender] -= amount;
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "withdraw failed");
    }

    function collectFees() external {
        require(msg.sender == owner, "only the owner can call this function");
        uint256 totalFees = feesCollected;
        feesCollected = 0;
        (bool sent, ) = payable(owner).call{value: totalFees}("");
        require(sent, "transfer failed");
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}

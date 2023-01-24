
pragma solidity >=0.4.22 <=0.8.17;

contract EtherMath {
    int256[] usableNumbers;
    int256 sum;
    uint256 reward;

    address owner;

    mapping(address => uint256) unclaimedRewards;

    address[] submittedSolution;

    constructor() {
        owner = msg.sender;
    }

    function verifySolution(int256[] memory solution)
        internal
        view
        returns (bool)
    {
        int256 solutionSum;

        for (uint256 idx; idx < solution.length; idx++) {
            bool numberExists;
            for (uint256 j; j < usableNumbers.length; j++) {
                // check if the number the solution used is in usableNumbers
                if (usableNumbers[j] == solution[idx]) {
                    numberExists = true;
                }
            }

            if (!numberExists) {
                return false;
            }
            solutionSum += solution[idx];
        }

        return solutionSum == sum;
    }

    function userSubmittedSolution(address user) internal view returns (bool) {
        for (uint256 idx; idx < submittedSolution.length; idx++) {
            address currentUser = submittedSolution[idx];
            if (currentUser == user) {
                return true;
            }
        }
        return false;
    }

    function submitChallenge(int256[] memory array, int256 targetSum)
        public
        payable
    {
        require(msg.sender == owner, "only the owner can call this function");
        require(reward == 0, "a challenge is already active");
        require(msg.value > 0, "you must send a non-zero value for the reward");
        reward = msg.value;
        usableNumbers = array;
        sum = targetSum;
    }

    function submitSolution(int256[] memory solution) public {
        require(reward != 0, "no challenge is currently active");
        require(
            !userSubmittedSolution(msg.sender),
            "you have already submitted a solution"
        );

        submittedSolution.push(msg.sender);
        if (verifySolution(solution)) {
            unclaimedRewards[msg.sender] += reward;
            reward = 0;
            sum = 0;
            delete submittedSolution;
            delete usableNumbers;
        }
    }

    function claimRewards() public {
        uint256 userReward = unclaimedRewards[msg.sender];
        unclaimedRewards[msg.sender] = 0;
        (bool sent, ) = payable(msg.sender).call{value: userReward}("");
        require(sent, "transfer failed");
    }
}


pragma solidity >=0.4.22 <=0.8.17;

contract EtherElection {
    address owner;

    address[] candidates;
    mapping(address => uint256) votes;
    mapping(address => bool) voted; // store who has already voted

    address winner;
    bool winnerWithdrew;

    constructor() {
        owner = msg.sender;
    }

    function isCandidateInCandidates(address candidate)
        internal
        view
        returns (bool)
    {
        for (uint256 idx; idx < candidates.length; idx++) {
            address currentCandidate = candidates[idx];

            if (currentCandidate == candidate) {
                return true;
            }
        }

        return false;
    }

    function enroll() public payable {
        require(candidates.length != 3, "3 candidates have already enrolled");
        require(msg.value == 1 ether, "you must send exaclty one ether");
        require(
            !isCandidateInCandidates(msg.sender),
            "you are already a candiate"
        );

        candidates.push(msg.sender);
    }

    function vote(address candidate) public payable {
        require(candidates.length == 3, "enrollment is not done");
        require(isCandidateInCandidates(candidate), "invalid candidate");
        require(winner == address(0), "voting has ended");
        require(!voted[msg.sender], "you have already voted");
        require(msg.value == 10000, "incorrect fee");
        voted[msg.sender] = true;
        votes[candidate]++;

        if (votes[candidate] == 5) {
            winner = candidate;
        }
    }

    function getWinner() public view returns (address) {
        require(winner != address(0), "winner has not been declared");
        return winner;
    }

    function claimReward() public {
        require(winner != address(0), "winner has not been declared");
        require(msg.sender == winner, "you are not the winner");
        require(!winnerWithdrew, "you have already withdrawn your reward");
        winnerWithdrew = true;
        (bool sent, ) = payable(winner).call{value: 3 ether}("");
        require(sent, "transfer failed");
    }

    function collectFees() public {
        require(winnerWithdrew, "winner has not yet withdrawn reward");
        require(msg.sender == owner, "only the owner can call this function");
        selfdestruct(payable(owner));
    }
}

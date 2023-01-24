pragma solidity >=0.4.22 <=0.8.17;

contract AdvancedCounter {
    mapping(address => mapping(string => int256)) counters;
    mapping(address => mapping(string => bool)) counterIdExists; // required to keep track of used ids
    mapping(address => uint256) numCountersCreated; // required to keep track of number of counters

    function counterExists(string memory id) internal view returns (bool) {
        // it is not neccessary to write this function but it helps keep the code more readable
        return counterIdExists[msg.sender][id];
    }

    function createCounter(string memory id, int256 value) public {
        require(
            numCountersCreated[msg.sender] != 3,
            "you have already created the maximum number of counters"
        );
        require(!counterExists(id), "a counter with this id already exists");
        counters[msg.sender][id] = value;
        numCountersCreated[msg.sender]++;
        counterIdExists[msg.sender][id] = true;
    }

    function deleteCounter(string memory id) public {
        require(counterExists(id), "this counter does not exist");
        delete counters[msg.sender][id];
        numCountersCreated[msg.sender]--;
        counterIdExists[msg.sender][id] = false;
    }

    function incrementCounter(string memory id) public {
        require(counterExists(id), "this counter does not exist");
        counters[msg.sender][id]++;
    }

    function decrementCounter(string memory id) public {
        require(counterExists(id), "this counter does not exist");
        counters[msg.sender][id]--;
    }

    function getCount(string memory id) public view returns (int256) {
        require(counterExists(id), "this counter does not exist");
        return counters[msg.sender][id];
    }
}

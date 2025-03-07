// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract RegistroFinca {
    struct Batch {
        string batchId;
        string producerName;
        string farm;
        string locationGPS;
        string tastingResults;
        string humidityAnalysis;
        uint256 timestamp;
    }
    
    mapping(string => Batch) public batches;
    string[] public allBatchIds;
    
    event BatchRegistered(string batchId, bytes32 batchHash);
    
    function registerBatch(
        string memory _batchId,
        string memory _producerName,
        string memory _farm,
        string memory _locationGPS,
        string memory _tastingResults,
        string memory _humidityAnalysis
    ) public {
        require(bytes(batches[_batchId].batchId).length == 0, "Batch already registered");
        
        batches[_batchId] = Batch({
            batchId: _batchId,
            producerName: _producerName,
            farm: _farm,
            locationGPS: _locationGPS,
            tastingResults: _tastingResults,
            humidityAnalysis: _humidityAnalysis,
            timestamp: block.timestamp
        });
        
        allBatchIds.push(_batchId);
        
        bytes32 batchHash = getBatchHash(_batchId);
        emit BatchRegistered(_batchId, batchHash);
    }
    
    function getBatchHash(string memory _batchId) public view returns (bytes32) {
        Batch memory b = batches[_batchId];
        require(bytes(b.batchId).length > 0, "Batch does not exist");
        
        return keccak256(abi.encodePacked(
            b.batchId,
            b.producerName,
            b.farm,
            b.locationGPS,
            b.tastingResults,
            b.humidityAnalysis,
            b.timestamp
        ));
    }
    
    function getBatchInfo(string memory _batchId) public view returns (
        string memory producerName,
        string memory farm,
        string memory locationGPS,
        string memory tastingResults,
        string memory humidityAnalysis,
        uint256 timestamp
    ) {
        Batch memory b = batches[_batchId];
        require(bytes(b.batchId).length > 0, "Batch does not exist");
        
        return (
            b.producerName,
            b.farm,
            b.locationGPS,
            b.tastingResults,
            b.humidityAnalysis,
            b.timestamp
        );
    }
    
    function getAllBatchIds() public view returns (string[] memory) {
        return allBatchIds;
    }
    
    function getTotalBatches() public view returns (uint256) {
        return allBatchIds.length;
    }
}
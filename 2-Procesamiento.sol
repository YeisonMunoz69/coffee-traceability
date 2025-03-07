// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "0-Interfaces.sol"; // Importar las interfaces

contract Procesamiento {
    struct ProcessingData {
        string batchId;
        string processingDetails;
        string certifications;
        uint256 timestamp;
        bytes32 previousStageHash;
    }
    
    mapping(string => ProcessingData) public processData;
    string[] public allProcessedBatchIds;
    
    address public registroFincaAddress;
    IRegistroFinca registroFinca;
    
    event ProcessingUpdated(string batchId, bytes32 processingHash);
    
    constructor(address _registroFincaAddress) {
        registroFincaAddress = _registroFincaAddress;
        registroFinca = IRegistroFinca(_registroFincaAddress);
    }
    
    function updateProcessing(
        string memory _batchId,
        string memory _processingDetails,
        string memory _certifications
    ) public {
        require(bytes(processData[_batchId].batchId).length == 0, "Processing already updated");
        
        // Verificar que el lote existe en RegistroFinca
        bytes32 previousHash = registroFinca.getBatchHash(_batchId);
        
        processData[_batchId] = ProcessingData({
            batchId: _batchId,
            processingDetails: _processingDetails,
            certifications: _certifications,
            timestamp: block.timestamp,
            previousStageHash: previousHash
        });
        
        allProcessedBatchIds.push(_batchId);
        
        bytes32 processingHash = getProcessingHash(_batchId);
        emit ProcessingUpdated(_batchId, processingHash);
    }
    
    function getProcessingHash(string memory _batchId) public view returns (bytes32) {
        ProcessingData memory p = processData[_batchId];
        require(bytes(p.batchId).length > 0, "Processing data does not exist");
        
        return keccak256(abi.encodePacked(
            p.batchId,
            p.processingDetails,
            p.certifications,
            p.timestamp,
            p.previousStageHash
        ));
    }
    
    function getProcessingInfo(string memory _batchId) public view returns (
        string memory processingDetails,
        string memory certifications,
        uint256 timestamp,
        bytes32 previousStageHash
    ) {
        ProcessingData memory p = processData[_batchId];
        require(bytes(p.batchId).length > 0, "Processing data does not exist");
        
        return (
            p.processingDetails,
            p.certifications,
            p.timestamp,
            p.previousStageHash
        );
    }
    
    function getAllProcessedBatchIds() public view returns (string[] memory) {
        return allProcessedBatchIds;
    }
    
    function getTotalProcessedBatches() public view returns (uint256) {
        return allProcessedBatchIds.length;
    }
}
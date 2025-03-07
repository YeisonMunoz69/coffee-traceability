// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "0-Interfaces.sol";

contract Consolidacion {
    struct ConsolidationData {
        string batchId;
        uint256 totalKG;
        string exportDocs;
        uint256 timestamp;
        bytes32 previousStageHash;
    }
    
    mapping(string => ConsolidationData) public consolidationData;
    string[] public allConsolidatedBatchIds;
    
    address public procesamientoAddress;
    IProcesamiento procesamiento;
    
    event BatchConsolidated(string batchId, bytes32 consolidationHash);
    
    constructor(address _procesamientoAddress) {
        procesamientoAddress = _procesamientoAddress;
        procesamiento = IProcesamiento(_procesamientoAddress);
    }
    
    function consolidateBatch(
        string memory _batchId,
        uint256 _totalKG,
        string memory _exportDocs
    ) public {
        require(bytes(consolidationData[_batchId].batchId).length == 0, "Batch already consolidated");
        
        // Verificar que el lote existe en Procesamiento
        bytes32 previousHash = procesamiento.getProcessingHash(_batchId);
        
        consolidationData[_batchId] = ConsolidationData({
            batchId: _batchId,
            totalKG: _totalKG,
            exportDocs: _exportDocs,
            timestamp: block.timestamp,
            previousStageHash: previousHash
        });
        
        allConsolidatedBatchIds.push(_batchId);
        
        bytes32 consolidationHash = getConsolidationHash(_batchId);
        emit BatchConsolidated(_batchId, consolidationHash);
    }
    
    function getConsolidationHash(string memory _batchId) public view returns (bytes32) {
        ConsolidationData memory c = consolidationData[_batchId];
        require(bytes(c.batchId).length > 0, "Consolidation data does not exist");
        
        return keccak256(abi.encodePacked(
            c.batchId,
            c.totalKG,
            c.exportDocs,
            c.timestamp,
            c.previousStageHash
        ));
    }
    
    function getConsolidationInfo(string memory _batchId) public view returns (
        uint256 totalKG,
        string memory exportDocs,
        uint256 timestamp,
        bytes32 previousStageHash
    ) {
        ConsolidationData memory c = consolidationData[_batchId];
        require(bytes(c.batchId).length > 0, "Consolidation data does not exist");
        
        return (
            c.totalKG,
            c.exportDocs,
            c.timestamp,
            c.previousStageHash
        );
    }
    
    function getAllConsolidatedBatchIds() public view returns (string[] memory) {
        return allConsolidatedBatchIds;
    }
    
    function getTotalConsolidatedBatches() public view returns (uint256) {
        return allConsolidatedBatchIds.length;
    }
}
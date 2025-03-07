// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "0-Interfaces.sol";

contract Despacho {
    struct DispatchData {
        string batchId;
        string dispatchDetails;
        uint256 timestamp;
        bytes32 previousStageHash;
    }
    
    mapping(string => DispatchData) public dispatchData;
    string[] public allDispatchedBatchIds;
    
    address public consolidacionAddress;
    IConsolidacion consolidacion;
    
    event DispatchRecorded(string batchId, bytes32 dispatchHash);
    
    constructor(address _consolidacionAddress) {
        consolidacionAddress = _consolidacionAddress;
        consolidacion = IConsolidacion(_consolidacionAddress);
    }
    
    function recordDispatch(
        string memory _batchId,
        string memory _dispatchDetails
    ) public {
        require(bytes(dispatchData[_batchId].batchId).length == 0, "Dispatch already recorded");
        
        // Verificar que el lote existe en Consolidacion
        bytes32 previousHash = consolidacion.getConsolidationHash(_batchId);
        
        dispatchData[_batchId] = DispatchData({
            batchId: _batchId,
            dispatchDetails: _dispatchDetails,
            timestamp: block.timestamp,
            previousStageHash: previousHash
        });
        
        allDispatchedBatchIds.push(_batchId);
        
        bytes32 dispatchHash = getDispatchHash(_batchId);
        emit DispatchRecorded(_batchId, dispatchHash);
    }
    
    function getDispatchHash(string memory _batchId) public view returns (bytes32) {
        DispatchData memory d = dispatchData[_batchId];
        require(bytes(d.batchId).length > 0, "Dispatch data does not exist");
        
        return keccak256(abi.encodePacked(
            d.batchId,
            d.dispatchDetails,
            d.timestamp,
            d.previousStageHash
        ));
    }
    
    function getDispatchInfo(string memory _batchId) public view returns (
        string memory dispatchDetails,
        uint256 timestamp,
        bytes32 previousStageHash
    ) {
        DispatchData memory d = dispatchData[_batchId];
        require(bytes(d.batchId).length > 0, "Dispatch data does not exist");
        
        return (
            d.dispatchDetails,
            d.timestamp,
            d.previousStageHash
        );
    }
    
    function getAllDispatchedBatchIds() public view returns (string[] memory) {
        return allDispatchedBatchIds;
    }
    
    function getTotalDispatchedBatches() public view returns (uint256) {
        return allDispatchedBatchIds.length;
    }
}
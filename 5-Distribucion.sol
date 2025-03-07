// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "0-Interfaces.sol";

contract Distribucion {
    struct DistributionData {
        string batchId;
        string[] productIds;
        uint256 timestamp;
        bytes32 previousStageHash;
    }
    
    mapping(string => DistributionData) public distributionData;
    mapping(string => bool) public isProductIdRegistered;
    string[] public allDistributedBatchIds;
    
    address public despachoAddress;
    IDespacho despacho;
    
    event DistributionUpdated(string batchId, bytes32 distributionHash, string[] productIds);
    
    constructor(address _despachoAddress) {
        despachoAddress = _despachoAddress;
        despacho = IDespacho(_despachoAddress);
    }
    
    // Función para generar IDs de producto basados en hash
    function generateProductIds(string memory _batchId, uint256 _quantity) internal view returns (string[] memory) {
        string[] memory productIds = new string[](_quantity);
        
        for (uint256 i = 0; i < _quantity; i++) {
            // Combinamos varios factores para generar un hash único
            bytes32 hashValue = keccak256(abi.encodePacked(
                _batchId,
                i,
                block.timestamp,
                block.prevrandao,
                msg.sender
            ));
            
            // Convertimos el hash a un código alfanumérico corto (primeros 8 bytes)
            productIds[i] = string(abi.encodePacked(
                _batchId,
                "-",
                toHexString(uint256(hashValue) % 0xFFFFFFFF, 8)
            ));
        }
        
        return productIds;
    }
    
    // Función para convertir uint a string hexadecimal
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(length);
        for (uint256 i = length; i > 0; i--) {
            buffer[i - 1] = bytes1(uint8(
                48 + uint256(value & 0xf) + (((value & 0xf) >= 10) ? 39 : 0)
            ));
            value >>= 4;
        }
        return string(buffer);
    }
    
    function updateDistribution(
        string memory _batchId,
        uint256 _quantity
    ) public {
        require(bytes(distributionData[_batchId].batchId).length == 0, "Distribution already updated");
        
        // Verificar que el lote existe en Despacho
        bytes32 previousHash = despacho.getDispatchHash(_batchId);
        
        // Generar IDs de producto basados en hash
        string[] memory productIds = generateProductIds(_batchId, _quantity);
        
        // Registrar todos los IDs de producto generados
        for (uint256 i = 0; i < productIds.length; i++) {
            isProductIdRegistered[productIds[i]] = true;
        }
        
        distributionData[_batchId] = DistributionData({
            batchId: _batchId,
            productIds: productIds,
            timestamp: block.timestamp,
            previousStageHash: previousHash
        });
        
        allDistributedBatchIds.push(_batchId);
        
        bytes32 distributionHash = getDistributionHash(_batchId);
        emit DistributionUpdated(_batchId, distributionHash, productIds);
    }
    
    function getDistributionHash(string memory _batchId) public view returns (bytes32) {
        DistributionData memory d = distributionData[_batchId];
        require(bytes(d.batchId).length > 0, "Distribution data does not exist");
        
        return keccak256(abi.encodePacked(
            d.batchId,
            d.productIds.length,
            d.timestamp,
            d.previousStageHash
        ));
    }
    
    function getProductIdByIndex(string memory _batchId, uint256 _index) public view returns (string memory) {
        DistributionData memory d = distributionData[_batchId];
        require(bytes(d.batchId).length > 0, "Distribution data does not exist");
        require(_index < d.productIds.length, "Index out of bounds");
        
        return d.productIds[_index];
    }
    
    function getAllProductIds(string memory _batchId) public view returns (string[] memory) {
        DistributionData memory d = distributionData[_batchId];
        require(bytes(d.batchId).length > 0, "Distribution data does not exist");
        
        return d.productIds;
    }
    
    function isValidProductId(string memory _productId) public view returns (bool) {
        return isProductIdRegistered[_productId];
    }
    
    function getDistributionInfo(string memory _batchId) public view returns (
        uint256 productsCount,
        uint256 timestamp,
        bytes32 previousStageHash
    ) {
        DistributionData memory d = distributionData[_batchId];
        require(bytes(d.batchId).length > 0, "Distribution data does not exist");
        
        return (
            d.productIds.length,
            d.timestamp,
            d.previousStageHash
        );
    }
    
    function getAllDistributedBatchIds() public view returns (string[] memory) {
        return allDistributedBatchIds;
    }
    
    function getTotalDistributedBatches() public view returns (uint256) {
        return allDistributedBatchIds.length;
    }
}
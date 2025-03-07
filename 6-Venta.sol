// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "0-Interfaces.sol";

contract Venta {
    struct SaleData {
        string productId;
        string buyerInfo;        // Información del comprador (opcional)
        uint256 saleAmount;      // Monto de la venta
        uint256 timestamp;
        bytes32 previousStageHash;
    }
    
    mapping(string => SaleData) public saleData;
    string[] public allSoldProductIds;
    
    address public distribucionAddress;
    IDistribucion distribucion;
    
    event SaleRecorded(string productId, bytes32 saleHash);
    
    constructor(address _distribucionAddress) {
        distribucionAddress = _distribucionAddress;
        distribucion = IDistribucion(_distribucionAddress);
    }
    
    function recordSale(
        string memory _productId,
        string memory _buyerInfo,
        uint256 _saleAmount
    ) public {
        require(saleData[_productId].timestamp == 0, "Sale already recorded for this product");
        require(distribucion.isValidProductId(_productId), "Invalid product ID");
        
        // Verificar que el producto existe en Distribucion
        // No podemos obtener directamente el hash del producto, pero podemos verificar su validez
        bytes32 previousHash = keccak256(abi.encodePacked(_productId, distribucionAddress));
        
        saleData[_productId] = SaleData({
            productId: _productId,
            buyerInfo: _buyerInfo,
            saleAmount: _saleAmount,
            timestamp: block.timestamp,
            previousStageHash: previousHash
        });
        
        allSoldProductIds.push(_productId);
        
        bytes32 saleHash = getSaleHash(_productId);
        emit SaleRecorded(_productId, saleHash);
    }
    
    function getSaleHash(string memory _productId) public view returns (bytes32) {
        SaleData memory s = saleData[_productId];
        require(s.timestamp > 0, "Sale data does not exist");
        
        return keccak256(abi.encodePacked(
            s.productId,
            s.buyerInfo,
            s.saleAmount,
            s.timestamp,
            s.previousStageHash
        ));
    }
    
    function getSaleInfo(string memory _productId) public view returns (
        string memory buyerInfo,
        uint256 saleAmount,
        uint256 timestamp,
        bytes32 previousStageHash
    ) {
        SaleData memory s = saleData[_productId];
        require(s.timestamp > 0, "Sale data does not exist");
        
        return (
            s.buyerInfo,
            s.saleAmount,
            s.timestamp,
            s.previousStageHash
        );
    }
    
    function getAllSoldProductIds() public view returns (string[] memory) {
        return allSoldProductIds;
    }
    
    function getTotalSoldProducts() public view returns (uint256) {
        return allSoldProductIds.length;
    }
}
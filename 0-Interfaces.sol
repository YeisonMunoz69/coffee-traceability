// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Interfaces para verificación entre contratos
interface IRegistroFinca {
    function getBatchHash(string memory _batchId) external view returns (bytes32);
}

interface IProcesamiento {
    function getProcessingHash(string memory _batchId) external view returns (bytes32);
}

interface IConsolidacion {
    function getConsolidationHash(string memory _batchId) external view returns (bytes32);
}

interface IDespacho {
    function getDispatchHash(string memory _batchId) external view returns (bytes32);
}

interface IDistribucion {
    function getDistributionHash(string memory _batchId) external view returns (bytes32);
    function isValidProductId(string memory _productId) external view returns (bool);
}
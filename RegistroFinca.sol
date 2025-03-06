// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract RegistroFinca {
    struct Batch {
        string batchId;              // ID único del lote
        string producerName;         // Nombre del productor
        string farm;                 // Nombre de la finca
        string locationGPS;          // Ubicación GPS (coordenadas)
        string tastingResults;       // Resultados preliminares de la cata
        string humidityAnalysis;     // Análisis de humedad
        uint256 timestamp;           // Momento del registro
    }
    
    mapping(string => Batch) public batches;
    
    event BatchRegistered(string batchId, bytes32 batchHash);
    
    // Función para registrar el lote en la finca.
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
        bytes32 batchHash = keccak256(abi.encodePacked(
            _batchId,
            _producerName,
            _farm,
            _locationGPS,
            _tastingResults,
            _humidityAnalysis,
            block.timestamp
        ));
        emit BatchRegistered(_batchId, batchHash);
    }
    
    // Función auxiliar para obtener el hash del lote registrado.
    function getBatchHash(string memory _batchId) public view returns (bytes32) {
        Batch memory b = batches[_batchId];
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GreenFix {
    // 1. Definimos una estructura para el Proyecto
    struct Proyecto {
        uint256 id;
        address creador;
        string nombre;
        uint256 objetivoFinanciero;
        uint256 montoActual;
        uint256 toneladasCO2;
        bool completado;
    }

    // 2. Variables del contrato
    uint256 public contadorProyectos;
    mapping(uint256 => Proyecto) public proyectos;

    // 3. Evento para avisar al mundo cuando se crea un proyecto
    event ProyectoCreado(uint256 id, string nombre, uint256 objetivo);

    // 4. Función para registrar un nuevo bono/proyecto
    function registrarProyecto(string memory _nombre, uint256 _objetivo, uint256 _co2) public {
        contadorProyectos++;
        proyectos[contadorProyectos] = Proyecto(
            contadorProyectos,
            msg.sender,
            _nombre,
            _objetivo,
            0,
            _co2,
            false
        );
        emit ProyectoCreado(contadorProyectos, _nombre, _objetivo);
    }
}
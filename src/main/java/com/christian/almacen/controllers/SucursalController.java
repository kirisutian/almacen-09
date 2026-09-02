package com.christian.almacen.controllers;

import com.christian.almacen.dto.sucursales.SucursalRequest;
import com.christian.almacen.dto.sucursales.SucursalResponse;
import com.christian.almacen.services.sucursales.SucursalService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sucursales")
@AllArgsConstructor
@Validated
public class SucursalController {

    private final SucursalService sucursalService;

    @GetMapping
    @Operation(
            summary = "Listar sucursales",
            tags = { "Sucursales - Consultas" }
    )
    public ResponseEntity<List<SucursalResponse>> listar() {
        return ResponseEntity.ok(sucursalService.listar());
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Obtener sucursal por ID",
            tags = { "Sucursales - Consultas" }
    )
    public ResponseEntity<SucursalResponse> obtenerPorId(
            @PathVariable @Positive(message = "El ID debe ser positivo") Long id
    ) {
        return ResponseEntity.ok(sucursalService.obtenerPorId(id));
    }

    @PostMapping
    @Operation(
            summary = "Registrar una nueva sucursal",
            tags = { "Sucursales - Gestión" }
    )
    public ResponseEntity<SucursalResponse> registrar(
            @Valid @RequestBody SucursalRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(sucursalService.registrar(request));
    }

    @PutMapping("/{id}")
    @Operation(
            summary = "Actualizar una sucursal existente",
            tags = { "Sucursales - Gestión" }
    )
    public ResponseEntity<SucursalResponse> actualizar(
            @PathVariable @Positive(message = "El ID debe ser positivo") Long id,
            @Valid @RequestBody SucursalRequest request
    ) {
        return ResponseEntity.ok(sucursalService.actualizar(request, id));
    }

    @DeleteMapping("/{id}")
    @Operation(
            summary = "Elimar una sucursal",
            tags = { "Sucursales - Gestión" }
    )
    public ResponseEntity<Void> eliminar(
            @PathVariable @Positive(message = "El ID debe ser positivo") Long id
    ) {
        sucursalService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}

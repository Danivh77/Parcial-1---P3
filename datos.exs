# Integrantes: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate

defmodule Datos do

  @moduledoc """
  Módulo que contiene los datos de prueba para el programa.
  Semana de 6 días con 10 confeccionistas (5 con alquiler de máquina), 4 líneas
  de producción, 80 lotes válidos y 10 lotes inválidos (2 por cada motivo).
  -versión 1.0
  -autoras: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate
  -fecha: 2026-10-04
  """

  def confeccionistas do
    [
      %{codigo: "C01", nombre: "María Elena Ríos", alquiler: true},
      %{codigo: "C02", nombre: "Andrés Salazar", alquiler: false},
      %{codigo: "C03", nombre: "Luz Marina Cardona", alquiler: true},
      %{codigo: "C04", nombre: "Jhon Fredy Giraldo", alquiler: false},
      %{codigo: "C05", nombre: "Ana Milena Osorio", alquiler: true},
      %{codigo: "C06", nombre: "Carlos Arturo Montoya", alquiler: false},
      %{codigo: "C07", nombre: "Diana Patricia Londoño", alquiler: true},
      %{codigo: "C08", nombre: "Hernán Darío Quintero", alquiler: true},
      %{codigo: "C09", nombre: "Yuliana Castaño", alquiler: false},
      %{codigo: "C10", nombre: "Óscar Eduardo Ramírez", alquiler: false}
    ]
  end

  def lineas do
    [
      %{id: "L1", nombre: "Línea Norte", puestos: 6},
      %{id: "L2", nombre: "Línea Central", puestos: 4},
      %{id: "L3", nombre: "Línea Sur", puestos: 5},
      %{id: "L4", nombre: "Línea Oriente", puestos: 3}
    ]
  end

  def lotes do
    [
      # Día 1: lotes válidos
      %{confeccionista: "C01", linea: "L1", dia: 1, prendas: 70, defectos: 1.5},
      %{confeccionista: "C01", linea: "L2", dia: 1, prendas: 55, defectos: 7},
      %{confeccionista: "C03", linea: "L1", dia: 1, prendas: 29, defectos: 3.5},
      %{confeccionista: "C03", linea: "L1", dia: 1, prendas: 25, defectos: 3.5},
      %{confeccionista: "C04", linea: "L1", dia: 1, prendas: 60, defectos: 2},
      %{confeccionista: "C04", linea: "L1", dia: 1, prendas: 82, defectos: 5},
      %{confeccionista: "C04", linea: "L1", dia: 1, prendas: 93, defectos: 1},
      %{confeccionista: "C05", linea: "L1", dia: 1, prendas: 84, defectos: 6},
      %{confeccionista: "C05", linea: "L1", dia: 1, prendas: 85, defectos: 8},
      %{confeccionista: "C05", linea: "L2", dia: 1, prendas: 90, defectos: 12},
      %{confeccionista: "C06", linea: "L1", dia: 1, prendas: 33, defectos: 2},
      %{confeccionista: "C06", linea: "L3", dia: 1, prendas: 54, defectos: 15},
      %{confeccionista: "C06", linea: "L3", dia: 1, prendas: 36, defectos: 5},
      %{confeccionista: "C06", linea: "L4", dia: 1, prendas: 25, defectos: 1.5},
      %{confeccionista: "C07", linea: "L1", dia: 1, prendas: 77, defectos: 2},
      %{confeccionista: "C08", linea: "L1", dia: 1, prendas: 62, defectos: 8},
      %{confeccionista: "C08", linea: "L4", dia: 1, prendas: 45, defectos: 0.5},
      %{confeccionista: "C08", linea: "L4", dia: 1, prendas: 34, defectos: 3.5},
      %{confeccionista: "C09", linea: "L2", dia: 1, prendas: 91, defectos: 4},
      %{confeccionista: "C09", linea: "L3", dia: 1, prendas: 77, defectos: 1.5},
      %{confeccionista: "C09", linea: "L4", dia: 1, prendas: 82, defectos: 15},
      # Día 2: lotes válidos
      %{confeccionista: "C01", linea: "L1", dia: 2, prendas: 90, defectos: 12},
      %{confeccionista: "C02", linea: "L2", dia: 2, prendas: 52, defectos: 10},
      %{confeccionista: "C02", linea: "L4", dia: 2, prendas: 87, defectos: 3},
      %{confeccionista: "C04", linea: "L2", dia: 2, prendas: 45, defectos: 4.5},
      %{confeccionista: "C04", linea: "L2", dia: 2, prendas: 37, defectos: 0.5},
      %{confeccionista: "C04", linea: "L2", dia: 2, prendas: 74, defectos: 12},
      %{confeccionista: "C04", linea: "L4", dia: 2, prendas: 74, defectos: 2},
      %{confeccionista: "C04", linea: "L4", dia: 2, prendas: 98, defectos: 2},
      %{confeccionista: "C04", linea: "L4", dia: 2, prendas: 48, defectos: 2.5},
      %{confeccionista: "C05", linea: "L2", dia: 2, prendas: 26, defectos: 7},
      %{confeccionista: "C05", linea: "L4", dia: 2, prendas: 90, defectos: 3.5},
      %{confeccionista: "C06", linea: "L1", dia: 2, prendas: 35, defectos: 3},
      %{confeccionista: "C06", linea: "L1", dia: 2, prendas: 67, defectos: 5},
      %{confeccionista: "C06", linea: "L2", dia: 2, prendas: 56, defectos: 3.5},
      %{confeccionista: "C06", linea: "L3", dia: 2, prendas: 27, defectos: 3.5},
      %{confeccionista: "C07", linea: "L4", dia: 2, prendas: 41, defectos: 12},
      %{confeccionista: "C08", linea: "L1", dia: 2, prendas: 34, defectos: 1.5},
      %{confeccionista: "C08", linea: "L4", dia: 2, prendas: 52, defectos: 0.5},
      # Día 3: lotes válidos
      %{confeccionista: "C02", linea: "L1", dia: 3, prendas: 59, defectos: 9},
      %{confeccionista: "C02", linea: "L1", dia: 3, prendas: 85, defectos: 7},
      %{confeccionista: "C03", linea: "L1", dia: 3, prendas: 90, defectos: 4.5},
      %{confeccionista: "C03", linea: "L2", dia: 3, prendas: 54, defectos: 12},
      %{confeccionista: "C03", linea: "L3", dia: 3, prendas: 52, defectos: 3.5},
      %{confeccionista: "C03", linea: "L4", dia: 3, prendas: 31, defectos: 2},
      %{confeccionista: "C04", linea: "L1", dia: 3, prendas: 71, defectos: 2.5},
      %{confeccionista: "C04", linea: "L3", dia: 3, prendas: 80, defectos: 6},
      %{confeccionista: "C04", linea: "L3", dia: 3, prendas: 72, defectos: 15},
      %{confeccionista: "C05", linea: "L4", dia: 3, prendas: 57, defectos: 9},
      %{confeccionista: "C06", linea: "L1", dia: 3, prendas: 27, defectos: 1.5},
      %{confeccionista: "C06", linea: "L2", dia: 3, prendas: 70, defectos: 0.5},
      %{confeccionista: "C09", linea: "L2", dia: 3, prendas: 32, defectos: 1},
      %{confeccionista: "C09", linea: "L3", dia: 3, prendas: 91, defectos: 3},
      %{confeccionista: "C09", linea: "L3", dia: 3, prendas: 91, defectos: 2.5},
      # Día 4: lotes válidos
      %{confeccionista: "C03", linea: "L1", dia: 4, prendas: 36, defectos: 2},
      %{confeccionista: "C04", linea: "L1", dia: 4, prendas: 34, defectos: 10},
      %{confeccionista: "C04", linea: "L4", dia: 4, prendas: 50, defectos: 1},
      %{confeccionista: "C06", linea: "L3", dia: 4, prendas: 65, defectos: 8},
      %{confeccionista: "C06", linea: "L4", dia: 4, prendas: 67, defectos: 8},
      %{confeccionista: "C07", linea: "L1", dia: 4, prendas: 41, defectos: 6},
      %{confeccionista: "C07", linea: "L1", dia: 4, prendas: 85, defectos: 1.5},
      %{confeccionista: "C08", linea: "L1", dia: 4, prendas: 88, defectos: 0.5},
      %{confeccionista: "C08", linea: "L4", dia: 4, prendas: 99, defectos: 0.5},
      %{confeccionista: "C09", linea: "L1", dia: 4, prendas: 64, defectos: 6},
      %{confeccionista: "C09", linea: "L4", dia: 4, prendas: 84, defectos: 1.5},
      # Día 5: lotes válidos
      %{confeccionista: "C02", linea: "L2", dia: 5, prendas: 39, defectos: 12},
      %{confeccionista: "C02", linea: "L3", dia: 5, prendas: 36, defectos: 12},
      %{confeccionista: "C04", linea: "L3", dia: 5, prendas: 81, defectos: 12},
      %{confeccionista: "C05", linea: "L3", dia: 5, prendas: 76, defectos: 4.5},
      %{confeccionista: "C05", linea: "L4", dia: 5, prendas: 50, defectos: 3.5},
      %{confeccionista: "C06", linea: "L2", dia: 5, prendas: 50, defectos: 15},
      %{confeccionista: "C06", linea: "L4", dia: 5, prendas: 40, defectos: 2.5},
      %{confeccionista: "C08", linea: "L2", dia: 5, prendas: 99, defectos: 6},
      %{confeccionista: "C09", linea: "L3", dia: 5, prendas: 26, defectos: 7},
      # Día 6: lotes válidos
      %{confeccionista: "C03", linea: "L1", dia: 6, prendas: 60, defectos: 1},
      %{confeccionista: "C04", linea: "L1", dia: 6, prendas: 82, defectos: 12},
      %{confeccionista: "C05", linea: "L2", dia: 6, prendas: 42, defectos: 12},
      %{confeccionista: "C06", linea: "L2", dia: 6, prendas: 77, defectos: 8},
      %{confeccionista: "C07", linea: "L1", dia: 6, prendas: 33, defectos: 4.5},
      %{confeccionista: "C09", linea: "L3", dia: 6, prendas: 82, defectos: 6},

      # Lotes inválidos (errores de digitación), 2 por cada motivo de rechazo
      %{confeccionista: "C77", linea: "L1", dia: 2, prendas: 60, defectos: 3},   # :confeccionista_desconocido
      %{confeccionista: "C88", linea: "L3", dia: 5, prendas: 45, defectos: 1.5},   # :confeccionista_desconocido
      %{confeccionista: "C03", linea: "L9", dia: 1, prendas: 50, defectos: 2},   # :linea_desconocida
      %{confeccionista: "C05", linea: "L0", dia: 4, prendas: 70, defectos: 6},   # :linea_desconocida
      %{confeccionista: "C07", linea: "L2", dia: 0, prendas: 40, defectos: 2},   # :dia_invalido
      %{confeccionista: "C08", linea: "L4", dia: 7, prendas: 55, defectos: 4},   # :dia_invalido
      %{confeccionista: "C10", linea: "L1", dia: 3, prendas: 0, defectos: 2},   # :prendas_fuera_de_rango
      %{confeccionista: "C02", linea: "L3", dia: 6, prendas: 200, defectos: 3},   # :prendas_fuera_de_rango
      %{confeccionista: "C04", linea: "L2", dia: 2, prendas: 60, defectos: -5},   # :porcentaje_invalido
      %{confeccionista: "C06", linea: "L4", dia: 5, prendas: 75, defectos: 130}   # :porcentaje_invalido
    ]
  end
end

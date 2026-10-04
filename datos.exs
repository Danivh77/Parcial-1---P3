# Integrantes: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate

@moduledoc """
  Módulo que contiene los datos de prueba para el programa.
  -versión 1.0
  -autoras: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate
  -fecha: 2026-03-10
  """

defmodule Datos do

  def confeccionistas do
    [
      %{codigo: "C01", nombre: "María Elena Ríos", alquiler: true},
      %{codigo: "C02", nombre: "Andrés Salazar", alquiler: false}
    ]
  end

  def lineas do
    [
      %{id: "L1", nombre: "Linea Norte", puestos: 6},
      %{id: "L2", nombre: "Línea Central", puestos: 4}
    ]
  end

  def lotes do
    [
      %{confeccionista: "C01", linea: "L1", dia: 1,
        prendas: 70, defectos: 1.5},
      %{confeccionista: "C01", linea: "L2", dia: 1,
        prendas: 55, defectos: 7}
    ]
  end
end

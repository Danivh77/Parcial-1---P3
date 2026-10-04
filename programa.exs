# Integrantes: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate

defmodule Programa do
  @moduledoc """
  Módulo principal del programa de validación de lotes.
  -versión 1.0
  -autoras: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate
  -fecha: 2026-10-04
  """
  #Producción diaria informada por el taller aliado

  @taller_aliado %{1 => 550, 2 => 620, 3 => 480, 5 => 710, 7 => 200}

  @doc """
  Ejecución del programa completo
  """
  def main do
    # 1. Cargar las listas del módulo Datos
    confeccionistas = Datos.confeccionistas()
    lineas = Datos.lineas()
    lotes = Datos.lotes()

    # 2. Transformar a mapas indexados para las búsquedas
    confeccionistas_por_codigo =
      Map.new(confeccionistas, fn confeccionista ->
        {confeccionista.codigo, confeccionista}
      end)

    lineas_por_id =
      Map.new(lineas, fn linea ->
        {linea.id, linea}
      end)

    # 3. Validar usando los mapas
    {lotes_validos, rechazados} =
      Validacion.validar_lotes(
        lotes,
        confeccionistas_por_codigo,
        lineas_por_id
      )

    #4. Solicitar al usuario un lote adicional y validarlo
      {lotes_validos, rechazados} =
    solicitar_lote_adicional(
    lotes_validos,
    rechazados,
    confeccionistas_por_codigo,
    lineas_por_id
  )

  # 5. Calcular las liquidaciones con los lotes válidos actualizados
  liquidaciones =
    Liquidacion.liquidar_todos(confeccionistas, lotes_validos)

  # 6. Mostrar los ocho reportes
  Reportes.generar_todos(
    confeccionistas,
    lineas,
    rechazados,
    lotes_validos,
    liquidaciones
  )
  
  end

  @doc """
  Solicita al usuario un lote adicional y lo valida.
  """

  def solicitar_lote_adicional(
      lotes_validos,
      rechazados,
      confeccionistas_por_codigo,
      lineas_por_id
    ) do
  texto =
    Util.leer_linea(
      "Ingrese un lote (confeccionista;linea;dia;prendas;defectos)\n" <>
        "o Enter para omitir: "
    )

  if Util.vacio?(texto) do
    Util.mostrar_mensaje("Se omitió el lote adicional.")
    {lotes_validos, rechazados}
  else
    case Validacion.parsear_lote_adicional(texto) do
      {:ok, lote} ->
        case Validacion.validar_lote(
               lote,
               confeccionistas_por_codigo,
               lineas_por_id
             ) do
          {:ok, lote_valido} ->
            Util.mostrar_mensaje("Lote agregado correctamente.")
            {lotes_validos ++ [lote_valido], rechazados}

          {:error, motivo} ->
            Util.mostrar_mensaje("Lote rechazado: #{motivo}")
            {lotes_validos, rechazados ++ [{lote, motivo}]}
        end

      {:error, motivo} ->
        Util.mostrar_mensaje("Lote rechazado: #{motivo}")
        {lotes_validos, rechazados}
      end
    end
  end
end

Programa.main()

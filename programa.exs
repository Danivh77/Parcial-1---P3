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

      # 7. Rankings con keyword lists
    mostrar_ranking("Ranking por neto", Reportes.ranking(liquidaciones, []))
    mostrar_ranking("Top 3 por prendas", Reportes.ranking(liquidaciones, campo: :prendas, limite: 3))
    mostrar_ranking("Ranking por bruto ascendente", Reportes.ranking(liquidaciones, orden: :asc, campo: :bruto))

     # 8. combinar con la producción del taller aliado
    mostrar_taller_aliado(lotes_validos)

    # 9. Comprobante individual (siempre al final)
    solicitar_comprobante(lotes_validos, liquidaciones)

  end

    @doc """
  Imprime un ranking numerado, una línea por confeccionista.
  """
  def mostrar_ranking(titulo, ranking) do
    Util.mostrar_mensaje("\n#{titulo}")

    ranking
    |> Enum.with_index(1)
    |> Enum.each(fn {l, posicion} ->
      Util.mostrar_mensaje(
        "#{posicion}. #{l.nombre} (#{l.codigo}) | Prendas: #{l.prendas} | " <>
          "Lotes: #{Util.formatear_dinero(l.bruto)} | NETO: #{Util.formatear_dinero(l.neto)}"
      )
    end)
  end

  @doc """
  Combina la producción diaria de R3 con la del taller aliado usando
  `Map.merge/3` (se suman los días presentes en ambos mapas).
  """
  def mostrar_taller_aliado(lotes_validos) do
    combinada =
      lotes_validos
      |> Reportes.produccion_por_dia()
      |> Reportes.combinar_produccion(@taller_aliado)

    Util.mostrar_mensaje("\nC.2 - Producción combinada con el taller aliado:")

    combinada
    |> Enum.sort()
    |> Enum.each(fn {dia, prendas} ->
      Util.mostrar_mensaje("Día #{dia}: #{prendas} prendas")
    end)
  end

  @doc """
  Pide el código de un confeccionista e imprime su comprobante. Si el código
  no existe, lo informa sin provocar un error.
  """
  def solicitar_comprobante(lotes_validos, liquidaciones) do
    codigo = Util.leer_linea("\nIngrese el código de un confeccionista para su comprobante: ")

    case Reportes.calcular_comprobante(codigo, lotes_validos, liquidaciones) do
      {:ok, %{liquidacion: liq, detalle: detalle}} ->
        Util.mostrar_mensaje("\n=== COMPROBANTE: #{liq.nombre} (#{liq.codigo}) ===")

        Enum.each(detalle, fn fila ->
          Util.mostrar_mensaje(
            "Día #{fila.dia}: #{fila.prendas} prendas | " <>
              "Lotes: #{Util.formatear_dinero(fila.valor)} | " <>
              "Bonificación: #{Util.formatear_dinero(fila.bonificacion)}"
          )
        end)

        Util.mostrar_mensaje("Suma de lotes: #{Util.formatear_dinero(liq.bruto)}")
        Util.mostrar_mensaje("Suma de bonificaciones: #{Util.formatear_dinero(liq.bonificaciones)}")
        Util.mostrar_mensaje("Descuento por alquiler: #{Util.formatear_dinero(liq.descuento_alquiler)}")
        Util.mostrar_mensaje("NETO: #{Util.formatear_dinero(liq.neto)}")

      {:error, :confeccionista_desconocido} ->
        Util.mostrar_mensaje("No existe un confeccionista con el código \"#{codigo}\".")
    end
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

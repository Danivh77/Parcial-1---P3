# Integrantes: Laura Daniela Vega Herrera, Elizabeth Cuellar Vélez, Nikoll Alzate

defmodule Mediciones do
  @moduledoc """
  Mediciones de rendimiento de la Parte C.3 ("Medir en lugar de suponer").
  versión 1.0
  Autoras: Laura Daniela Vega Herrera, Elizabeth Cuéllar Vélez, Nikoll Alzate
  fecha: 2026-10-04
  """

  @cantidad_confeccionistas 100_000
  @cantidad_busquedas 1_000
  @tamano_lista 20_000
  @repeticiones 3

  # Punto de entrada (impuro: imprime)

  @doc """
  Ejecuta las dos comparaciones e imprime los resultados.
  """
  def ejecutar do
    mostrar_entorno()
    comparar_busquedas()
    comparar_construccion()
  end

  # Generación de datos (funciones puras)

  @doc """
  Genera `cantidad` confeccionistas con `Enum.map/2` sobre un rango.
  Los códigos tienen la forma "C000001", "C000002", ...
  """
  def generar_confeccionistas(cantidad) do
    Enum.map(1..cantidad, fn numero ->
      %{
        codigo: codigo(numero),
        nombre: "Confeccionista #{numero}",
        alquiler: rem(numero, 2) == 0
      }
    end)
  end

  @doc """
  Construye el código de un confeccionista a partir de su número.
  """
  def codigo(numero) do
    "C" <> String.pad_leading(Integer.to_string(numero), 6, "0")
  end

  @doc """
  Genera `cantidad` códigos al azar entre "C000001" y el código `maximo`.
  """
  def codigos_al_azar(cantidad, maximo) do
    Enum.map(1..cantidad, fn _ -> codigo(:rand.uniform(maximo)) end)
  end

  @doc """
  Convierte la lista de confeccionistas en un mapa indexado por código.
  """
  def indexar_por_codigo(confeccionistas) do
    Map.new(confeccionistas, fn confeccionista -> {confeccionista.codigo, confeccionista} end)
  end

  # Operaciones que se miden (funciones puras)

  @doc """
  Busca cada código en la lista recorriéndola con `Enum.find/2`.
  Cada búsqueda revisa, en promedio, la mitad de la lista.
  """
  def buscar_en_lista(confeccionistas, codigos) do
    Enum.map(codigos, fn codigo_buscado ->
      Enum.find(confeccionistas, fn confeccionista -> confeccionista.codigo == codigo_buscado end)
    end)
  end

  @doc """
  Busca cada código en el mapa con `Map.get/2`, sin recorrerlo.
  """
  def buscar_en_mapa(mapa_confeccionistas, codigos) do
    Enum.map(codigos, fn codigo_buscado -> Map.get(mapa_confeccionistas, codigo_buscado) end)
  end

  @doc """
  Construye una lista de `tamano` elementos agregando cada uno al final
  con `++`. Cada `++` copia toda la lista acumulada.
  """
  def construir_agregando_al_final(tamano) do
    Enum.reduce(1..tamano, [], fn elemento, lista -> lista ++ [elemento] end)
  end

  @doc """
  Construye una lista de `tamano` elementos agregando cada uno al inicio
  con `[elemento | lista]`. Cada operación crea un solo nodo nuevo.
  La lista queda en orden inverso.
  """
  def construir_agregando_al_inicio(tamano) do
    Enum.reduce(1..tamano, [], fn elemento, lista -> [elemento | lista] end)
  end

  @doc """
  Ejecuta `funcion` con `:timer.tc/1` y devuelve
  `{milisegundos, resultado}`. `:timer.tc/1` mide en microsegundos.
  """
  def medir(funcion) do
    {microsegundos, resultado} = :timer.tc(funcion)
    {microsegundos / 1000, resultado}
  end

  @doc """
  Cuenta cuántos resultados de búsqueda no son `nil`.
  """
  def contar_encontrados(resultados) do
    Enum.count(resultados, fn resultado -> resultado != nil end)
  end

  # Comparación 1: lista vs. mapa

  defp comparar_busquedas do
    FormatoMediciones.titulo(
      "COMPARACIÓN 1: buscar #{@cantidad_busquedas} códigos entre " <>
        "#{@cantidad_confeccionistas} confeccionistas"
    )

    {ms_generar, confeccionistas} =
      medir(fn -> generar_confeccionistas(@cantidad_confeccionistas) end)

    {ms_indexar, mapa} = medir(fn -> indexar_por_codigo(confeccionistas) end)

    IO.puts("Generar la lista:            #{FormatoMediciones.ms(ms_generar)} ms (una sola vez)")
    IO.puts("Construir el mapa indexado:  #{FormatoMediciones.ms(ms_indexar)} ms (una sola vez)\n")

    filas =
      Enum.map(1..@repeticiones, fn repeticion ->
        # Mismos códigos para la lista y el mapa, nuevos en cada repetición.
        codigos = codigos_al_azar(@cantidad_busquedas, @cantidad_confeccionistas)

        {ms_lista, encontrados_lista} = medir(fn -> buscar_en_lista(confeccionistas, codigos) end)
        {ms_mapa, encontrados_mapa} = medir(fn -> buscar_en_mapa(mapa, codigos) end)

        # Comprobación: ambas estructuras deben encontrar los mismos códigos.
        coinciden = encontrados_lista == encontrados_mapa
        {repeticion, ms_lista, ms_mapa, coinciden, contar_encontrados(encontrados_mapa)}
      end)

    FormatoMediciones.imprimir_tabla("Lista (Enum.find)", "Mapa (Map.get)", filas)
  end

  # Comparación 2: ++ al final vs. [elemento | lista]

  defp comparar_construccion do
    FormatoMediciones.titulo("COMPARACIÓN 2: construir una lista de #{@tamano_lista} elementos")

    filas =
      Enum.map(1..@repeticiones, fn repeticion ->
        {ms_final, lista_final} = medir(fn -> construir_agregando_al_final(@tamano_lista) end)
        {ms_inicio, lista_inicio} = medir(fn -> construir_agregando_al_inicio(@tamano_lista) end)

        # Comprobación: mismos elementos, en orden inverso.
        coinciden = lista_final == Enum.reverse(lista_inicio)
        {repeticion, ms_final, ms_inicio, coinciden, length(lista_inicio)}
      end)

    FormatoMediciones.imprimir_tabla("Al final (++)", "Al inicio ([h | t])", filas)
  end

  # Entorno de ejecución

  defp mostrar_entorno do
    FormatoMediciones.titulo("ENTORNO DE EJECUCIÓN")
    IO.puts("Elixir:        #{System.version()}")
    IO.puts("Erlang/OTP:    #{System.otp_release()}")
    IO.puts("Arquitectura:  #{:erlang.system_info(:system_architecture)}")
    IO.puts("Núcleos:       #{System.schedulers_online()}")
    IO.puts("Computador:    (escriban aquí el modelo, procesador y RAM)")
  end
end

defmodule FormatoMediciones do
  @moduledoc """
  Funciones de formato usadas solo por `Mediciones`. Se mantienen aparte
  para que `mediciones.exs` no dependa de los módulos compilados del
  programa.
  """

  @doc """
  Imprime un título de sección.
  """
  def titulo(texto) do
    IO.puts("\n===== #{texto} =====\n")
  end

  @doc """
  Da formato a milisegundos con tres decimales.
  """
  def ms(milisegundos) do
    :erlang.float_to_binary(milisegundos * 1.0, decimals: 3)
  end

  @doc """
  Imprime la tabla de una comparación. Cada fila es
  `{repeticion, ms_a, ms_b, coinciden, cantidad}`.
  """
  def imprimir_tabla(nombre_a, nombre_b, filas) do
    ancho = 26

    IO.puts(
      String.pad_trailing("Repetición", 12) <>
        String.pad_leading(nombre_a <> " ms", ancho) <>
        String.pad_leading(nombre_b <> " ms", ancho) <>
        String.pad_leading("Veces más rápido", 18) <>
        String.pad_leading("Comprobación", 16)
    )

    Enum.each(filas, fn {repeticion, ms_a, ms_b, coinciden, cantidad} ->
      comprobacion = if coinciden, do: "OK (#{cantidad})", else: "DIFERENTE"

      IO.puts(
        String.pad_trailing("#{repeticion}", 12) <>
          String.pad_leading(ms(ms_a), ancho) <>
          String.pad_leading(ms(ms_b), ancho) <>
          String.pad_leading(razon(ms_a, ms_b), 18) <>
          String.pad_leading(comprobacion, 16)
      )
    end)

    promedio_a = promedio(Enum.map(filas, fn {_, ms_a, _, _, _} -> ms_a end))
    promedio_b = promedio(Enum.map(filas, fn {_, _, ms_b, _, _} -> ms_b end))

    IO.puts(
      String.pad_trailing("Promedio", 12) <>
        String.pad_leading(ms(promedio_a), ancho) <>
        String.pad_leading(ms(promedio_b), ancho) <>
        String.pad_leading(razon(promedio_a, promedio_b), 18)
    )
  end

  defp promedio(valores), do: Enum.sum(valores) / length(valores)

  # Cuántas veces es más rápida la opción B que la A.
  defp razon(_ms_a, ms_b) when ms_b == 0, do: "—"
  defp razon(ms_a, ms_b), do: :erlang.float_to_binary(ms_a / ms_b, decimals: 1) <> "x"
end

Mediciones.ejecutar()

extends Node2D

# ============================================================
# CONFIGURACIÓN DEL TABLERO
# ============================================================

# Cantidad inicial de monedas.
@export var cantidad_monedas := 12

# Distancia desde el centro del tablero hasta las monedas.
@export var radio := 200.0

# ============================================================
# INFORMACIÓN DEL JUEGO
# ============================================================

# Indica qué jugador tiene el turno.
# 1 = Jugador 1
# 2 = Jugador 2
var jugador_actual := 1

# Contiene todas las monedas creadas por el Board.
var monedas = []

# Contiene las monedas que el jugador seleccionó
# durante el turno actual.
# Como máximo podremos tener 2.
var monedas_seleccionadas = []

# ============================================================
# ESCENA DE LA MONEDA
# ============================================================

# Cargamos la escena Moneda.tscn.
var moneda_scene = preload("res://Scene/Moneda.tscn")

# ============================================================
# ELEMENTOS DE LA INTERFAZ
# ============================================================

# Label que muestra de quién es el turno.
@onready var label_turno = $"../UI/LabelTurno"

# Label que muestra cuántas monedas quedan.
@onready var label_monedas = $"../UI/LabelMonedas"

# Label que muestra mensajes al jugador.
@onready var label_mensaje = $"../UI/LabelMensaje"

#Label de quien gano el juego
@onready var label_ganador = $"../UI/LabelGanador"

# Botón que confirma la jugada.
@onready var button_confirmar = $"../UI/ButtonConfirmarmar"

# Botón para reiniciar la partida.
@onready var button_reiniciar = $"../UI/ButtonReiniciar"

# Botón para volver al menú principal.
@onready var button_menu = $"../UI/ButtonMenu"

# ============================================================
# INICIO DEL JUEGO
# ============================================================

func _ready():

	# Creamos las monedas.
	crear_monedas()

	# Actualizamos la información de la interfaz.
	actualizar_interfaz()

	# Mostramos el mensaje inicial.
	label_mensaje.text = "Seleccioná una o dos monedas"

	# Conectamos el botón Confirmar.
	button_confirmar.pressed.connect(_on_button_confirmar_pressed)

	# Conectamos el botón Reiniciar.
	button_reiniciar.pressed.connect(_on_button_reiniciar_pressed)

	# Conectamos el botón Menú.
	button_menu.pressed.connect(_on_button_menu_pressed)

# ============================================================
# CREAR LAS MONEDAS
# ============================================================

func crear_monedas():

	# Repetimos el proceso tantas veces como monedas
	# hayamos configurado.
	for i in range(cantidad_monedas):

		# Creamos una instancia nueva de Moneda.tscn.
		var moneda = moneda_scene.instantiate()

		# Le asignamos su número.
		#
		# Primera moneda → 0
		# Segunda moneda → 1
		# ...
		# Última moneda → 11
		moneda.indice = i

		# Conectamos la señal de la moneda con el Board.
		# Cuando la moneda reciba un clic,
		# se ejecutará _on_moneda_presionada().
		moneda.moneda_presionada.connect(_on_moneda_presionada)

		# Calculamos el ángulo que tendrá esta moneda.
		var angulo = TAU * i / cantidad_monedas

		# Calculamos su posición dentro del círculo.
		moneda.position = Vector2(
			cos(angulo),
			sin(angulo)
		) * radio

		# Agregamos la moneda como hija del Board.
		add_child(moneda)

		# Guardamos una referencia a la moneda.
		monedas.append(moneda)


# ============================================================
# CUANDO EL JUGADOR PRESIONA UNA MONEDA
# ============================================================

func _on_moneda_presionada(moneda):

	# --------------------------------------------------------
	# CASO 1:
	# La moneda ya estaba seleccionada.
	# --------------------------------------------------------

	if moneda in monedas_seleccionadas:

		# La quitamos de la lista.
		monedas_seleccionadas.erase(moneda)

		# La mostramos nuevamente como no seleccionada.
		moneda.cambiar_seleccion()

		# Avisamos al jugador.
		label_mensaje.text = "Moneda deseleccionada"

		return


	# --------------------------------------------------------
	# CASO 2:
	# Ya tenemos 2 monedas seleccionadas.
	# --------------------------------------------------------

	if monedas_seleccionadas.size() >= 2:

		label_mensaje.text = "Solo podés seleccionar 2 monedas"

		return


	# --------------------------------------------------------
	# CASO 3:
	# Todavía no tenemos ninguna moneda seleccionada.
	# --------------------------------------------------------

	if monedas_seleccionadas.size() == 0:

		# Agregamos la moneda a la lista.
		monedas_seleccionadas.append(moneda)

		# La marcamos visualmente.
		moneda.cambiar_seleccion()

		# Informamos al jugador.
		label_mensaje.text = "Seleccionaste una moneda"
		return

	# --------------------------------------------------------
	# CASO 4:
	# Ya tenemos una moneda y queremos seleccionar otra.
	# --------------------------------------------------------

	var primera_moneda = monedas_seleccionadas[0]

	# Comprobamos si la nueva moneda está tocando
	# a la primera moneda.
	if son_adyacentes(primera_moneda, moneda):

		# Si son adyacentes, agregamos la segunda moneda.
		monedas_seleccionadas.append(moneda)

		# La marcamos visualmente.
		moneda.cambiar_seleccion()

		# Informamos al jugador.
		label_mensaje.text = "Seleccionaste dos monedas adyacentes"

	else:

		# Si no son adyacentes, no permitimos seleccionarla.
		label_mensaje.text = "Las monedas deben estar juntas"

# ============================================================
# COMPROBAR ADYACENCIA
# ============================================================

func son_adyacentes(moneda_a, moneda_b) -> bool:

	# Obtenemos la distancia entre las dos monedas.
	var distancia = moneda_a.position.distance_to(moneda_b.position)

	# Calculamos cuánto deberían medir aproximadamente
	# dos monedas que se están tocando.
	# Este valor tendremos que ajustarlo dependiendo
	# del tamaño real de tu Sprite.
	var distancia_adyacente = 180.0 

	# Si la distancia es menor o igual al límite,
	# consideramos que las monedas están tocándose.
	return distancia <= distancia_adyacente

# ============================================================
# CONFIRMAR JUGADA
# ============================================================

func _on_button_confirmar_pressed():
	# Comprobamos que haya al menos una moneda seleccionada.
	if monedas_seleccionadas.size() == 0:
		label_mensaje.text = "Tenés que seleccionar una moneda"
		return

	# --------------------------------------------------------
	# ELIMINAR LAS MONEDAS SELECCIONADAS
	# --------------------------------------------------------
	for moneda in monedas_seleccionadas:
		# Eliminamos la moneda de la escena.
		moneda.queue_free()
		# La quitamos de la lista general.
		monedas.erase(moneda)
		# Reducimos el contador.
		cantidad_monedas -= 1
	# --------------------------------------------------------
	# LIMPIAR LA SELECCIÓN
	# --------------------------------------------------------
	# Ya procesamos las monedas.
	# Por eso vaciamos la lista.
	monedas_seleccionadas.clear()

	# --------------------------------------------------------
	# COMPROBAR SI TERMINÓ LA PARTIDA
	# --------------------------------------------------------

	# Llamamos a ganador() antes de cambiar el turno.
	# Esto es importante porque jugador_actual todavía
	# representa al jugador que acaba de realizar la jugada.
	if ganador():
		return

	# --------------------------------------------------------
	# ACTUALIZAR EL JUEGO
	# --------------------------------------------------------
	# Si todavía quedan monedas, cambiamos de jugador.
	cambiar_turno()
	# Actualizamos los textos.
	actualizar_interfaz()
	
func cambiar_turno():
	# Si está jugando el Jugador 1...
	if jugador_actual == 1:
		# Ahora juega el Jugador 2.
		jugador_actual = 2
	
	else:
		# De lo contrario, vuelve a jugar el Jugador 1.
		jugador_actual = 1

func ganador() -> bool:

	# Comprobamos si ya no quedan monedas.
	if cantidad_monedas == 0:

		# Mostramos un mensaje grande indicando
		# quién ganó la partida.
		label_ganador.text = "🏆 ¡GANÓ EL JUGADOR " + str(jugador_actual) + "! 🏆"

		# Mostramos el mensaje de final de partida.
		label_mensaje.text = "¡Fin de la partida!"

		# Desactivamos el botón Confirmar porque
		# la partida ya terminó.
		button_confirmar.disabled = true

		# Mostramos el botón para reiniciar.
		button_reiniciar.visible = true

		# Mostramos el botón para volver al menú.
		button_menu.visible = true

		# Mostramos el mensaje del ganador.
		label_ganador.visible = true

		# Indicamos que la partida terminó.
		return true

	# Si todavía quedan monedas,
	# no hay ganador.
	return false
	
# ============================================================
# ACTUALIZAR INTERFAZ
# ============================================================

func actualizar_interfaz():
	# Mostramos quién está jugando.
	label_turno.text = "Turno: Jugador " + str(jugador_actual)

	# Mostramos cuántas monedas quedan.
	label_monedas.text = "Monedas: " + str(cantidad_monedas)

# ============================================================
# REINICIAR PARTIDA
# ============================================================

func _on_button_reiniciar_pressed():

	# Volvemos a cargar la escena actual.
	# Esto hace que el juego empiece nuevamente
	# desde cero.
	get_tree().reload_current_scene()

# ============================================================
# VOLVER AL MENÚ
# ============================================================

func _on_button_menu_pressed():
	# Cambiamos de la escena del juego
	# a la escena del menú principal.
	get_tree().change_scene_to_file("res://Scene/Menu.tscn")

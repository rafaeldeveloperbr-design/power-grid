# SkillTreeUI.gd
extends PanelContainer

signal habilidade_escolhida(habilidade_id: String)

var categoria_atual: String = "todas"
var botoes_habilidades: Array[Button] = []

@onready var label_titulo: Label = $VBoxContainer/LabelTitulo
@onready var lista_habilidades: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer
@onready var label_pontos: Label = $VBoxContainer/HBoxContainer2/LabelPontos
@onready var btn_fechar: Button = $VBoxContainer/HBoxContainer2/BotaoFechar

@onready var btn_todas: Button = $VBoxContainer/HBoxCategorias/BotaoTodas
@onready var btn_solar: Button = $VBoxContainer/HBoxCategorias/BotaoSolar
@onready var btn_eolica: Button = $VBoxContainer/HBoxCategorias/BotaoEolica
@onready var btn_ambiental: Button = $VBoxContainer/HBoxCategorias/BotaoAmbiental
@onready var btn_economia: Button = $VBoxContainer/HBoxCategorias/BotaoEconomia
@onready var btn_geral: Button = $VBoxContainer/HBoxCategorias/BotaoGeral


func _ready() -> void:
	visible = false
	
	if btn_fechar:
		btn_fechar.pressed.connect(_on_fechar_pressed)
	
	if btn_todas: btn_todas.pressed.connect(func(): _filtrar_categoria("todas"))
	if btn_solar: btn_solar.pressed.connect(func(): _filtrar_categoria("solar"))
	if btn_eolica: btn_eolica.pressed.connect(func(): _filtrar_categoria("eolica"))
	if btn_ambiental: btn_ambiental.pressed.connect(func(): _filtrar_categoria("ambiental"))
	if btn_economia: btn_economia.pressed.connect(func(): _filtrar_categoria("economia"))
	if btn_geral: btn_geral.pressed.connect(func(): _filtrar_categoria("geral"))
	
	if SkillTreeManager.has_signal("pontos_mudou"):
		SkillTreeManager.pontos_mudou.connect(_atualizar_pontos)


func abrir():
	visible = true
	_atualizar_pontos(SkillTreeManager.pontos_disponiveis)
	
	if SkillTreeManager.pontos_disponiveis <= 0:
		label_titulo.text = " Sem pontos! Migre de cidade para ganhar mais."
	else:
		label_titulo.text = " Árvore de Habilidades"
	
	_renderizar_habilidades()


func fechar():
	visible = false


func _filtrar_categoria(categoria: String):
	categoria_atual = categoria
	
	for btn in [btn_todas, btn_solar, btn_eolica, btn_ambiental, btn_economia, btn_geral]:
		if btn:
			btn.modulate = Color(1, 1, 1)
	
	match categoria:
		"todas": if btn_todas: btn_todas.modulate = Color(0.6, 1.0, 0.6)
		"solar": if btn_solar: btn_solar.modulate = Color(0.6, 1.0, 0.6)
		"eolica": if btn_eolica: btn_eolica.modulate = Color(0.6, 1.0, 0.6)
		"ambiental": if btn_ambiental: btn_ambiental.modulate = Color(0.6, 1.0, 0.6)
		"economia": if btn_economia: btn_economia.modulate = Color(0.6, 1.0, 0.6)
		"geral": if btn_geral: btn_geral.modulate = Color(0.6, 1.0, 0.6)
	
	_renderizar_habilidades()


func _renderizar_habilidades():
	if not lista_habilidades:
		push_error("lista_habilidades não encontrada!")
		return
	
	for btn in botoes_habilidades:
		btn.queue_free()
	botoes_habilidades.clear()
	
	var habilidades_filtradas = []
	for hab in SkillTreeManager.HABILIDADES:
		if categoria_atual == "todas" or hab.arvore == categoria_atual:
			habilidades_filtradas.append(hab)
	
	for hab in habilidades_filtradas:
		var btn = _criar_botao_habilidade(hab)
		lista_habilidades.add_child(btn)
		botoes_habilidades.append(btn)


func _criar_botao_habilidade(hab: Dictionary) -> Button:
	var btn = Button.new()
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	var desbloqueada = SkillTreeManager.desbloqueadas.get(hab.id, false)
	var pode_desbloquear = SkillTreeManager.pode_desbloquear(hab.id)
	var requisitos_faltantes = _get_requisitos_faltantes(hab)
	
	var texto = ""
	if desbloqueada:
		texto = "✅ %s\n   %s" % [hab.nome, hab.desc]
		btn.disabled = true
		btn.modulate = Color(0.6, 1.0, 0.6, 0.7)
	elif pode_desbloquear:
		texto = " %s (Custo: %d ponto)\n   %s\n   CLIQUE PARA DESBLOQUEAR!" % [hab.nome, hab.custo, hab.desc]
		btn.pressed.connect(func(): _desbloquear_habilidade(hab.id))
		btn.modulate = Color(1.0, 1.0, 0.6)
	else:
		texto = "🔒 %s\n   %s\n   Requisitos: %s" % [hab.nome, hab.desc, requisitos_faltantes]
		btn.disabled = true
		btn.modulate = Color(0.7, 0.7, 0.7)
	
	btn.text = texto
	return btn


func _get_requisitos_faltantes(hab: Dictionary) -> String:
	var faltantes = []
	for req_id in hab.requer:
		if not SkillTreeManager.desbloqueadas.get(req_id, false):
			var req_hab = SkillTreeManager._get_habilidade(req_id)
			if not req_hab.is_empty():
				faltantes.append(req_hab.nome)
	return ", ".join(faltantes) if faltantes else "Nenhum"


func _desbloquear_habilidade(id: String):
	if SkillTreeManager.desbloquear(id):
		_atualizar_pontos(SkillTreeManager.pontos_disponiveis)
		_renderizar_habilidades()
		habilidade_escolhida.emit(id)
		
		if SkillTreeManager.pontos_disponiveis <= 0:
			await get_tree().create_timer(1.5).timeout
			fechar()


func _atualizar_pontos(pontos: int):
	if label_pontos:
		label_pontos.text = " Pontos disponíveis: %d" % pontos


func _on_fechar_pressed():
	fechar()

# AchievementManager.gd - V2 com 10/25/50 para TODOS os geradores
extends Node

signal conquista_desbloqueada(mensagem: String)

const CONQUISTAS: Array[Dictionary] = [
	# Solar
	{"chave": "solar_10", "nome": "Sol Brilha I", "desc": "10 Painéis Solares", "tipo": "solar", "meta": 10, "bonus": "producao_solar"},
	{"chave": "solar_25", "nome": "Sol Brilha II", "desc": "25 Painéis Solares", "tipo": "solar", "meta": 25, "bonus": "producao_solar"},
	{"chave": "solar_50", "nome": "Sol Brilha III", "desc": "50 Painéis Solares", "tipo": "solar", "meta": 50, "bonus": "producao_solar"},
	# Eólica
	{"chave": "eolica_10", "nome": "Vento Forte I", "desc": "10 Turbinas", "tipo": "eolica", "meta": 10, "bonus": "producao_eolica"},
	{"chave": "eolica_25", "nome": "Vento Forte II", "desc": "25 Turbinas", "tipo": "eolica", "meta": 25, "bonus": "producao_eolica"},
	{"chave": "eolica_50", "nome": "Vento Forte III", "desc": "50 Turbinas", "tipo": "eolica", "meta": 50, "bonus": "producao_eolica"},
	# Carvão - sujo mas barato
	{"chave": "carvao_10", "nome": "Rei do Carvão I", "desc": "10 Usinas a Carvão", "tipo": "carvao", "meta": 10, "bonus": "producao_carvao"},
	{"chave": "carvao_25", "nome": "Rei do Carvão II", "desc": "25 Usinas a Carvão", "tipo": "carvao", "meta": 25, "bonus": "producao_carvao"},
	{"chave": "carvao_50", "nome": "Rei do Carvão III", "desc": "50 Usinas a Carvão", "tipo": "carvao", "meta": 50, "bonus": "producao_carvao"},
	# Geotérmica
	{"chave": "geotermica_10", "nome": "Calor da Terra I", "desc": "10 Geotérmicas", "tipo": "geotermica", "meta": 10, "bonus": "producao_geotermica"},
	{"chave": "geotermica_25", "nome": "Calor da Terra II", "desc": "25 Geotérmicas", "tipo": "geotermica", "meta": 25, "bonus": "producao_geotermica"},
	{"chave": "geotermica_50", "nome": "Calor da Terra III", "desc": "50 Geotérmicas", "tipo": "geotermica", "meta": 50, "bonus": "producao_geotermica"},
	# Biomassa - limpa
	{"chave": "biomassa_10", "nome": "Eco Warrior I", "desc": "10 Biomassa", "tipo": "biomassa", "meta": 10, "bonus": "producao_biomassa"},
	{"chave": "biomassa_25", "nome": "Eco Warrior II", "desc": "25 Biomassa", "tipo": "biomassa", "meta": 25, "bonus": "producao_biomassa"},
	{"chave": "biomassa_50", "nome": "Eco Warrior III", "desc": "50 Biomassa", "tipo": "biomassa", "meta": 50, "bonus": "producao_biomassa"},
	# Hidrelétrica
	{"chave": "hidreletrica_10", "nome": "Força das Águas I", "desc": "10 Hidrelétricas", "tipo": "hidreletrica", "meta": 10, "bonus": "producao_hidreletrica"},
	{"chave": "hidreletrica_25", "nome": "Força das Águas II", "desc": "25 Hidrelétricas", "tipo": "hidreletrica", "meta": 25, "bonus": "producao_hidreletrica"},
	{"chave": "hidreletrica_50", "nome": "Força das Águas III", "desc": "50 Hidrelétricas", "tipo": "hidreletrica", "meta": 50, "bonus": "producao_hidreletrica"},
	# Nuclear
	{"chave": "nuclear_10", "nome": "Átomo I", "desc": "10 Reatores", "tipo": "nuclear", "meta": 10, "bonus": "producao_nuclear"},
	{"chave": "nuclear_25", "nome": "Átomo II", "desc": "25 Reatores", "tipo": "nuclear", "meta": 25, "bonus": "producao_nuclear"},
	{"chave": "nuclear_50", "nome": "Átomo III", "desc": "50 Reatores", "tipo": "nuclear", "meta": 50, "bonus": "producao_nuclear"},
	
	# Fusao
	{"chave": "fusao_10", "nome": "Poder das Estrelas I", "desc": "10 Reatores de Fusão", "tipo": "fusao", "meta": 10, "bonus": "producao_fusao"},
	{"chave": "fusao_25", "nome": "Poder das Estrelas II", "desc": "25 Reatores de Fusão", "tipo": "fusao", "meta": 25, "bonus": "producao_fusao"},
	{"chave": "fusao_50", "nome": "Poder das Estrelas III", "desc": "50 Reatores de Fusão", "tipo": "fusao", "meta": 50, "bonus": "producao_fusao"},
	
	# Bateria
	{"chave": "bateria_10", "nome": "Reserva I", "desc": "10 Baterias", "tipo": "bateria", "meta": 10, "bonus": "capacidade_bateria"},
	{"chave": "bateria_25", "nome": "Reserva II", "desc": "25 Baterias", "tipo": "bateria", "meta": 25, "bonus": "capacidade_bateria"},
	{"chave": "bateria_50", "nome": "Reserva III", "desc": "50 Baterias", "tipo": "bateria", "meta": 50, "bonus": "capacidade_bateria"},
	# Upgrades manivela
	{"chave": "up_manivela_10", "nome": "Braço de Ferro", "desc": "Manivela Lvl 10", "tipo": "up_manivela", "meta": 10, "bonus": "poder_manivela"},
	{"chave": "up_manivela_25", "nome": "Hulk", "desc": "Manivela Lvl 25", "tipo": "up_manivela", "meta": 25, "bonus": "poder_manivela"},
]

var desbloqueadas: Dictionary = {}

func _ready() -> void:
	for c in CONQUISTAS:
		desbloqueadas[c.chave] = false

func verificar_marcos_e_conquistas() -> void:
	for conquista in CONQUISTAS:
		var chave: String = conquista.chave
		if desbloqueadas[chave]:
			continue
		var atual: int = GameState.get_quantidade(conquista.tipo)
		if atual >= conquista.meta:
			_desbloquear(conquista)

func _desbloquear(conquista: Dictionary) -> void:
	desbloqueadas[conquista.chave] = true
	GameState.aplicar_bonus_conquista(conquista.bonus)
	conquista_desbloqueada.emit("Marco: %s! %s - Produção dobrou!" % [conquista.nome, conquista.desc])

func renderizar_lista(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()
	for item in CONQUISTAS:
		var eh_desbloqueado: bool = desbloqueadas[item.chave]
		var qtd_atual: int = GameState.get_quantidade(item.tipo)
		var label_item = Label.new()
		label_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label_item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if eh_desbloqueado:
			label_item.text = "✅ %s [CONCLUÍDO]\n   %s\n " % [item.nome, item.desc]
			label_item.modulate = Color(0.6, 1.0, 0.6)
		else:
			label_item.text = "🔒 %s (%d/%d)\n   %s\n " % [item.nome, mini(qtd_atual, item.meta), item.meta, item.desc]
			label_item.modulate = Color(1, 1, 1, 0.7)
		container.add_child(label_item)

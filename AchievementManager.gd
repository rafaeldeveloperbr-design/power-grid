# AchievementManager.gd - Gerenciador de Conquistas
extends Node

signal conquista_desbloqueada(mensagem: String)

const CONQUISTAS: Array[Dictionary] = [
	{"chave": "solar_10", "nome": "Energia Limpa I", "desc": "10 Painéis Solares - Produção Solar dobra", "tipo": "solar", "meta": 10, "bonus": "producao_solar"},
	{"chave": "solar_25", "nome": "Energia Limpa II", "desc": "25 Painéis Solares - Produção Solar dobra", "tipo": "solar", "meta": 25, "bonus": "producao_solar"},
	{"chave": "solar_50", "nome": "Energia Limpa III", "desc": "50 Painéis Solares - Produção Solar dobra", "tipo": "solar", "meta": 50, "bonus": "producao_solar"},
	{"chave": "eolica_10", "nome": "Bons Ventos I", "desc": "10 Turbinas Eólicas - Produção Eólica dobra", "tipo": "eolica", "meta": 10, "bonus": "producao_eolica"},
	{"chave": "eolica_25", "nome": "Bons Ventos II", "desc": "25 Turbinas - Produção Eólica dobra", "tipo": "eolica", "meta": 25, "bonus": "producao_eolica"},
	{"chave": "eolica_50", "nome": "Bons Ventos III", "desc": "50 Turbinas - Produção Eólica dobra", "tipo": "eolica", "meta": 50, "bonus": "producao_eolica"},
	{"chave": "geotermica_10", "nome": "Calor Profundo I", "desc": "10 Geotérmicas - Produção Geotérmica dobra", "tipo": "geotermica", "meta": 10, "bonus": "producao_geotermica"},
	{"chave": "geotermica_25", "nome": "Calor Profundo II", "desc": "25 Geotérmicas - Produção Geotérmica dobra", "tipo": "geotermica", "meta": 25, "bonus": "producao_geotermica"},
	{"chave": "geotermica_50", "nome": "Calor Profundo III", "desc": "50 Geotérmicas - Produção Geotérmica dobra", "tipo": "geotermica", "meta": 50, "bonus": "producao_geotermica"},
	{"chave": "nuclear_10", "nome": "Poder Atômico I", "desc": "10 Reatores - Produção Nuclear dobra", "tipo": "nuclear", "meta": 10, "bonus": "producao_nuclear"},
	{"chave": "nuclear_25", "nome": "Poder Atômico II", "desc": "25 Reatores - Produção Nuclear dobra", "tipo": "nuclear", "meta": 25, "bonus": "producao_nuclear"},
	{"chave": "nuclear_50", "nome": "Poder Atômico III", "desc": "50 Reatores - Produção Nuclear dobra", "tipo": "nuclear", "meta": 50, "bonus": "producao_nuclear"},
	{"chave": "bateria_10", "nome": "Reserva de Energia I", "desc": "10 Baterias - Capacidade dobra", "tipo": "bateria", "meta": 10, "bonus": "capacidade_bateria"},
	{"chave": "bateria_25", "nome": "Reserva de Energia II", "desc": "25 Baterias - Capacidade dobra", "tipo": "bateria", "meta": 25, "bonus": "capacidade_bateria"},
	{"chave": "bateria_50", "nome": "Reserva de Energia III", "desc": "50 Baterias - Capacidade dobra", "tipo": "bateria", "meta": 50, "bonus": "capacidade_bateria"},
	{"chave": "up_manivela_10", "nome": "Braço de Ferro", "desc": "Manivela Nível 10 - Força de clique dobra", "tipo": "up_manivela", "meta": 10, "bonus": "poder_manivela"},
	{"chave": "up_solar_10", "nome": "Alta Eficiência Solar", "desc": "Upgrade Solar Nível 10 - Solar dobra", "tipo": "up_solar", "meta": 10, "bonus": "producao_solar"},
	{"chave": "up_eolica_10", "nome": "Engrenagens de Titânio", "desc": "Upgrade Eólico Nível 10 - Eólica dobra", "tipo": "up_eolica", "meta": 10, "bonus": "producao_eolica"},
	{"chave": "up_geotermica_10", "nome": "Magma Domado", "desc": "Upgrade Geotérmico Nível 10 - Geotérmica dobra", "tipo": "up_geotermica", "meta": 10, "bonus": "producao_geotermica"},
	{"chave": "up_nuclear_10", "nome": "Mestre do Núcleo", "desc": "Upgrade Nuclear Nível 10 - Nuclear dobra", "tipo": "up_nuclear", "meta": 10, "bonus": "producao_nuclear"},
]

var desbloqueadas: Dictionary = {}

func _ready() -> void:
	for c in CONQUISTAS:
		desbloqueadas[c.chave] = false

func verificar_marcos_e_conquistas() -> void:
	# CORREÇÃO: usa IFs independentes, não ELIF - permite desbloquear 10,25,50 de uma vez
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
	conquista_desbloqueada.emit("Marco: %s! %s" % [conquista.nome, conquista.desc])
	print("Conquista desbloqueada: ", conquista.chave)

func esta_desbloqueada(chave: String) -> bool:
	return desbloqueadas.get(chave, false)

func renderizar_lista(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

	for item in CONQUISTAS:
		var eh_desbloqueado: bool = desbloqueadas[item.chave]
		var qtd_atual: int = GameState.get_quantidade(item.tipo)
		
		var label_item = Label.new()
		label_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label_item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label_item.add_theme_font_size_override("font_size", 14)
		
		if eh_desbloqueado:
			label_item.text = "✅ %s\n   %s [CONCLUÍDO]\n " % [item.nome, item.desc]
			label_item.modulate = Color(0.6, 1.0, 0.6)
		else:
			label_item.text = "🔒 %s (%d/%d)\n   %s\n " % [item.nome, mini(qtd_atual, item.meta), item.meta, item.desc]
			label_item.modulate = Color(1, 1, 1, 0.7)
			
		container.add_child(label_item)

# --- SAVE/LOAD seguro ---
func get_save_data() -> Dictionary:
	return desbloqueadas.duplicate()

func load_save_data(data: Dictionary):
	for chave in data.keys():
		if desbloqueadas.has(chave):
			desbloqueadas[chave] = data[chave]
	# Reaplicar bônus sem duplicar signal
	for conquista in CONQUISTAS:
		if desbloqueadas[conquista.chave]:
			var vezes = 1 # cada conquista só dá 1 nível de bônus
			if not GameState.bonus_conquistas.has(conquista.bonus):
				GameState.bonus_conquistas[conquista.bonus] = 0
			# Evita reaplicar se já foi aplicado no GameState
			# O GameState deve ser carregado antes
	GameState.recalcular_tudo()

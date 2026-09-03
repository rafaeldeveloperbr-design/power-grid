# AchievementManager.gd
extends Node

var marcos_atingidos = {
	"solar_10": false, "solar_25": false, "solar_50": false,
	"eolica_10": false, "eolica_25": false, "eolica_50": false,
	"geotermica_10": false, "geotermica_25": false, "geotermica_50": false,
	"nuclear_10": false, "nuclear_25": false, "nuclear_50": false,
	"bateria_10": false, "bateria_25": false, "bateria_50": false,
	"up_manivela_10": false, "up_solar_10": false, "up_eolica_10": false,
	"up_geotermica_10": false, "up_nuclear_10": false
}

var dados_conquistas = [
	{"chave": "solar_10", "nome": "Energia Limpa I", "desc": "Possua 10 Painéis Solares (Dobro de Prod.)", "tipo": "solar", "meta": 10},
	{"chave": "solar_25", "nome": "Energia Limpa II", "desc": "Possua 25 Painéis Solares (Dobro de Prod.)", "tipo": "solar", "meta": 25},
	{"chave": "solar_50", "nome": "Energia Limpa III", "desc": "Possua 50 Painéis Solares (Dobro de Prod.)", "tipo": "solar", "meta": 50},
	{"chave": "eolica_10", "nome": "Bons Ventos I", "desc": "Possua 10 Turbinas Eólicas (Dobro de Prod.)", "tipo": "eolica", "meta": 10},
	{"chave": "eolica_25", "nome": "Bons Ventos II", "desc": "Possua 25 Turbinas Eólicas (Dobro de Prod.)", "tipo": "eolica", "meta": 25},
	{"chave": "eolica_50", "nome": "Bons Ventos III", "desc": "Possua 50 Turbinas Eólicas (Dobro de Prod.)", "tipo": "eolica", "meta": 50},
	{"chave": "geotermica_10", "nome": "Calor Profundo I", "desc": "Possua 10 Usinas Geotérmicas (Dobro de Prod.)", "tipo": "geotermica", "meta": 10},
	{"chave": "geotermica_25", "nome": "Calor Profundo II", "desc": "Possua 25 Usinas Geotérmicas (Dobro de Prod.)", "tipo": "geotermica", "meta": 25},
	{"chave": "geotermica_50", "nome": "Calor Profundo III", "desc": "Possua 50 Usinas Geotérmicas (Dobro de Prod.)", "tipo": "geotermica", "meta": 50},
	{"chave": "nuclear_10", "nome": "Poder Atômico I", "desc": "Possua 10 Reatores Nucleares (Dobro de Prod.)", "tipo": "nuclear", "meta": 10},
	{"chave": "nuclear_25", "nome": "Poder Atômico II", "desc": "Possua 25 Reatores Nucleares (Dobro de Prod.)", "tipo": "nuclear", "meta": 25},
	{"chave": "nuclear_50", "nome": "Poder Atômico III", "desc": "Possua 50 Reatores Nucleares (Dobro de Prod.)", "tipo": "nuclear", "meta": 50},
	{"chave": "bateria_10", "nome": "Reserva de Energia I", "desc": "Possua 10 Baterias (Dobro de Capacidade Extra)", "tipo": "bateria", "meta": 10},
	{"chave": "bateria_25", "nome": "Reserva de Energia II", "desc": "Possua 25 Baterias (Dobro de Capacidade Extra)", "tipo": "bateria", "meta": 25},
	{"chave": "bateria_50", "nome": "Reserva de Energia III", "desc": "Possua 50 Baterias (Dobro de Capacidade Extra)", "tipo": "bateria", "meta": 50},
	{"chave": "up_manivela_10", "nome": "Braço de Ferro", "desc": "Manivela no Nível 10 (+100% Força de Clique)", "tipo": "up_manivela", "meta": 10},
	{"chave": "up_solar_10", "nome": "Alta Eficiência Solar", "desc": "Melhoria Solar no Nível 10 (Dobro de Prod. Solar)", "tipo": "up_solar", "meta": 10},
	{"chave": "up_eolica_10", "nome": "Engrenagens de Titânio", "desc": "Melhoria Eólica no Nível 10 (Dobro de Prod. Eólica)", "tipo": "up_eolica", "meta": 10},
	{"chave": "up_geotermica_10", "nome": "Magma Domado", "desc": "Melhoria Geotérmica no Nível 10 (Dobro de Prod. Geotérmica)", "tipo": "up_geotermica", "meta": 10},
	{"chave": "up_nuclear_10", "nome": "Mestre do Núcleo", "desc": "Melhoria Nuclear no Nível 10 (Dobro de Prod. Nuclear)", "tipo": "up_nuclear", "meta": 10}
]

signal conquista_desbloqueada(mensagem: String)

func verificar_marcos_e_conquistas() -> void:
	if GameState.paineis_solares >= 10 and not marcos_atingidos["solar_10"]:
		marcos_atingidos["solar_10"] = true
		GameState.producao_solar *= 2.0
		conquista_desbloqueada.emit("Marco: 10 Solares! Produção Solar Dobrou!")
	elif GameState.paineis_solares >= 25 and not marcos_atingidos["solar_25"]:
		marcos_atingidos["solar_25"] = true
		GameState.producao_solar *= 2.0
		conquista_desbloqueada.emit("Marco: 25 Solares! Produção Solar Dobrou!")
	elif GameState.paineis_solares >= 50 and not marcos_atingidos["solar_50"]:
		marcos_atingidos["solar_50"] = true
		GameState.producao_solar *= 2.0
		conquista_desbloqueada.emit("Marco: 50 Solares! Produção Solar Dobrou!")

	# Baterias
	if GameState.baterias >= 10 and not marcos_atingidos["bateria_10"]:
		marcos_atingidos["bateria_10"] = true
		GameState.capacidade_bateria *= 2.0
		conquista_desbloqueada.emit("Marco: 10 Baterias! Capacidade Extra Dobrou!")
	elif GameState.baterias >= 25 and not marcos_atingidos["bateria_25"]:
		marcos_atingidos["bateria_25"] = true
		GameState.capacidade_bateria *= 2.0
		conquista_desbloqueada.emit("Marco: 25 Baterias! Capacidade Extra Dobrou!")
	elif GameState.baterias >= 50 and not marcos_atingidos["bateria_50"]:
		marcos_atingidos["bateria_50"] = true
		GameState.capacidade_bateria *= 2.0
		conquista_desbloqueada.emit("Marco: 50 Baterias! Capacidade Extra Dobrou!")
		
	# Adicione os outros checadores de Eólica, Geotérmica, Nuclear e Upgrades aqui da mesma forma.

func renderizar_lista(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

	for item in dados_conquistas:
		var eh_desbloqueado = marcos_atingidos[item["chave"]]
		var qtd_atual = 0
		
		match item["tipo"]:
			"solar": qtd_atual = GameState.paineis_solares
			"eolica": qtd_atual = GameState.turbinas_eolicas
			"geotermica": qtd_atual = GameState.usinas_geotermicas
			"nuclear": qtd_atual = GameState.reatores_nucleares
			"bateria": qtd_atual = GameState.baterias
			"up_manivela": qtd_atual = GameState.nivel_manivela
			"up_solar": qtd_atual = GameState.nivel_solar_upgrade
			"up_eolica": qtd_atual = GameState.nivel_eolica_upgrade
			"up_geotermica": qtd_atual = GameState.nivel_geotermica_upgrade
			"up_nuclear": qtd_atual = GameState.nivel_nuclear_upgrade
			
		var label_item = Label.new()
		label_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label_item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		if eh_desbloqueado:
			label_item.text = "✅ %s\n   %s [CONCLUÍDO]\n " % [item["nome"], item["desc"]]
		else:
			label_item.text = "🔒 %s (%d/%d)\n   %s\n " % [item["nome"], min(qtd_atual, item["meta"]), item["meta"], item["desc"]]
			
		container.add_child(label_item)

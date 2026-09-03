extends Node2D

# --- RECURSOS ---
var ouro: float = 0.0
var energia_armazenada: float = 0.0

# --- OFERTA E DEMANDA ---
var demanda_cidade: float = 5.0
var oferta_atual: float = 0.0
var em_blackout: bool = false

# --- EVENTOS CLIMÁTICOS ---
enum Clima { NORMAL, TEMPESTADE, ECLIPSE, ONDA_DE_CALOR }
var clima_atual: Clima = Clima.NORMAL
var tempo_clima_restante: int = 0
var tempo_proximo_evento: int = 30 

var mult_eolica: float = 1.0
var mult_solar: float = 1.0

# --- MARCOS / CONQUISTAS (MILESTONES) ---
var marcos_atingidos = {
	# Geradores
	"solar_10": false, "solar_25": false, "solar_50": false,
	"eolica_10": false, "eolica_25": false, "eolica_50": false,
	"geotermica_10": false, "geotermica_25": false, "geotermica_50": false,
	"nuclear_10": false, "nuclear_25": false, "nuclear_50": false,
	# Upgrades Lvl 10
	"up_manivela_10": false,
	"up_solar_10": false,
	"up_eolica_10": false,
	"up_geotermica_10": false,
	"up_nuclear_10": false
}

var dados_conquistas = [
	# Geradores
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

	# Conquistas de Melhorias (Lvl 10)
	{"chave": "up_manivela_10", "nome": "Braço de Ferro", "desc": "Manivela no Nível 10 (+100% Força de Clique)", "tipo": "up_manivela", "meta": 10},
	{"chave": "up_solar_10", "nome": "Alta Eficiência Solar", "desc": "Melhoria Solar no Nível 10 (Dobro de Prod. Solar)", "tipo": "up_solar", "meta": 10},
	{"chave": "up_eolica_10", "nome": "Engrenagens de Titânio", "desc": "Melhoria Eólica no Nível 10 (Dobro de Prod. Eólica)", "tipo": "up_eolica", "meta": 10},
	{"chave": "up_geotermica_10", "nome": "Magma Domado", "desc": "Melhoria Geotérmica no Nível 10 (Dobro de Prod. Geotérmica)", "tipo": "up_geotermica", "meta": 10},
	{"chave": "up_nuclear_10", "nome": "Mestre do Núcleo", "desc": "Melhoria Nuclear no Nível 10 (Dobro de Prod. Nuclear)", "tipo": "up_nuclear", "meta": 10}
]

var mensagem_conquista: String = ""
var tempo_mensagem_conquista: int = 0

# --- CICLO DIA / NOITE ---
var eh_dia: bool = true
var tempo_ciclo: int = 0
var tempo_jogo: int = 0

# --- PODER DOS EQUIPAMENTOS ---
var poder_manivela: float = 2.0
var producao_solar: float = 1.0
var producao_eolica: float = 2.0
var producao_geotermica: float = 6.0
var producao_nuclear: float = 25.0

# --- GERADORES E PREÇOS ---
var paineis_solares: int = 0
var preco_painel_solar: float = 15.0

var turbinas_eolicas: int = 0
var preco_turbina_eolica: float = 40.0

var usinas_geotermicas: int = 0
var preco_geotermica: float = 120.0

var reatores_nucleares: int = 0
var preco_nuclear: float = 450.0

var baterias: int = 0
var preco_bateria: float = 20.0
var capacidade_bateria: float = 25.0

# --- UPGRADES ---
var nivel_manivela: int = 1
var preco_upgrade_manivela: float = 30.0

var nivel_solar_upgrade: int = 1
var preco_upgrade_solar: float = 60.0

var nivel_eolica_upgrade: int = 1
var preco_upgrade_eolica: float = 100.0

var nivel_geotermica_upgrade: int = 1
var preco_upgrade_geotermica: float = 250.0

var nivel_nuclear_upgrade: int = 1
var preco_upgrade_nuclear: float = 800.0

# --- REFERÊNCIAS VISUAIS ---
@onready var label_ouro: Label = $LabelOuro
@onready var label_energia: Label = $LabelEnergia
@onready var label_blackout: Label = $LabelBlackout
@onready var label_clima: Label = $LabelClima
@onready var botao_manivela: Button = $BotaoManivela
@onready var botao_abrir_loja: Button = $BotaoAbrirLoja
@onready var botao_abrir_upgrades: Button = $BotaoAbrirUpgrades
@onready var botao_abrir_conquistas: Button = $BotaoAbrirConquistas

# Menus
@onready var painel_loja: PanelContainer = $PainelLoja
@onready var painel_upgrades: PanelContainer = $PainelUpgrades
@onready var painel_conquistas: PanelContainer = $PainelConquistas
@onready var lista_conquistas: VBoxContainer = $PainelConquistas/VBoxContainer/ScrollConquistas/ListaConquistas

# Botões Loja
@onready var botao_comprar_solar: Button = $PainelLoja/VBoxContainer/BotaoComprarSolar
@onready var botao_comprar_eolica: Button = $PainelLoja/VBoxContainer/BotaoComprarEolica
@onready var botao_comprar_geotermica: Button = $PainelLoja/VBoxContainer/BotaoComprarGeotermica
@onready var botao_comprar_nuclear: Button = $PainelLoja/VBoxContainer/BotaoComprarNuclear
@onready var botao_comprar_bateria: Button = $PainelLoja/VBoxContainer/BotaoComprarBateria

# Botões Upgrades
@onready var botao_upgrade_manivela: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeManivela
@onready var botao_upgrade_solar: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeSolar
@onready var botao_upgrade_eolica: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeEolica
@onready var botao_upgrade_geotermica: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeGeotermica
@onready var botao_upgrade_nuclear: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeNuclear

func _ready() -> void:
	randomize()
	if label_blackout != null: label_blackout.visible = false
	if painel_loja != null: painel_loja.visible = false
	if painel_upgrades != null: painel_upgrades.visible = false
	if painel_conquistas != null: painel_conquistas.visible = false
	atualizar_interface()

func atualizar_interface() -> void:
	var capacidade_maxima = 10.0 + (baterias * capacidade_bateria)
	
	if label_ouro != null and label_energia != null:
		var estado_tempo = "DIA ☀️" if eh_dia else "NOITE 🌙"
		label_ouro.text = "Ouro: $" + str(int(ouro)) + " | " + estado_tempo
		label_energia.text = ("Oferta: %.1f MW/s | Demanda: %.1f MW/s\n" % [oferta_atual, demanda_cidade]) + \
							 ("Bateria: %.1f / %.1f MW" % [energia_armazenada, capacidade_maxima])
	
	if label_clima != null:
		if tempo_mensagem_conquista > 0:
			label_clima.text = "🏆 " + mensagem_conquista
		else:
			match clima_atual:
				Clima.NORMAL:
					label_clima.text = "Clima: Estável 🌤️"
				Clima.TEMPESTADE:
					label_clima.text = "⚡ ALERTA: TEMPESTADE! (Eólicas 3x Produção) [%ds]" % tempo_clima_restante
				Clima.ECLIPSE:
					label_clima.text = "🌑 ALERTA: ECLIPSE! (Painéis Solares Desativados) [%ds]" % tempo_clima_restante
				Clima.ONDA_DE_CALOR:
					label_clima.text = "🔥 ALERTA: ONDA DE CALOR! (Demanda +50%%) [%ds]" % tempo_clima_restante

	if botao_manivela != null:
		botao_manivela.text = "Girar Manivela (+%.1f MW)" % poder_manivela
	
	# --- TEXTOS DA LOJA ---
	if botao_comprar_solar != null:
		botao_comprar_solar.text = ("Painel Solar ($%d)\nGera: +%.1f MW/s (Dia) | Qtd: %d" % [int(preco_painel_solar), producao_solar, paineis_solares])
	if botao_comprar_eolica != null:
		botao_comprar_eolica.text = ("Turbina Eólica ($%d)\nGera: +%.1f MW/s (Constante) | Qtd: %d" % [int(preco_turbina_eolica), producao_eolica, turbinas_eolicas])
	if botao_comprar_geotermica != null:
		botao_comprar_geotermica.text = ("Usina Geotérmica ($%d)\nGera: +%.1f MW/s (Constante) | Qtd: %d" % [int(preco_geotermica), producao_geotermica, usinas_geotermicas])
	if botao_comprar_nuclear != null:
		botao_comprar_nuclear.text = ("Reator Nuclear ($%d)\nGera: +%.1f MW/s (Constante) | Qtd: %d" % [int(preco_nuclear), producao_nuclear, reatores_nucleares])
	if botao_comprar_bateria != null:
		botao_comprar_bateria.text = ("Bateria ($%d)\nCapacidade: +%.1f MW | Qtd: %d" % [int(preco_bateria), capacidade_bateria, baterias])

	# --- TEXTOS DE UPGRADES ---
	if botao_upgrade_manivela != null:
		botao_upgrade_manivela.text = ("Manivela Reforçada Lvl %d ($%d)\nAumenta para +%.1f MW por clique" % [nivel_manivela, int(preco_upgrade_manivela), poder_manivela + 1.5])
	if botao_upgrade_solar != null:
		botao_upgrade_solar.text = ("Células Fotovoltaicas Lvl %d ($%d)\nAumenta solar para +%.1f MW/s" % [nivel_solar_upgrade, int(preco_upgrade_solar), producao_solar + 1.0])
	if botao_upgrade_eolica != null:
		botao_upgrade_eolica.text = ("Pás Aerodinâmicas Lvl %d ($%d)\nAumenta eólica para +%.1f MW/s" % [nivel_eolica_upgrade, int(preco_upgrade_eolica), producao_eolica + 1.5])
	if botao_upgrade_geotermica != null:
		botao_upgrade_geotermica.text = ("Perfuração Profunda Lvl %d ($%d)\nAumenta geotérmica para +%.1f MW/s" % [nivel_geotermica_upgrade, int(preco_upgrade_geotermica), producao_geotermica + 3.0])
	if botao_upgrade_nuclear != null:
		botao_upgrade_nuclear.text = ("Fissão Avançada Lvl %d ($%d)\nAumenta nuclear para +%.1f MW/s" % [nivel_nuclear_upgrade, int(preco_upgrade_nuclear), producao_nuclear + 10.0])

# --- LÓGICA DE CONQUISTAS ---
func verificar_marcos_e_conquistas() -> void:
	# GERADORES
	if paineis_solares >= 10 and not marcos_atingidos["solar_10"]:
		marcos_atingidos["solar_10"] = true
		producao_solar *= 2.0
		exibir_conquista("Marco: 10 Solares! Produção Solar Dobrou!")
	elif paineis_solares >= 25 and not marcos_atingidos["solar_25"]:
		marcos_atingidos["solar_25"] = true
		producao_solar *= 2.0
		exibir_conquista("Marco: 25 Solares! Produção Solar Dobrou!")
	elif paineis_solares >= 50 and not marcos_atingidos["solar_50"]:
		marcos_atingidos["solar_50"] = true
		producao_solar *= 2.0
		exibir_conquista("Marco: 50 Solares! Produção Solar Dobrou!")

	if turbinas_eolicas >= 10 and not marcos_atingidos["eolica_10"]:
		marcos_atingidos["eolica_10"] = true
		producao_eolica *= 2.0
		exibir_conquista("Marco: 10 Eólicas! Produção Eólica Dobrou!")
	elif turbinas_eolicas >= 25 and not marcos_atingidos["eolica_25"]:
		marcos_atingidos["eolica_25"] = true
		producao_eolica *= 2.0
		exibir_conquista("Marco: 25 Eólicas! Produção Eólica Dobrou!")
	elif turbinas_eolicas >= 50 and not marcos_atingidos["eolica_50"]:
		marcos_atingidos["eolica_50"] = true
		producao_eolica *= 2.0
		exibir_conquista("Marco: 50 Eólicas! Produção Eólica Dobrou!")

	if usinas_geotermicas >= 10 and not marcos_atingidos["geotermica_10"]:
		marcos_atingidos["geotermica_10"] = true
		producao_geotermica *= 2.0
		exibir_conquista("Marco: 10 Geotérmicas! Produção Geotérmica Dobrou!")
	elif usinas_geotermicas >= 25 and not marcos_atingidos["geotermica_25"]:
		marcos_atingidos["geotermica_25"] = true
		producao_geotermica *= 2.0
		exibir_conquista("Marco: 25 Geotérmicas! Produção Geotérmica Dobrou!")
	elif usinas_geotermicas >= 50 and not marcos_atingidos["geotermica_50"]:
		marcos_atingidos["geotermica_50"] = true
		producao_geotermica *= 2.0
		exibir_conquista("Marco: 50 Geotérmicas! Produção Geotérmica Dobrou!")

	if reatores_nucleares >= 10 and not marcos_atingidos["nuclear_10"]:
		marcos_atingidos["nuclear_10"] = true
		producao_nuclear *= 2.0
		exibir_conquista("Marco: 10 Reatores! Produção Nuclear Dobrou!")
	elif reatores_nucleares >= 25 and not marcos_atingidos["nuclear_25"]:
		marcos_atingidos["nuclear_25"] = true
		producao_nuclear *= 2.0
		exibir_conquista("Marco: 25 Reatores! Produção Nuclear Dobrou!")
	elif reatores_nucleares >= 50 and not marcos_atingidos["nuclear_50"]:
		marcos_atingidos["nuclear_50"] = true
		producao_nuclear *= 2.0
		exibir_conquista("Marco: 50 Reatores! Produção Nuclear Dobrou!")

	# MELHORIAS (LVL 10)
	if nivel_manivela >= 10 and not marcos_atingidos["up_manivela_10"]:
		marcos_atingidos["up_manivela_10"] = true
		poder_manivela *= 2.0
		exibir_conquista("Conquista: Manivela Lvl 10! Força de Clique Dobrou!")

	if nivel_solar_upgrade >= 10 and not marcos_atingidos["up_solar_10"]:
		marcos_atingidos["up_solar_10"] = true
		producao_solar *= 2.0
		exibir_conquista("Conquista: Upgrade Solar Lvl 10! Produção Solar Dobrou!")

	if nivel_eolica_upgrade >= 10 and not marcos_atingidos["up_eolica_10"]:
		marcos_atingidos["up_eolica_10"] = true
		producao_eolica *= 2.0
		exibir_conquista("Conquista: Upgrade Eólico Lvl 10! Produção Eólica Dobrou!")

	if nivel_geotermica_upgrade >= 10 and not marcos_atingidos["up_geotermica_10"]:
		marcos_atingidos["up_geotermica_10"] = true
		producao_geotermica *= 2.0
		exibir_conquista("Conquista: Upgrade Geotérmico Lvl 10! Produção Geotérmica Dobrou!")

	if nivel_nuclear_upgrade >= 10 and not marcos_atingidos["up_nuclear_10"]:
		marcos_atingidos["up_nuclear_10"] = true
		producao_nuclear *= 2.0
		exibir_conquista("Conquista: Upgrade Nuclear Lvl 10! Produção Nuclear Dobrou!")

	atualizar_painel_conquistas()

func exibir_conquista(msg: String) -> void:
	mensagem_conquista = msg
	tempo_mensagem_conquista = 4

func atualizar_painel_conquistas() -> void:
	var lista = get_node_or_null("PainelConquistas/VBoxContainer/ScrollConquistas/ListaConquistas")
	if lista == null:
		lista = lista_conquistas
	if lista == null: return
	
	# Limpa a lista antiga
	for child in lista.get_children():
		child.queue_free()

	# Preenche com todas as conquistas e status
	for item in dados_conquistas:
		var eh_desbloqueado = marcos_atingidos[item["chave"]]
		var qtd_atual = 0
		
		match item["tipo"]:
			"solar": qtd_atual = paineis_solares
			"eolica": qtd_atual = turbinas_eolicas
			"geotermica": qtd_atual = usinas_geotermicas
			"nuclear": qtd_atual = reatores_nucleares
			"up_manivela": qtd_atual = nivel_manivela
			"up_solar": qtd_atual = nivel_solar_upgrade
			"up_eolica": qtd_atual = nivel_eolica_upgrade
			"up_geotermica": qtd_atual = nivel_geotermica_upgrade
			"up_nuclear": qtd_atual = nivel_nuclear_upgrade
			
		var label_item = Label.new()
		label_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label_item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		if eh_desbloqueado:
			label_item.text = "✅ %s\n   %s [CONCLUÍDO]\n " % [item["nome"], item["desc"]]
		else:
			label_item.text = "🔒 %s (%d/%d)\n   %s\n " % [item["nome"], min(qtd_atual, item["meta"]), item["meta"], item["desc"]]
			
		lista.add_child(label_item)

func sortear_evento_climatico() -> void:
	var chance = randf()
	if chance < 0.4:
		clima_atual = Clima.TEMPESTADE
		tempo_clima_restante = 15
		mult_eolica = 3.0
		mult_solar = 1.0
	elif chance < 0.7:
		clima_atual = Clima.ONDA_DE_CALOR
		tempo_clima_restante = 12
		mult_eolica = 1.0
		mult_solar = 1.0
	else:
		clima_atual = Clima.ECLIPSE
		tempo_clima_restante = 10
		mult_eolica = 1.0
		mult_solar = 0.0

func resetar_clima() -> void:
	clima_atual = Clima.NORMAL
	mult_eolica = 1.0
	mult_solar = 1.0

# Clique na Manivela
func _on_button_pressed() -> void:
	var capacidade_maxima = 10.0 + (baterias * capacidade_bateria)
	if energia_armazenada < capacidade_maxima:
		energia_armazenada += poder_manivela
		atualizar_interface()

# Loop do Timer (1s)
func _on_timer_timeout() -> void:
	tempo_ciclo += 1
	tempo_jogo += 1
	
	if tempo_mensagem_conquista > 0:
		tempo_mensagem_conquista -= 1
	
	# CONTROLE DO CLIMA
	if clima_atual != Clima.NORMAL:
		tempo_clima_restante -= 1
		if tempo_clima_restante <= 0:
			resetar_clima()
	else:
		tempo_proximo_evento -= 1
		if tempo_proximo_evento <= 0:
			sortear_evento_climatico()
			tempo_proximo_evento = randi_range(25, 45)
	
	# AUMENTO DE DEMANDA: Só aumenta se NÃO estiver em blackout!
	if tempo_jogo % 20 == 0 and not em_blackout:
		demanda_cidade *= 1.15

	if tempo_ciclo >= 10:
		tempo_ciclo = 0
		eh_dia = not eh_dia
	
	# DEMANDA MODIFICADA PELO CLIMA
	var demanda_efetiva = demanda_cidade * (1.5 if clima_atual == Clima.ONDA_DE_CALOR else 1.0)
	
	# CÁLCULO DA OFERTA TOTAL
	var producao_eolica_total = (turbinas_eolicas * producao_eolica) * mult_eolica
	var producao_geotermica_total = usinas_geotermicas * producao_geotermica
	var producao_nuclear_total = reatores_nucleares * producao_nuclear
	var producao_solar_total = ((paineis_solares * producao_solar) if eh_dia else 0.0) * mult_solar
	
	oferta_atual = producao_eolica_total + producao_geotermica_total + producao_nuclear_total + producao_solar_total
	
	var capacidade_maxima = 10.0 + (baterias * capacidade_bateria)
	
	# LÓGICA DE ATENDIMENTO DE ENERGIA E BLACKOUT
	if oferta_atual >= demanda_efetiva:
		var excesso = oferta_atual - demanda_efetiva
		energia_armazenada = min(energia_armazenada + excesso, capacidade_maxima)
		ouro += demanda_efetiva * 1.5
		em_blackout = false
		if label_blackout != null: label_blackout.visible = false
	else:
		var deficit = demanda_efetiva - oferta_atual
		if energia_armazenada >= deficit:
			energia_armazenada -= deficit
			ouro += demanda_efetiva * 1.5
			em_blackout = false
			if label_blackout != null: label_blackout.visible = false
		else:
			var energia_entregue = oferta_atual + energia_armazenada
			energia_armazenada = 0.0
			ouro += energia_entregue * 0.5
			em_blackout = true
			if label_blackout != null:
				label_blackout.visible = true
				label_blackout.text = "⚠️ BLACKOUT! DEMANDA CONGELADA ATE VOCE ALCANCAR!"

	atualizar_interface()

# Visibilidade dos botões do fundo
func mudar_visibilidade_botoes_principais(visivel: bool) -> void:
	if botao_manivela != null: botao_manivela.visible = visivel
	if botao_abrir_loja != null: botao_abrir_loja.visible = visivel
	if botao_abrir_upgrades != null: botao_abrir_upgrades.visible = visivel
	if botao_abrir_conquistas != null: botao_abrir_conquistas.visible = visivel

# --- CONTROLE DOS PAINÉIS ---
func _on_botao_abrir_loja_pressed() -> void:
	if painel_loja != null: painel_loja.visible = true
	if painel_upgrades != null: painel_upgrades.visible = false
	if painel_conquistas != null: painel_conquistas.visible = false
	mudar_visibilidade_botoes_principais(false)

func _on_botao_fechar_loja_pressed() -> void:
	if painel_loja != null: painel_loja.visible = false
	mudar_visibilidade_botoes_principais(true)

func _on_botao_abrir_upgrades_pressed() -> void:
	if painel_upgrades != null: painel_upgrades.visible = true
	if painel_loja != null: painel_loja.visible = false
	if painel_conquistas != null: painel_conquistas.visible = false
	mudar_visibilidade_botoes_principais(false)

func _on_botao_fechar_upgrades_pressed() -> void:
	if painel_upgrades != null: painel_upgrades.visible = false
	mudar_visibilidade_botoes_principais(true)

func _on_botao_abrir_conquistas_pressed() -> void:
	atualizar_painel_conquistas()
	if painel_conquistas != null: painel_conquistas.visible = true
	if painel_loja != null: painel_loja.visible = false
	if painel_upgrades != null: painel_upgrades.visible = false
	mudar_visibilidade_botoes_principais(false)

func _on_botao_fechar_conquistas_pressed() -> void:
	if painel_conquistas != null: painel_conquistas.visible = false
	mudar_visibilidade_botoes_principais(true)

# --- AÇÕES DA LOJA ---
func _on_botao_comprar_solar_pressed() -> void:
	if ouro >= preco_painel_solar:
		ouro -= preco_painel_solar
		paineis_solares += 1
		preco_painel_solar *= 1.15
		verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_comprar_eolica_pressed() -> void:
	if ouro >= preco_turbina_eolica:
		ouro -= preco_turbina_eolica
		turbinas_eolicas += 1
		preco_turbina_eolica *= 1.15
		verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_comprar_geotermica_pressed() -> void:
	if ouro >= preco_geotermica:
		ouro -= preco_geotermica
		usinas_geotermicas += 1
		preco_geotermica *= 1.15
		verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_comprar_nuclear_pressed() -> void:
	if ouro >= preco_nuclear:
		ouro -= preco_nuclear
		reatores_nucleares += 1
		preco_nuclear *= 1.15
		verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_comprar_bateria_pressed() -> void:
	if ouro >= preco_bateria:
		ouro -= preco_bateria
		baterias += 1
		preco_bateria *= 1.2
		atualizar_interface()

# --- AÇÕES DE UPGRADES ---
func _on_botao_upgrade_manivela_pressed() -> void:
	if ouro >= preco_upgrade_manivela:
		ouro -= preco_upgrade_manivela
		poder_manivela += 1.5
		nivel_manivela += 1
		preco_upgrade_manivela *= 1.8
		verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_upgrade_solar_pressed() -> void:
	if ouro >= preco_upgrade_solar:
		ouro -= preco_upgrade_solar
		producao_solar += 1.0
		nivel_solar_upgrade += 1
		preco_upgrade_solar *= 2.0
		verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_upgrade_eolica_pressed() -> void:
	if ouro >= preco_upgrade_eolica:
		ouro -= preco_upgrade_eolica
		producao_eolica += 1.5
		nivel_eolica_upgrade += 1
		preco_upgrade_eolica *= 2.0
		verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_upgrade_geotermica_pressed() -> void:
	if ouro >= preco_upgrade_geotermica:
		ouro -= preco_upgrade_geotermica
		producao_geotermica += 3.0
		nivel_geotermica_upgrade += 1
		preco_upgrade_geotermica *= 2.2
		verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_upgrade_nuclear_pressed() -> void:
	if ouro >= preco_upgrade_nuclear:
		ouro -= preco_upgrade_nuclear
		producao_nuclear += 10.0
		nivel_nuclear_upgrade += 1
		preco_upgrade_nuclear *= 2.5
		verificar_marcos_e_conquistas()
		atualizar_interface()

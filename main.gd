extends Node2D

# --- EVENTOS CLIMÁTICOS ---
enum Clima { NORMAL, TEMPESTADE, ECLIPSE, ONDA_DE_CALOR }
var clima_atual: Clima = Clima.NORMAL
var tempo_clima_restante: int = 0
var tempo_proximo_evento: int = 30 

var mult_eolica: float = 1.0
var mult_solar: float = 1.0

# --- CICLO DIA / NOITE ---
var eh_dia: bool = true
var tempo_ciclo: int = 0
var duracao_ciclo: int = 30
var tempo_jogo: int = 0

var mensagem_conquista: String = ""
var tempo_mensagem_conquista: int = 0

# --- REFERÊNCIAS ---
@onready var achievement_manager: Node = $AchievementManager

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
	
	if achievement_manager != null and achievement_manager.has_signal("conquista_desbloqueada"):
		achievement_manager.conquista_desbloqueada.connect(_on_conquista_desbloqueada)
		
	atualizar_interface()

func _on_conquista_desbloqueada(msg: String) -> void:
	mensagem_conquista = msg
	tempo_mensagem_conquista = 4

func atualizar_interface() -> void:
	var cap_max = GameState.calcular_capacidade_maxima()
	
	if label_ouro != null and label_energia != null:
		var estado_tempo = "DIA ☀️" if eh_dia else "NOITE 🌙"
		label_ouro.text = "Ouro: $" + str(int(GameState.ouro)) + " | " + estado_tempo
		label_energia.text = ("Oferta: %.1f MW/s | Demanda: %.1f MW/s\n" % [GameState.oferta_atual, GameState.demanda_cidade]) + \
							 ("Bateria: %.1f / %.1f MW" % [GameState.energia_armazenada, cap_max])
	
	if label_clima != null:
		if tempo_mensagem_conquista > 0:
			label_clima.text = "🏆 " + mensagem_conquista
		else:
			match clima_atual:
				Clima.NORMAL: label_clima.text = "Clima: Estável 🌤️"
				Clima.TEMPESTADE: label_clima.text = "⚡ ALERTA: TEMPESTADE! (Eólicas 3x) [%ds]" % tempo_clima_restante
				Clima.ECLIPSE: label_clima.text = "🌑 ALERTA: ECLIPSE! (Solares Desativados) [%ds]" % tempo_clima_restante
				Clima.ONDA_DE_CALOR: label_clima.text = "🔥 ALERTA: ONDA DE CALOR! (Demanda +50%%) [%ds]" % tempo_clima_restante

	if botao_manivela != null:
		botao_manivela.text = "Girar Manivela (+%.1f MW)" % GameState.poder_manivela
	
	# Loja
	if botao_comprar_solar != null:
		botao_comprar_solar.text = ("Painel Solar ($%d)\nGera: +%.1f MW/s | Qtd: %d" % [int(GameState.preco_painel_solar), GameState.producao_solar, GameState.paineis_solares])
	
	if botao_comprar_eolica != null:
		botao_comprar_eolica.visible = GameState.paineis_solares >= 5
		if botao_comprar_eolica.visible:
			botao_comprar_eolica.text = ("Turbina Eólica ($%d)\nGera: +%.1f MW/s | Qtd: %d" % [int(GameState.preco_turbina_eolica), GameState.producao_eolica, GameState.turbinas_eolicas])
	
	if botao_comprar_geotermica != null:
		botao_comprar_geotermica.visible = GameState.turbinas_eolicas >= 5
		if botao_comprar_geotermica.visible:
			botao_comprar_geotermica.text = ("Usina Geotérmica ($%d)\nGera: +%.1f MW/s | Qtd: %d" % [int(GameState.preco_geotermica), GameState.producao_geotermica, GameState.usinas_geotermicas])
	
	if botao_comprar_nuclear != null:
		botao_comprar_nuclear.visible = GameState.usinas_geotermicas >= 5
		if botao_comprar_nuclear.visible:
			botao_comprar_nuclear.text = ("Reator Nuclear ($%d)\nGera: +%.1f MW/s | Qtd: %d" % [int(GameState.preco_nuclear), GameState.producao_nuclear, GameState.reatores_nucleares])
	
	if botao_comprar_bateria != null:
		botao_comprar_bateria.text = ("Bateria ($%d)\nCapacidade: +%.1f MW | Qtd: %d" % [int(GameState.preco_bateria), GameState.capacidade_bateria, GameState.baterias])

	# Upgrades
	if botao_upgrade_manivela != null:
		botao_upgrade_manivela.text = ("Manivela Reforçada Lvl %d ($%d)\nAumenta para +%.1f MW por clique" % [
			GameState.nivel_manivela, 
			int(GameState.preco_upgrade_manivela), 
			GameState.poder_manivela + 1.5
		])
	
	if botao_upgrade_solar != null:
		botao_upgrade_solar.visible = GameState.paineis_solares > 0
		if botao_upgrade_solar.visible:
			botao_upgrade_solar.text = ("Células Fotovoltaicas Lvl %d ($%d)\nAumenta solar para +%.1f MW/s" % [
				GameState.nivel_solar_upgrade, 
				int(GameState.preco_upgrade_solar), 
				GameState.producao_solar + 1.0
			])
	
	if botao_upgrade_eolica != null:
		botao_upgrade_eolica.visible = GameState.turbinas_eolicas > 0
		if botao_upgrade_eolica.visible:
			botao_upgrade_eolica.text = ("Pás Aerodinâmicas Lvl %d ($%d)\nAumenta eólica para +%.1f MW/s" % [
				GameState.nivel_eolica_upgrade, 
				int(GameState.preco_upgrade_eolica), 
				GameState.producao_eolica + 1.5
			])
	
	if botao_upgrade_geotermica != null:
		botao_upgrade_geotermica.visible = GameState.usinas_geotermicas > 0
		if botao_upgrade_geotermica.visible:
			botao_upgrade_geotermica.text = ("Perfuração Profunda Lvl %d ($%d)\nAumenta geotérmica para +%.1f MW/s" % [
				GameState.nivel_geotermica_upgrade, 
				int(GameState.preco_upgrade_geotermica), 
				GameState.producao_geotermica + 3.0
			])
	
	if botao_upgrade_nuclear != null:
		botao_upgrade_nuclear.visible = GameState.reatores_nucleares > 0
		if botao_upgrade_nuclear.visible:
			botao_upgrade_nuclear.text = ("Fissão Avançada Lvl %d ($%d)\nAumenta nuclear para +%.1f MW/s" % [
				GameState.nivel_nuclear_upgrade, 
				int(GameState.preco_upgrade_nuclear), 
				GameState.producao_nuclear + 10.0
			])

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

func _on_button_pressed() -> void:
	var cap_max = GameState.calcular_capacidade_maxima()
	if GameState.energia_armazenada < cap_max:
		GameState.energia_armazenada += GameState.poder_manivela
		atualizar_interface()

func _on_timer_timeout() -> void:
	tempo_ciclo += 1
	tempo_jogo += 1
	
	if tempo_mensagem_conquista > 0:
		tempo_mensagem_conquista -= 1
	
	if clima_atual != Clima.NORMAL:
		tempo_clima_restante -= 1
		if tempo_clima_restante <= 0: resetar_clima()
	else:
		tempo_proximo_evento -= 1
		if tempo_proximo_evento <= 0:
			sortear_evento_climatico()
			tempo_proximo_evento = randi_range(25, 45)
	
	# Aumento de Demanda (A cada 20s)
	if tempo_jogo % 20 == 0 and not GameState.em_blackout:
		GameState.demanda_cidade *= 1.12

	if tempo_ciclo >= duracao_ciclo:
		tempo_ciclo = 0
		eh_dia = not eh_dia
	
	var demanda_efetiva = GameState.demanda_cidade * (1.5 if clima_atual == Clima.ONDA_DE_CALOR else 1.0)
	
	var prod_eolica = (GameState.turbinas_eolicas * GameState.producao_eolica) * mult_eolica
	var prod_geotermica = GameState.usinas_geotermicas * GameState.producao_geotermica
	var prod_nuclear = GameState.reatores_nucleares * GameState.producao_nuclear
	var prod_solar = ((GameState.paineis_solares * GameState.producao_solar) if eh_dia else 0.0) * mult_solar
	
	GameState.oferta_atual = prod_eolica + prod_geotermica + prod_nuclear + prod_solar
	var cap_max = GameState.calcular_capacidade_maxima()
	
	if GameState.oferta_atual >= demanda_efetiva:
		var excesso = GameState.oferta_atual - demanda_efetiva
		GameState.energia_armazenada = min(GameState.energia_armazenada + excesso, cap_max)
		GameState.ouro += demanda_efetiva * 1.5
		GameState.em_blackout = false
		if label_blackout != null: label_blackout.visible = false
	else:
		var deficit = demanda_efetiva - GameState.oferta_atual
		if GameState.energia_armazenada >= deficit:
			GameState.energia_armazenada -= deficit
			GameState.ouro += demanda_efetiva * 1.5
			GameState.em_blackout = false
			if label_blackout != null: label_blackout.visible = false
		else:
			var entregue = GameState.oferta_atual + GameState.energia_armazenada
			GameState.energia_armazenada = 0.0
			GameState.ouro += entregue * 0.5
			GameState.em_blackout = true
			if label_blackout != null:
				label_blackout.visible = true
				label_blackout.text = "⚠️ BLACKOUT! DEMANDA CONGELADA ATE VOCE ALCANCAR!"

	atualizar_interface()

# --- NAVEGAÇÃO ---
func mudar_visibilidade_botoes(visivel: bool) -> void:
	if botao_manivela != null: botao_manivela.visible = visivel
	if botao_abrir_loja != null: botao_abrir_loja.visible = visivel
	if botao_abrir_upgrades != null: botao_abrir_upgrades.visible = visivel
	if botao_abrir_conquistas != null: botao_abrir_conquistas.visible = visivel

func _on_botao_abrir_loja_pressed() -> void:
	atualizar_interface()
	if painel_loja != null: painel_loja.visible = true
	mudar_visibilidade_botoes(false)

func _on_botao_fechar_loja_pressed() -> void:
	if painel_loja != null: painel_loja.visible = false
	mudar_visibilidade_botoes(true)

func _on_botao_abrir_upgrades_pressed() -> void:
	atualizar_interface()
	if painel_upgrades != null: painel_upgrades.visible = true
	mudar_visibilidade_botoes(false)

func _on_botao_fechar_upgrades_pressed() -> void:
	if painel_upgrades != null: painel_upgrades.visible = false
	mudar_visibilidade_botoes(true)

func _on_botao_abrir_conquistas_pressed() -> void:
	if achievement_manager != null and lista_conquistas != null:
		achievement_manager.renderizar_lista(lista_conquistas)
	if painel_conquistas != null: painel_conquistas.visible = true
	mudar_visibilidade_botoes(false)

func _on_botao_fechar_conquistas_pressed() -> void:
	if painel_conquistas != null: painel_conquistas.visible = false
	mudar_visibilidade_botoes(true)

# --- COMPRAS LOJA ---
func _on_botao_comprar_solar_pressed() -> void:
	if GameState.ouro >= GameState.preco_painel_solar:
		GameState.ouro -= GameState.preco_painel_solar
		GameState.paineis_solares += 1
		GameState.preco_painel_solar *= 1.15
		if achievement_manager != null: achievement_manager.verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_comprar_eolica_pressed() -> void:
	if GameState.paineis_solares >= 5 and GameState.ouro >= GameState.preco_turbina_eolica:
		GameState.ouro -= GameState.preco_turbina_eolica
		GameState.turbinas_eolicas += 1
		GameState.preco_turbina_eolica *= 1.15
		if achievement_manager != null: achievement_manager.verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_comprar_geotermica_pressed() -> void:
	if GameState.turbinas_eolicas >= 5 and GameState.ouro >= GameState.preco_geotermica:
		GameState.ouro -= GameState.preco_geotermica
		GameState.usinas_geotermicas += 1
		GameState.preco_geotermica *= 1.15
		if achievement_manager != null: achievement_manager.verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_comprar_nuclear_pressed() -> void:
	if GameState.usinas_geotermicas >= 5 and GameState.ouro >= GameState.preco_nuclear:
		GameState.ouro -= GameState.preco_nuclear
		GameState.reatores_nucleares += 1
		GameState.preco_nuclear *= 1.15
		if achievement_manager != null: achievement_manager.verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_comprar_bateria_pressed() -> void:
	if GameState.ouro >= GameState.preco_bateria:
		GameState.ouro -= GameState.preco_bateria
		GameState.baterias += 1
		GameState.preco_bateria *= 1.15
		if achievement_manager != null: achievement_manager.verificar_marcos_e_conquistas()
		atualizar_interface()

# --- UPGRADES ---
func _on_botao_upgrade_manivela_pressed() -> void:
	if GameState.ouro >= GameState.preco_upgrade_manivela:
		GameState.ouro -= GameState.preco_upgrade_manivela
		GameState.poder_manivela += 1.5
		GameState.nivel_manivela += 1
		GameState.preco_upgrade_manivela *= 1.8
		if achievement_manager != null: achievement_manager.verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_upgrade_solar_pressed() -> void:
	if GameState.ouro >= GameState.preco_upgrade_solar:
		GameState.ouro -= GameState.preco_upgrade_solar
		GameState.producao_solar += 1.0
		GameState.nivel_solar_upgrade += 1
		GameState.preco_upgrade_solar *= 2.0
		if achievement_manager != null: achievement_manager.verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_upgrade_eolica_pressed() -> void:
	if GameState.ouro >= GameState.preco_upgrade_eolica:
		GameState.ouro -= GameState.preco_upgrade_eolica
		GameState.producao_eolica += 1.5
		GameState.nivel_eolica_upgrade += 1
		GameState.preco_upgrade_eolica *= 2.0
		if achievement_manager != null: achievement_manager.verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_upgrade_geotermica_pressed() -> void:
	if GameState.ouro >= GameState.preco_upgrade_geotermica:
		GameState.ouro -= GameState.preco_upgrade_geotermica
		GameState.producao_geotermica += 3.0
		GameState.nivel_geotermica_upgrade += 1
		GameState.preco_upgrade_geotermica *= 2.2
		if achievement_manager != null: achievement_manager.verificar_marcos_e_conquistas()
		atualizar_interface()

func _on_botao_upgrade_nuclear_pressed() -> void:
	if GameState.ouro >= GameState.preco_upgrade_nuclear:
		GameState.ouro -= GameState.preco_upgrade_nuclear
		GameState.producao_nuclear += 10.0
		GameState.nivel_nuclear_upgrade += 1
		GameState.preco_upgrade_nuclear *= 2.5
		if achievement_manager != null: achievement_manager.verificar_marcos_e_conquistas()
		atualizar_interface()

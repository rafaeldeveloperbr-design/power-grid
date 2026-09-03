extends Node2D

# --- RECURSOS ---
var ouro: float = 0.0
var energia_armazenada: float = 0.0

# --- OFERTA E DEMANDA ---
var demanda_cidade: float = 5.0
var oferta_atual: float = 0.0

# --- CICLO DIA / NOITE ---
var eh_dia: bool = true
var tempo_ciclo: int = 0
var tempo_jogo: int = 0

# --- PODER DOS EQUIPAMENTOS (PRODUÇÃO POR UNIDADE) ---
var poder_manivela: float = 2.0        # MW por clique
var producao_solar: float = 1.0        # MW/s (Apenas Dia)
var producao_eolica: float = 2.0       # MW/s (Constante)
var producao_geotermica: float = 6.0   # MW/s (Constante)
var producao_nuclear: float = 25.0     # MW/s (Constante)

# --- GERADORES E PREÇOS INICIAIS ---
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

# --- NÍVEIS E PREÇOS DE UPGRADES ---
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
@onready var botao_manivela: Button = $BotaoManivela

# Menus
@onready var painel_loja: PanelContainer = $PainelLoja
@onready var painel_upgrades: PanelContainer = $PainelUpgrades

# Botões da Loja
@onready var botao_comprar_solar: Button = $PainelLoja/VBoxContainer/BotaoComprarSolar
@onready var botao_comprar_eolica: Button = $PainelLoja/VBoxContainer/BotaoComprarEolica
@onready var botao_comprar_geotermica: Button = $PainelLoja/VBoxContainer/BotaoComprarGeotermica
@onready var botao_comprar_nuclear: Button = $PainelLoja/VBoxContainer/BotaoComprarNuclear
@onready var botao_comprar_bateria: Button = $PainelLoja/VBoxContainer/BotaoComprarBateria

# Botões de Upgrades
@onready var botao_upgrade_manivela: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeManivela
@onready var botao_upgrade_solar: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeSolar
@onready var botao_upgrade_eolica: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeEolica
@onready var botao_upgrade_geotermica: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeGeotermica
@onready var botao_upgrade_nuclear: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeNuclear

func _ready() -> void:
	if label_blackout != null: label_blackout.visible = false
	if painel_loja != null: painel_loja.visible = false
	if painel_upgrades != null: painel_upgrades.visible = false
	atualizar_interface()

func atualizar_interface() -> void:
	var capacidade_maxima = 10.0 + (baterias * capacidade_bateria)
	
	if label_ouro != null and label_energia != null:
		var estado_tempo = "DIA ☀️" if eh_dia else "NOITE 🌙"
		label_ouro.text = "Ouro: $" + str(int(ouro)) + " | " + estado_tempo
		label_energia.text = ("Oferta: %.1f MW/s | Demanda: %.1f MW/s\n" % [oferta_atual, demanda_cidade]) + \
							 ("Bateria: %.1f / %.1f MW" % [energia_armazenada, capacidade_maxima])
	
	if botao_manivela != null:
		botao_manivela.text = "Girar Manivela (+%.1f MW)" % poder_manivela
	
	# --- TEXTOS DA LOJA ---
	if botao_comprar_solar != null:
		botao_comprar_solar.text = ("Painel Solar ($%d)\nGera: +%.1f MW/s (Dia) | Qtd: %d" % 
								   [int(preco_painel_solar), producao_solar, paineis_solares])
								
	if botao_comprar_eolica != null:
		botao_comprar_eolica.text = ("Turbina Eólica ($%d)\nGera: +%.1f MW/s (Constante) | Qtd: %d" % 
									[int(preco_turbina_eolica), producao_eolica, turbinas_eolicas])
		
	if botao_comprar_geotermica != null:
		botao_comprar_geotermica.text = ("Usina Geotérmica ($%d)\nGera: +%.1f MW/s (Constante) | Qtd: %d" % 
										[int(preco_geotermica), producao_geotermica, usinas_geotermicas])

	if botao_comprar_nuclear != null:
		botao_comprar_nuclear.text = ("Reator Nuclear ($%d)\nGera: +%.1f MW/s (Constante) | Qtd: %d" % 
									 [int(preco_nuclear), producao_nuclear, reatores_nucleares])

	if botao_comprar_bateria != null:
		botao_comprar_bateria.text = ("Bateria ($%d)\nCapacidade: +%.1f MW | Qtd: %d" % 
								   [int(preco_bateria), capacidade_bateria, baterias])

	# --- TEXTOS DE UPGRADES ---
	if botao_upgrade_manivela != null:
		botao_upgrade_manivela.text = ("Manivela Reforçada Lvl %d ($%d)\nAumenta para +%.1f MW por clique" % 
									  [nivel_manivela, int(preco_upgrade_manivela), poder_manivela + 1.5])
									
	if botao_upgrade_solar != null:
		botao_upgrade_solar.text = ("Células Fotovoltaicas Lvl %d ($%d)\nAumenta solar para +%.1f MW/s" % 
								   [nivel_solar_upgrade, int(preco_upgrade_solar), producao_solar + 1.0])

	if botao_upgrade_eolica != null:
		botao_upgrade_eolica.text = ("Pás Aerodinâmicas Lvl %d ($%d)\nAumenta eólica para +%.1f MW/s" % 
									[nivel_eolica_upgrade, int(preco_upgrade_eolica), producao_eolica + 1.5])

	if botao_upgrade_geotermica != null:
		botao_upgrade_geotermica.text = ("Perfuração Profunda Lvl %d ($%d)\nAumenta geotérmica para +%.1f MW/s" % 
										[nivel_geotermica_upgrade, int(preco_upgrade_geotermica), producao_geotermica + 3.0])

	if botao_upgrade_nuclear != null:
		botao_upgrade_nuclear.text = ("Fissão Avançada Lvl %d ($%d)\nAumenta nuclear para +%.1f MW/s" % 
									 [nivel_nuclear_upgrade, int(preco_upgrade_nuclear), producao_nuclear + 10.0])

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
	
	if tempo_jogo % 30 == 0:
		demanda_cidade += 2.0
	
	if tempo_ciclo >= 10:
		tempo_ciclo = 0
		eh_dia = not eh_dia
	
	# CÁLCULO DA OFERTA TOTAL
	var producao_eolica_total = turbinas_eolicas * producao_eolica
	var producao_geotermica_total = usinas_geotermicas * producao_geotermica
	var producao_nuclear_total = reatores_nucleares * producao_nuclear
	var producao_solar_total = (paineis_solares * producao_solar) if eh_dia else 0.0
	
	oferta_atual = producao_eolica_total + producao_geotermica_total + producao_nuclear_total + producao_solar_total
	
	var capacidade_maxima = 10.0 + (baterias * capacidade_bateria)
	
	if oferta_atual >= demanda_cidade:
		var excesso = oferta_atual - demanda_cidade
		energia_armazenada = min(energia_armazenada + excesso, capacidade_maxima)
		ouro += demanda_cidade * 1.5
		if label_blackout != null: label_blackout.visible = false
	else:
		var deficit = demanda_cidade - oferta_atual
		if energia_armazenada >= deficit:
			energia_armazenada -= deficit
			ouro += demanda_cidade * 1.5
			if label_blackout != null: label_blackout.visible = false
		else:
			var energia_entregue = oferta_atual + energia_armazenada
			energia_armazenada = 0.0
			ouro += energia_entregue * 0.5
			if label_blackout != null: label_blackout.visible = not label_blackout.visible

	atualizar_interface()

# --- AÇÕES DA LOJA ---
func _on_botao_abrir_loja_pressed() -> void:
	if painel_loja != null: painel_loja.visible = true
	if painel_upgrades != null: painel_upgrades.visible = false

func _on_botao_fechar_loja_pressed() -> void:
	if painel_loja != null: painel_loja.visible = false

func _on_botao_comprar_solar_pressed() -> void:
	if ouro >= preco_painel_solar:
		ouro -= preco_painel_solar
		paineis_solares += 1
		preco_painel_solar *= 1.15
		atualizar_interface()

func _on_botao_comprar_eolica_pressed() -> void:
	if ouro >= preco_turbina_eolica:
		ouro -= preco_turbina_eolica
		turbinas_eolicas += 1
		preco_turbina_eolica *= 1.15
		atualizar_interface()

func _on_botao_comprar_geotermica_pressed() -> void:
	if ouro >= preco_geotermica:
		ouro -= preco_geotermica
		usinas_geotermicas += 1
		preco_geotermica *= 1.15
		atualizar_interface()

func _on_botao_comprar_nuclear_pressed() -> void:
	if ouro >= preco_nuclear:
		ouro -= preco_nuclear
		reatores_nucleares += 1
		preco_nuclear *= 1.15
		atualizar_interface()

func _on_botao_comprar_bateria_pressed() -> void:
	if ouro >= preco_bateria:
		ouro -= preco_bateria
		baterias += 1
		preco_bateria *= 1.2
		atualizar_interface()

# --- AÇÕES DO PAINEL DE UPGRADES ---
func _on_botao_abrir_upgrades_pressed() -> void:
	if painel_upgrades != null: painel_upgrades.visible = true
	if painel_loja != null: painel_loja.visible = false

func _on_botao_fechar_upgrades_pressed() -> void:
	if painel_upgrades != null: painel_upgrades.visible = false

func _on_botao_upgrade_manivela_pressed() -> void:
	if ouro >= preco_upgrade_manivela:
		ouro -= preco_upgrade_manivela
		poder_manivela += 1.5
		nivel_manivela += 1
		preco_upgrade_manivela *= 1.8
		atualizar_interface()

func _on_botao_upgrade_solar_pressed() -> void:
	if ouro >= preco_upgrade_solar:
		ouro -= preco_upgrade_solar
		producao_solar += 1.0
		nivel_solar_upgrade += 1
		preco_upgrade_solar *= 2.0
		atualizar_interface()

func _on_botao_upgrade_eolica_pressed() -> void:
	if ouro >= preco_upgrade_eolica:
		ouro -= preco_upgrade_eolica
		producao_eolica += 1.5
		nivel_eolica_upgrade += 1
		preco_upgrade_eolica *= 2.0
		atualizar_interface()

func _on_botao_upgrade_geotermica_pressed() -> void:
	if ouro >= preco_upgrade_geotermica:
		ouro -= preco_upgrade_geotermica
		producao_geotermica += 3.0
		nivel_geotermica_upgrade += 1
		preco_upgrade_geotermica *= 2.2
		atualizar_interface()

func _on_botao_upgrade_nuclear_pressed() -> void:
	if ouro >= preco_upgrade_nuclear:
		ouro -= preco_upgrade_nuclear
		producao_nuclear += 10.0
		nivel_nuclear_upgrade += 1
		preco_upgrade_nuclear *= 2.5
		atualizar_interface()

extends Node2D

#Aumentar velocidade para testar o game, remover na fase final
const MODO_TESTE = true
const VELOCIDADE_TESTE = 5.0 # 5x mais rápido

enum Clima { NORMAL, TEMPESTADE, ECLIPSE, ONDA_DE_CALOR, SECA }

const CLIMA_INFO = {
	Clima.NORMAL: {"texto": "Clima: Estável 🌤", "mult_eolica": 1.0, "mult_solar": 1.0, "mult_hidro": 1.0, "duracao": 0},
	Clima.TEMPESTADE: {"texto": "⚡ TEMPESTADE! Eólicas 3x + Hidro 2x", "mult_eolica": 3.0, "mult_solar": 0.8, "mult_hidro": 2.0, "duracao": 15},
	Clima.ECLIPSE: {"texto": "🌑 ECLIPSE! Solares OFF", "mult_eolica": 1.0, "mult_solar": 0.0, "mult_hidro": 1.0, "duracao": 10},
	Clima.ONDA_DE_CALOR: {"texto": "🔥 ONDA DE CALOR! Demanda +50%", "mult_eolica": 1.0, "mult_solar": 1.2, "mult_hidro": 0.5, "duracao": 12},
	Clima.SECA: {"texto": "🏜️ SECA! Hidro -80%", "mult_eolica": 0.7, "mult_solar": 1.3, "mult_hidro": 0.2, "duracao": 18},
}

var clima_atual: Clima = Clima.NORMAL
var tempo_clima_restante: int = 0
var tempo_proximo_evento: int = 30
var mult_eolica: float = 1.0
var mult_solar: float = 1.0
var mult_hidro: float = 1.0

var eh_dia: bool = true
var tempo_ciclo: int = 0
var duracao_ciclo: int = 30
var tempo_jogo: int = 0
var tempo_mensagem_conquista: int = 0
var mensagem_conquista: String = ""

var rng = RandomNumberGenerator.new()

@onready var achievement_manager: Node = $AchievementManager
@onready var label_ouro: Label = $TopHUD/VBoxTop/LabelOuro
@onready var label_energia: Label = $TopHUD/VBoxTop/LabelEnergia
@onready var label_blackout: Label = $LabelBlackout
@onready var label_clima: Label = $TopHUD/VBoxTop/LabelClima
@onready var label_conquista: Label = $TopHUD/VBoxTop/LabelConquista
@onready var label_poluicao: Label = $TopHUD/VBoxTop/LabelPoluicao
@onready var label_cidade: Label = $TopHUD/VBoxTop/LabelCidade
@onready var botao_manivela: Button = $BotaoManivela
@onready var botao_abrir_loja: Button = $BotoesPrincipais/BotaoAbrirLoja
@onready var botao_abrir_upgrades: Button = $BotoesPrincipais/BotaoAbrirUpgrades
@onready var botao_abrir_conquistas: Button = $BotoesPrincipais/BotaoAbrirConquistas
@onready var botao_abrir_manutencao: Button = $BotoesPrincipais/BotaoAbrirManutencao
@onready var botao_migrar_cidade: Button = $BotaoMigrarCidade

@onready var painel_loja: PanelContainer = $PainelLoja
@onready var painel_upgrades: PanelContainer = $PainelUpgrades
@onready var painel_conquistas: PanelContainer = $PainelConquistas
@onready var painel_manutencao: PanelContainer = $PainelManutencao
@onready var lista_conquistas: VBoxContainer = $PainelConquistas/VBoxContainer/ScrollConquistas/ListaConquistas
@onready var lista_manutencao: VBoxContainer = $PainelManutencao/VBoxContainer/ScrollManutencao/ListaManutencao

# COM SCROLL AGORA - caminho novo
@onready var botao_comprar_solar: Button = $PainelLoja/VBoxContainer/ScrollLoja/ListaLoja/BotaoComprarSolar
@onready var botao_comprar_eolica: Button = $PainelLoja/VBoxContainer/ScrollLoja/ListaLoja/BotaoComprarEolica
@onready var botao_comprar_bateria: Button = $PainelLoja/VBoxContainer/ScrollLoja/ListaLoja/BotaoComprarBateria
@onready var botao_comprar_carvao: Button = $PainelLoja/VBoxContainer/ScrollLoja/ListaLoja/BotaoComprarCarvao
@onready var botao_comprar_geotermica: Button = $PainelLoja/VBoxContainer/ScrollLoja/ListaLoja/BotaoComprarGeotermica
@onready var botao_comprar_biomassa: Button = $PainelLoja/VBoxContainer/ScrollLoja/ListaLoja/BotaoComprarBiomassa
@onready var botao_comprar_hidreletrica: Button = $PainelLoja/VBoxContainer/ScrollLoja/ListaLoja/BotaoComprarHidreletrica
@onready var botao_comprar_nuclear: Button = $PainelLoja/VBoxContainer/ScrollLoja/ListaLoja/BotaoComprarNuclear
@onready var botao_comprar_fusao: Button = $PainelLoja/VBoxContainer/ScrollLoja/ListaLoja/BotaoComprarFusao

@onready var botao_upgrade_manivela: Button = $PainelUpgrades/VBoxContainer/ScrollUpgrades/ListaUpgrades/BotaoUpgradeManivela
@onready var botao_upgrade_solar: Button = $PainelUpgrades/VBoxContainer/ScrollUpgrades/ListaUpgrades/BotaoUpgradeSolar
@onready var botao_upgrade_eolica: Button = $PainelUpgrades/VBoxContainer/ScrollUpgrades/ListaUpgrades/BotaoUpgradeEolica
@onready var botao_upgrade_carvao: Button = $PainelUpgrades/VBoxContainer/ScrollUpgrades/ListaUpgrades/BotaoUpgradeCarvao
@onready var botao_upgrade_biomassa: Button = $PainelUpgrades/VBoxContainer/ScrollUpgrades/ListaUpgrades/BotaoUpgradeBiomassa
@onready var botao_upgrade_geotermica: Button = $PainelUpgrades/VBoxContainer/ScrollUpgrades/ListaUpgrades/BotaoUpgradeGeotermica
@onready var botao_upgrade_hidreletrica: Button = $PainelUpgrades/VBoxContainer/ScrollUpgrades/ListaUpgrades/BotaoUpgradeHidreletrica
@onready var botao_upgrade_nuclear: Button = $PainelUpgrades/VBoxContainer/ScrollUpgrades/ListaUpgrades/BotaoUpgradeNuclear
@onready var botao_upgrade_fusao: Button = $PainelUpgrades/VBoxContainer/ScrollUpgrades/ListaUpgrades/BotaoUpgradeFusao

func _ready() -> void:
	rng.randomize()
	if label_blackout: label_blackout.visible = false
	if painel_loja: painel_loja.visible = false
	if painel_upgrades: painel_upgrades.visible = false
	if painel_conquistas: painel_conquistas.visible = false
	if painel_manutencao: painel_manutencao.visible = false
	if label_conquista: label_conquista.visible = false
	if botao_migrar_cidade: botao_migrar_cidade.visible = false
	
	if GameState.has_signal("recurso_mudou"):
		GameState.recurso_mudou.connect(atualizar_interface)
		GameState.producao_mudou.connect(atualizar_interface)
		GameState.cidade_mudou.connect(_on_cidade_mudou)
		GameState.poluicao_mudou.connect(atualizar_poluicao)
	
	if achievement_manager and achievement_manager.has_signal("conquista_desbloqueada"):
		if not achievement_manager.conquista_desbloqueada.is_connected(_on_conquista_desbloqueada):
			achievement_manager.conquista_desbloqueada.connect(_on_conquista_desbloqueada)
		
	atualizar_interface()
	
		# --- MODO TESTE ---
	if MODO_TESTE:
		print(">>> MODO TESTE ATIVO <<<")
		if has_node("Timer"):
			$Timer.wait_time = $Timer.wait_time / VELOCIDADE_TESTE
		GameState.ouro = 50000
		GameState.energia_armazenada = GameState.calcular_capacidade_maxima()
		if label_blackout:
			label_blackout.text = "[TESTE %dx] %s" % [VELOCIDADE_TESTE, label_blackout.text]
			label_blackout.visible = true

func _on_cidade_mudou():
	mensagem_conquista = "🏙️ Bem-vindo a %s! Eficiência +15%%" % GameState.get_cidade_atual_info().nome
	tempo_mensagem_conquista = 5
	if label_conquista:
		label_conquista.text = "🏆 " + mensagem_conquista
		label_conquista.visible = true
		label_conquista.modulate.a = 1.0

func _on_conquista_desbloqueada(msg: String) -> void:
	if label_conquista:
		label_conquista.text = "🏆 " + msg
		label_conquista.visible = true
		tempo_mensagem_conquista = 4
		label_conquista.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(label_conquista, "modulate:a", 1.0, 0.3)

func atualizar_interface() -> void:
	atualizar_labels_recurso()
	atualizar_labels_clima()
	atualizar_poluicao()
	atualizar_cidade()
	atualizar_loja()
	atualizar_upgrades()
	if painel_manutencao and painel_manutencao.visible:
		atualizar_manutencao()

func atualizar_labels_recurso():
	var cap_max = GameState.calcular_capacidade_maxima()
	if label_ouro and label_energia:
		var estado_tempo = "DIA ☀" if eh_dia else "NOITE 🌙"
		label_ouro.text = "Ouro: $%d | %s | Eficiência: %.0f%%" % [int(GameState.ouro), estado_tempo, GameState.eficiencia_global * 100]
		label_energia.text = ("Oferta: %.1f MW/s | Demanda: %.1f MW/s\n" % [GameState.oferta_atual, GameState.demanda_cidade]) + ("Bateria: %.1f / %.1f MW" % [GameState.energia_armazenada, cap_max])
	if botao_manivela:
		botao_manivela.text = "Girar Manivela (+%.1f MW)" % GameState.poder_manivela

func atualizar_labels_clima():
	if not label_clima: return
	var info = CLIMA_INFO[clima_atual]
	if clima_atual == Clima.NORMAL:
		label_clima.text = info.texto
	else:
		label_clima.text = "ALERTA: %s [%ds]" % [info.texto, tempo_clima_restante]

func atualizar_poluicao():
	if not label_poluicao: return
	var cor = "🟢"
	if GameState.poluicao > 30: cor = "🟡"
	if GameState.poluicao > 60: cor = "🟠"
	if GameState.poluicao > 85: cor = "🔴"
	label_poluicao.text = "%s Poluição: %.0f%%" % [cor, GameState.poluicao]
	if GameState.poluicao > 50:
		label_poluicao.text += " (Solar -%.0f%%)" % (GameState.poluicao * 0.5)
	if GameState.tecnicos_ambientais > 0:
		label_poluicao.text += " | 🌿 %d técnicos" % GameState.tecnicos_ambientais

func atualizar_cidade():
	if not label_cidade: return
	var info = GameState.get_cidade_atual_info()
	label_cidade.text = "📍 %s | Meta: %.0f / %.0f MW" % [info.nome, GameState.demanda_cidade, info.cap]
	if botao_migrar_cidade:
		botao_migrar_cidade.visible = GameState.pode_migrar_cidade()
		if botao_migrar_cidade.visible:
			var proxima = GameState.CIDADES[GameState.cidade_atual + 1].nome if GameState.cidade_atual + 1 < GameState.CIDADES.size() else "FIM"
			botao_migrar_cidade.text = "✈️ Migrar para %s (+15%%)" % proxima

func atualizar_loja() -> void:
	if botao_comprar_solar:
		var desc = GameState.DESCRICOES_GERADORES.get("solar", "")
		botao_comprar_solar.text = "Solar ($%d) +%.1f MW | Qtd: %d\n%s" % [
			int(GameState.get_preco("solar")), 
			GameState.producao_solar, 
			GameState.paineis_solares,
			desc
		]
		botao_comprar_solar.disabled = not GameState.pode_comprar("solar")

	if botao_comprar_eolica:
		botao_comprar_eolica.visible = GameState.paineis_solares >= 5
		if botao_comprar_eolica.visible:
			var desc = GameState.DESCRICOES_GERADORES.get("eolica", "")
			botao_comprar_eolica.text = "Eólica ($%d) +%.1f MW | Qtd: %d\n%s" % [
				int(GameState.get_preco("eolica")), 
				GameState.producao_eolica, 
				GameState.turbinas_eolicas,
				desc
			]
			botao_comprar_eolica.disabled = not GameState.pode_comprar("eolica")

	if botao_comprar_bateria:
		var desc = GameState.DESCRICOES_GERADORES.get("bateria", "Aumenta a capacidade de armazenamento.")
		botao_comprar_bateria.text = "Bateria ($%d) +%.1f MW | Qtd: %d\n%s" % [
			int(GameState.get_preco("bateria")), 
			GameState.capacidade_por_bateria, 
			GameState.baterias,
			desc
		]
		botao_comprar_bateria.disabled = not GameState.pode_comprar("bateria")

	if botao_comprar_carvao:
		botao_comprar_carvao.visible = GameState.turbinas_eolicas >= 5
		if botao_comprar_carvao.visible:
			var desc = GameState.DESCRICOES_GERADORES.get("carvao", "")
			botao_comprar_carvao.text = "Carvão ($%d) +%.1f MW | Qtd: %d 🔴\n%s" % [
				int(GameState.get_preco("carvao")), 
				GameState.producao_carvao, 
				GameState.usinas_carvao,
				desc
			]
			botao_comprar_carvao.disabled = not GameState.pode_comprar("carvao")

	if botao_comprar_geotermica:
		botao_comprar_geotermica.visible = GameState.usinas_carvao >= 2
		if botao_comprar_geotermica.visible:
			var desc = GameState.DESCRICOES_GERADORES.get("geotermica", "")
			botao_comprar_geotermica.text = "Geotérmica ($%d) +%.1f MW | Qtd: %d\n%s" % [
				int(GameState.get_preco("geotermica")), 
				GameState.producao_geotermica, 
				GameState.usinas_geotermicas,
				desc
			]
			botao_comprar_geotermica.disabled = not GameState.pode_comprar("geotermica")

	if botao_comprar_biomassa:
		botao_comprar_biomassa.visible = GameState.usinas_geotermicas >= 5
		if botao_comprar_biomassa.visible:
			var desc = GameState.DESCRICOES_GERADORES.get("biomassa", "")
			botao_comprar_biomassa.text = "Biomassa ($%d) +%.1f MW | Qtd: %d 🟢\n%s" % [
				int(GameState.get_preco("biomassa")), 
				GameState.producao_biomassa, 
				GameState.usinas_biomassa,
				desc
			]
			botao_comprar_biomassa.disabled = not GameState.pode_comprar("biomassa")

	if botao_comprar_hidreletrica:
		botao_comprar_hidreletrica.visible = GameState.usinas_biomassa >= 5
		if botao_comprar_hidreletrica.visible:
			var desc = GameState.DESCRICOES_GERADORES.get("hidreletrica", "")
			botao_comprar_hidreletrica.text = "Hidro ($%d) +%.1f MW | Qtd: %d\n%s" % [
				int(GameState.get_preco("hidreletrica")), 
				GameState.producao_hidreletrica, 
				GameState.hidreletricas,
				desc
			]
			botao_comprar_hidreletrica.disabled = not GameState.pode_comprar("hidreletrica")

	if botao_comprar_nuclear:
		botao_comprar_nuclear.visible = GameState.hidreletricas >= 5
		if botao_comprar_nuclear.visible:
			var desc = GameState.DESCRICOES_GERADORES.get("nuclear", "")
			botao_comprar_nuclear.text = "Nuclear ($%d) +%.1f MW | Qtd: %d\n%s" % [
				int(GameState.get_preco("nuclear")), 
				GameState.producao_nuclear, 
				GameState.reatores_nucleares,
				desc
			]
			botao_comprar_nuclear.disabled = not GameState.pode_comprar("nuclear")

	if botao_comprar_fusao:
		botao_comprar_fusao.visible = GameState.reatores_nucleares >= 5
		if botao_comprar_fusao.visible:
			var desc = GameState.DESCRICOES_GERADORES.get("fusao", "")
			botao_comprar_fusao.text = "Fusão ($%d) +%.1f MW | Qtd: %d 🟢\n%s" % [
				int(GameState.get_preco("fusao")), 
				GameState.producao_fusao, 
				GameState.reatores_fusao,
				desc
			]
			botao_comprar_fusao.disabled = not GameState.pode_comprar("fusao")
			
func atualizar_upgrades() -> void:
	if botao_upgrade_manivela:
		var desc = GameState.DESCRICOES_UPGRADES["up_manivela"]
		botao_upgrade_manivela.text = "Manivela Lvl %d ($%d) -> +%.1f MW\n%s" % [
			GameState.nivel_manivela, 
			int(GameState.get_preco("up_manivela")), 
			GameState.poder_manivela + 1.5,
			desc
		]
		botao_upgrade_manivela.disabled = not GameState.pode_comprar("up_manivela")

	if botao_upgrade_solar:
		botao_upgrade_solar.visible = GameState.paineis_solares > 0
		if botao_upgrade_solar.visible:
			var desc = GameState.DESCRICOES_UPGRADES["up_solar"]
			botao_upgrade_solar.text = "Células Lvl %d ($%d) -> %.1f MW/s\n%s" % [
				GameState.nivel_solar_upgrade, 
				int(GameState.get_preco("up_solar")), 
				GameState.producao_solar + 1.0,
				desc
			]
			botao_upgrade_solar.disabled = not GameState.pode_comprar("up_solar")

	if botao_upgrade_eolica:
		botao_upgrade_eolica.visible = GameState.turbinas_eolicas > 0
		if botao_upgrade_eolica.visible:
			var desc = GameState.DESCRICOES_UPGRADES["up_eolica"]
			botao_upgrade_eolica.text = "Pás Lvl %d ($%d) -> %.1f MW/s\n%s" % [
				GameState.nivel_eolica_upgrade, 
				int(GameState.get_preco("up_eolica")), 
				GameState.producao_eolica + 1.5,
				desc
			]
			botao_upgrade_eolica.disabled = not GameState.pode_comprar("up_eolica")

	if botao_upgrade_carvao:
		botao_upgrade_carvao.visible = GameState.usinas_carvao > 0
		if botao_upgrade_carvao.visible:
			var desc = GameState.DESCRICOES_UPGRADES["up_carvao"]
			botao_upgrade_carvao.text = "Caldeira Lvl %d ($%d) -> %.1f MW/s\n%s" % [
				GameState.nivel_carvao_upgrade, 
				int(GameState.get_preco("up_carvao")), 
				GameState.producao_carvao + 3.0,
				desc
			]
			botao_upgrade_carvao.disabled = not GameState.pode_comprar("up_carvao")

	if botao_upgrade_biomassa:
		botao_upgrade_biomassa.visible = GameState.usinas_biomassa > 0
		if botao_upgrade_biomassa.visible:
			var desc = GameState.DESCRICOES_UPGRADES["up_biomassa"]
			botao_upgrade_biomassa.text = "Compostagem Lvl %d ($%d) -> %.1f MW/s\n%s" % [
				GameState.nivel_biomassa_upgrade, 
				int(GameState.get_preco("up_biomassa")), 
				GameState.producao_biomassa + 1.5,
				desc
			]
			botao_upgrade_biomassa.disabled = not GameState.pode_comprar("up_biomassa")

	if botao_upgrade_geotermica:
		botao_upgrade_geotermica.visible = GameState.usinas_geotermicas > 0
		if botao_upgrade_geotermica.visible:
			var desc = GameState.DESCRICOES_UPGRADES["up_geotermica"]
			botao_upgrade_geotermica.text = "Perfuração Lvl %d ($%d) -> %.1f MW/s\n%s" % [
				GameState.nivel_geotermica_upgrade, 
				int(GameState.get_preco("up_geotermica")), 
				GameState.producao_geotermica + 3.0,
				desc
			]
			botao_upgrade_geotermica.disabled = not GameState.pode_comprar("up_geotermica")

	if botao_upgrade_hidreletrica:
		botao_upgrade_hidreletrica.visible = GameState.hidreletricas > 0
		if botao_upgrade_hidreletrica.visible:
			var desc = GameState.DESCRICOES_UPGRADES["up_hidreletrica"]
			botao_upgrade_hidreletrica.text = "Turbinas Hidro Lvl %d ($%d) -> %.1f MW/s\n%s" % [
				GameState.nivel_hidreletrica_upgrade, 
				int(GameState.get_preco("up_hidreletrica")), 
				GameState.producao_hidreletrica + 5.0,
				desc
			]
			botao_upgrade_hidreletrica.disabled = not GameState.pode_comprar("up_hidreletrica")

	if botao_upgrade_nuclear:
		botao_upgrade_nuclear.visible = GameState.reatores_nucleares > 0
		if botao_upgrade_nuclear.visible:
			var desc = GameState.DESCRICOES_UPGRADES["up_nuclear"]
			botao_upgrade_nuclear.text = "Fissão Lvl %d ($%d) -> %.1f MW/s\n%s" % [
				GameState.nivel_nuclear_upgrade, 
				int(GameState.get_preco("up_nuclear")), 
				GameState.producao_nuclear + 10.0,
				desc
			]
			botao_upgrade_nuclear.disabled = not GameState.pode_comprar("up_nuclear")
			
	if botao_upgrade_fusao:
		botao_upgrade_fusao.visible = GameState.reatores_fusao > 0
		if botao_upgrade_fusao.visible:
			var desc = GameState.DESCRICOES_UPGRADES.get("up_fusao", "")
			botao_upgrade_fusao.text = "Reator Lvl %d ($%d) -> %.1f MW/s\n%s" % [
				GameState.nivel_fusao_upgrade, 
				int(GameState.get_preco("up_fusao")), 
				GameState.producao_fusao + 35.0,
				desc
			]
			botao_upgrade_fusao.disabled = not GameState.pode_comprar("up_fusao")

func atualizar_manutencao():
	if not lista_manutencao: return
	for child in lista_manutencao.get_children():
		child.queue_free()

	# --- POLUIÇÃO ---
	var label_titulo_pol = Label.new()
	var prod_atual = 0.0
	for tipo in GameState.POLUICAO_POR_GERADOR.keys():
		var qtd = GameState.get_quantidade(tipo)
		prod_atual += qtd * GameState.POLUICAO_POR_GERADOR[tipo]
	
	var limpeza_amb = 0.0
	if GameState.tecnicos_ambientais > 0:
		var bonus_amb = 1.0 + min((GameState.tecnicos_ambientais - 1) * 0.08, 0.4)
		# usa a constante nova se existir, se não usa 0.45
		var base_amb = GameState.LIMPEZA_BASE_AMBIENTAL if "LIMPEZA_BASE_AMBIENTAL" in GameState else 0.45
		limpeza_amb = GameState.tecnicos_ambientais * base_amb * bonus_amb
	
	label_titulo_pol.text = "--- POLUIÇÃO ---\nPoluição: %.0f%% (%.1f/s) | 🌿 %d limpam %.1f/s" % [
		GameState.poluicao, prod_atual - limpeza_amb, GameState.tecnicos_ambientais, limpeza_amb
	]
	label_titulo_pol.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lista_manutencao.add_child(label_titulo_pol)

	var btn_filtro = Button.new()
	btn_filtro.text = "Filtro Carvão ($%d) [%s]" % [int(GameState.get_preco("filtro_carvao")), "ON" if GameState.filtro_carvao_ativo else "OFF"]
	btn_filtro.disabled = not GameState.pode_comprar("filtro_carvao")
	btn_filtro.pressed.connect(func(): _comprar("filtro_carvao"))
	lista_manutencao.add_child(btn_filtro)

	var btn_captura = Button.new()
	btn_captura.text = "Captura Carbono ($%d) [%s]" % [int(GameState.get_preco("captura_carbono")), "ON" if GameState.captura_carbono_ativa else "OFF"]
	btn_captura.disabled = not GameState.pode_comprar("captura_carbono")
	btn_captura.pressed.connect(func(): _comprar("captura_carbono"))
	lista_manutencao.add_child(btn_captura)

	var btn_tec_amb = Button.new()
	btn_tec_amb.text = "🌿 Técnico Ambiental ($%d) Qtd: %d" % [int(GameState.get_preco("tecnico_ambiental")), GameState.tecnicos_ambientais]
	btn_tec_amb.disabled = not GameState.pode_comprar("tecnico_ambiental")
	btn_tec_amb.pressed.connect(func(): _comprar("tecnico_ambiental"))
	lista_manutencao.add_child(btn_tec_amb)

	var separador = HSeparator.new()
	lista_manutencao.add_child(separador)

	# --- SAÚDE - UMA LABEL SÓ ---
	var total_geradores = GameState.get_total_geradores()
	
	var cap_por_tec = GameState.CAPACIDADE_POR_TECNICO if "CAPACIDADE_POR_TECNICO" in GameState else 12
	var base_reparo = GameState.REPARO_BASE_POR_TECNICO if "REPARO_BASE_POR_TECNICO" in GameState else 1.2
	
	var capacidade = GameState.tecnicos_manutencao * cap_por_tec
	var eficiencia = 1.0
	if total_geradores > 0 and capacidade > 0:
		eficiencia = min(1.0, float(capacidade) / float(total_geradores))
		if total_geradores > capacidade * 2:
			eficiencia *= 0.6

	var bonus_manut = 1.0
	if GameState.tecnicos_manutencao > 0:
		bonus_manut = 1.0 + min((GameState.tecnicos_manutencao - 1) * 0.08, 0.4)
	
	var poder_total = GameState.tecnicos_manutencao * base_reparo * bonus_manut * eficiencia
	var status = "OK" if eficiencia >= 0.9 else "SOBRECARREGADO!" if eficiencia < 0.5 else "ATENÇÃO"

	var label_titulo_manut = Label.new()
	label_titulo_manut.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_titulo_manut.text = "--- SAÚDE (%d Estruturas) ---\n🔧 %d técnicos (cap %d) | Eficiência: %.0f%% [%s]\nReparo total: %.2f%%/s" % [
		total_geradores, GameState.tecnicos_manutencao, capacidade, eficiencia * 100.0, status, poder_total
	]
	lista_manutencao.add_child(label_titulo_manut)

	var btn_tecnico = Button.new()
	btn_tecnico.text = "🔧 Contratar Técnico ($%d) Qtd: %d" % [int(GameState.get_preco("tecnico_manutencao")), GameState.tecnicos_manutencao]
	btn_tecnico.disabled = not GameState.pode_comprar("tecnico_manutencao")
	btn_tecnico.pressed.connect(func(): _comprar("tecnico_manutencao"))
	lista_manutencao.add_child(btn_tecnico)

	for tipo in ["solar", "eolica", "carvao", "geotermica", "biomassa", "hidreletrica", "nuclear", "fusao"]:
		var qtd = GameState.get_quantidade(tipo)
		if qtd <= 0: continue
		var saude = GameState.saude.get(tipo, 100.0)
		var barra = "████" if saude > 70 else "██░░" if saude > 40 else "█░░░" if saude > 15 else "░░░░"
		var label = Label.new()
		label.text = "%s x%d - %s %.0f%%" % [tipo.capitalize(), qtd, barra, saude]
		lista_manutencao.add_child(label)
		if saude < 95:
			var btn_rep = Button.new()
			var custo_base = {"solar":5, "eolica":8, "carvao":15, "geotermica":20, "biomassa":10, "hidreletrica":40, "nuclear":100, "fusao":200}.get(tipo, 5)
			var dano = 100.0 - saude
			var custo = int(qtd * custo_base * (dano / 100.0))
			custo = max(custo, int(custo_base * 0.2))
			btn_rep.text = "🔧 Consertar %s ($%d)" % [tipo.capitalize(), custo]
			btn_rep.disabled = GameState.ouro < custo
			btn_rep.pressed.connect(func(): reparar_tipo(tipo))
			lista_manutencao.add_child(btn_rep)

func reparar_tipo(tipo: String):
	if GameState.reparar(tipo):
		atualizar_manutencao()
		atualizar_interface()

func sortear_evento_climatico() -> void:
	var chance = rng.randf()
	if chance < 0.3:
		ativar_clima(Clima.TEMPESTADE)
	elif chance < 0.5:
		ativar_clima(Clima.ONDA_DE_CALOR)
	elif chance < 0.7:
		ativar_clima(Clima.SECA)
	elif chance < 0.85:
		ativar_clima(Clima.ECLIPSE)
	else:
		ativar_clima(Clima.NORMAL)

func ativar_clima(tipo: Clima):
	clima_atual = tipo
	var info = CLIMA_INFO[tipo]
	tempo_clima_restante = info.duracao
	mult_eolica = info.mult_eolica
	mult_solar = info.mult_solar
	mult_hidro = info.mult_hidro

func resetar_clima() -> void:
	clima_atual = Clima.NORMAL
	mult_eolica = 1.0
	mult_solar = 1.0
	mult_hidro = 1.0

func _on_button_pressed() -> void:
	_on_botao_manivela_pressed()

func _on_botao_manivela_pressed() -> void:
	if GameState.energia_armazenada < GameState.calcular_capacidade_maxima():
		GameState.energia_armazenada += GameState.poder_manivela

func _on_timer_timeout() -> void:
	var delta = 1.0
	tempo_ciclo += 1
	tempo_jogo += 1
	
	if tempo_mensagem_conquista > 0:
		tempo_mensagem_conquista -= 1
		if tempo_mensagem_conquista <= 0 and label_conquista:
			var tween = create_tween()
			tween.tween_property(label_conquista, "modulate:a", 0.0, 0.5)
			tween.tween_callback(func(): label_conquista.visible = false)
	
	if clima_atual != Clima.NORMAL:
		tempo_clima_restante -= 1
		if tempo_clima_restante <= 0: resetar_clima()
	else:
		tempo_proximo_evento -= 1
		if tempo_proximo_evento <= 0:
			sortear_evento_climatico()
			tempo_proximo_evento = rng.randi_range(20, 40)
	
	if tempo_jogo % 20 == 0 and not GameState.em_blackout:
		GameState.demanda_cidade = min(GameState.demanda_cidade * 1.12, GameState.get_cap_atual())

	if tempo_ciclo >= duracao_ciclo:
		tempo_ciclo = 0
		eh_dia = not eh_dia
	
	var demanda_efetiva = GameState.demanda_cidade * (1.5 if clima_atual == Clima.ONDA_DE_CALOR else 1.0)
	GameState.oferta_atual = GameState.calcular_oferta_bruta(eh_dia, mult_eolica, mult_solar, mult_hidro)
	var cap_max = GameState.calcular_capacidade_maxima()
	
	GameState.atualizar_poluicao(delta)
	GameState.desgastar(delta, clima_atual)
	
	if GameState.oferta_atual >= demanda_efetiva:
		var excesso = GameState.oferta_atual - demanda_efetiva
		GameState.energia_armazenada = min(GameState.energia_armazenada + excesso, cap_max)
		GameState.ouro += demanda_efetiva * 1.5
		GameState.em_blackout = false
		if label_blackout: label_blackout.visible = false
	else:
		var deficit = demanda_efetiva - GameState.oferta_atual
		if GameState.energia_armazenada >= deficit:
			GameState.energia_armazenada -= deficit
			GameState.ouro += demanda_efetiva * 1.5
			GameState.em_blackout = false
			if label_blackout: label_blackout.visible = false
		else:
			var entregue = GameState.oferta_atual + GameState.energia_armazenada
			GameState.energia_armazenada = 0.0
			GameState.ouro += entregue * 0.5
			GameState.em_blackout = true
			if label_blackout:
				label_blackout.visible = true
				label_blackout.text = "⚠ BLACKOUT! DEMANDA CONGELADA!"

func mudar_visibilidade_botoes(visivel: bool) -> void:
	if botao_manivela: botao_manivela.visible = visivel
	if botao_abrir_loja: botao_abrir_loja.visible = visivel
	if botao_abrir_upgrades: botao_abrir_upgrades.visible = visivel
	if botao_abrir_conquistas: botao_abrir_conquistas.visible = visivel
	if botao_abrir_manutencao: botao_abrir_manutencao.visible = visivel
	if botao_migrar_cidade: botao_migrar_cidade.visible = visivel and GameState.pode_migrar_cidade()

func _on_botao_abrir_loja_pressed() -> void:
	if painel_loja: painel_loja.visible = true
	mudar_visibilidade_botoes(false)
func _on_botao_fechar_loja_pressed() -> void:
	if painel_loja: painel_loja.visible = false
	mudar_visibilidade_botoes(true)
func _on_botao_abrir_upgrades_pressed() -> void:
	if painel_upgrades: painel_upgrades.visible = true
	mudar_visibilidade_botoes(false)
func _on_botao_fechar_upgrades_pressed() -> void:
	if painel_upgrades: painel_upgrades.visible = false
	mudar_visibilidade_botoes(true)
func _on_botao_abrir_conquistas_pressed() -> void:
	if achievement_manager and lista_conquistas:
		achievement_manager.renderizar_lista(lista_conquistas)
	if painel_conquistas: painel_conquistas.visible = true
	mudar_visibilidade_botoes(false)
func _on_botao_fechar_conquistas_pressed() -> void:
	if painel_conquistas: painel_conquistas.visible = false
	mudar_visibilidade_botoes(true)
func _on_botao_abrir_manutencao_pressed() -> void:
	atualizar_manutencao()
	if painel_manutencao: painel_manutencao.visible = true
	mudar_visibilidade_botoes(false)
func _on_botao_fechar_manutencao_pressed() -> void:
	if painel_manutencao: painel_manutencao.visible = false
	mudar_visibilidade_botoes(true)
func _on_botao_migrar_cidade_pressed() -> void:
	if GameState.migrar_cidade():
		if achievement_manager and achievement_manager.has_method("resetar_conquistas"):
			achievement_manager.resetar_conquistas()
		atualizar_interface()

func _comprar(tipo: String):
	if GameState.comprar(tipo):
		if achievement_manager:
			achievement_manager.verificar_marcos_e_conquistas()
		if painel_manutencao and painel_manutencao.visible:
			atualizar_manutencao()

func _on_botao_comprar_solar_pressed(): _comprar("solar")
func _on_botao_comprar_eolica_pressed(): _comprar("eolica")
func _on_botao_comprar_bateria_pressed(): _comprar("bateria")
func _on_botao_comprar_carvao_pressed(): _comprar("carvao")
func _on_botao_comprar_geotermica_pressed(): _comprar("geotermica")
func _on_botao_comprar_biomassa_pressed(): _comprar("biomassa")
func _on_botao_comprar_hidreletrica_pressed(): _comprar("hidreletrica")
func _on_botao_comprar_nuclear_pressed(): _comprar("nuclear")
func _on_botao_comprar_fusao_pressed(): _comprar("fusao")
func _on_botao_upgrade_manivela_pressed(): _comprar("up_manivela")
func _on_botao_upgrade_solar_pressed(): _comprar("up_solar")
func _on_botao_upgrade_eolica_pressed(): _comprar("up_eolica")
func _on_botao_upgrade_carvao_pressed(): _comprar("up_carvao")
func _on_botao_upgrade_biomassa_pressed(): _comprar("up_biomassa")
func _on_botao_upgrade_geotermica_pressed(): _comprar("up_geotermica")
func _on_botao_upgrade_hidreletrica_pressed(): _comprar("up_hidreletrica")
func _on_botao_upgrade_nuclear_pressed(): _comprar("up_nuclear")
func _on_botao_upgrade_fusao_pressed(): _comprar("up_fusao")


func _unhandled_input(event):
	if not MODO_TESTE: return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1: # + ouro
				GameState.ouro += 10000
				print("Cheat: +10k ouro")
			KEY_F2: # + bateria cheia
				GameState.energia_armazenada = GameState.calcular_capacidade_maxima()
			KEY_F3: # libera tudo
				GameState.paineis_solares = 10
				GameState.turbinas_eolicas = 10
				GameState.usinas_carvao = 5
				GameState.usinas_geotermicas = 5
				GameState.usinas_biomassa = 5
				GameState.hidreletricas = 5
				GameState.reatores_nucleares = 5
				GameState.reatores_fusao = 5
				GameState.baterias = 20
				GameState.recalcular_tudo()
			KEY_F4: # repara tudo
				for tipo in GameState.saude.keys():
					GameState.saude[tipo] = 100.0
			KEY_F5: # limpa poluição
				GameState.poluicao = 0.0
			KEY_F6: # avança cidade
				GameState.demanda_cidade = GameState.get_cap_atual()
				_on_botao_migrar_cidade_pressed()
			KEY_F7: # alterna velocidade 1x / 5x / 20x
				if has_node("Timer"):
					if $Timer.wait_time > 0.3:
						$Timer.wait_time = 0.05
						print("Teste: 20x")
					elif $Timer.wait_time > 0.1:
						$Timer.wait_time = 1.0
						print("Teste: 1x normal")
					else:
						$Timer.wait_time = 0.2
						print("Teste: 5x")
			KEY_F8: # zera preços
				for k in GameState.precos.keys():
					GameState.precos[k] = 1.0
				print("Cheat: tudo por $1")
		atualizar_interface()

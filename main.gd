extends Node2D
# main.gd - COM LABEL DE CONQUISTA SEPARADO (embaixo do clima)

enum Clima { NORMAL, TEMPESTADE, ECLIPSE, ONDA_DE_CALOR }

const CLIMA_INFO = {
		Clima.NORMAL: {"texto": "Clima: Estável 🌤", "mult_eolica": 1.0, "mult_solar": 1.0},
		Clima.TEMPESTADE: {"texto": "⚡ TEMPESTADE! Eólicas 3x", "mult_eolica": 3.0, "mult_solar": 1.0, "duracao": 15},
		Clima.ECLIPSE: {"texto": "🌑 ECLIPSE! Solares OFF", "mult_eolica": 1.0, "mult_solar": 0.0, "duracao": 10},
		Clima.ONDA_DE_CALOR: {"texto": "🔥 ONDA DE CALOR! Demanda +50%", "mult_eolica": 1.0, "mult_solar": 1.0, "duracao": 12},
}

var clima_atual: Clima = Clima.NORMAL
var tempo_clima_restante: int = 0
var tempo_proximo_evento: int = 30
var mult_eolica: float = 1.0
var mult_solar: float = 1.0

var eh_dia: bool = true
var tempo_ciclo: int = 0
var duracao_ciclo: int = 30
var tempo_jogo: int = 0

var tempo_mensagem_conquista: int = 0

var rng = RandomNumberGenerator.new()

@onready var achievement_manager: Node = $AchievementManager
@onready var label_ouro: Label = $LabelOuro
@onready var label_energia: Label = $LabelEnergia
@onready var label_blackout: Label = $LabelBlackout
@onready var label_clima: Label = $LabelClima
# NOVO - Label separado pra conquista (crie na cena)
@onready var label_conquista: Label = $LabelConquista 
@onready var botao_manivela: Button = $BotaoManivela
@onready var botao_abrir_loja: Button = $BotaoAbrirLoja
@onready var botao_abrir_upgrades: Button = $BotaoAbrirUpgrades
@onready var botao_abrir_conquistas: Button = $BotaoAbrirConquistas

@onready var painel_loja: PanelContainer = $PainelLoja
@onready var painel_upgrades: PanelContainer = $PainelUpgrades
@onready var painel_conquistas: PanelContainer = $PainelConquistas
@onready var lista_conquistas: VBoxContainer = $PainelConquistas/VBoxContainer/ScrollConquistas/ListaConquistas

@onready var botao_comprar_solar: Button = $PainelLoja/VBoxContainer/BotaoComprarSolar
@onready var botao_comprar_eolica: Button = $PainelLoja/VBoxContainer/BotaoComprarEolica
@onready var botao_comprar_geotermica: Button = $PainelLoja/VBoxContainer/BotaoComprarGeotermica
@onready var botao_comprar_nuclear: Button = $PainelLoja/VBoxContainer/BotaoComprarNuclear
@onready var botao_comprar_bateria: Button = $PainelLoja/VBoxContainer/BotaoComprarBateria

@onready var botao_upgrade_manivela: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeManivela
@onready var botao_upgrade_solar: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeSolar
@onready var botao_upgrade_eolica: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeEolica
@onready var botao_upgrade_geotermica: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeGeotermica
@onready var botao_upgrade_nuclear: Button = $PainelUpgrades/VBoxContainer/BotaoUpgradeNuclear

func _ready() -> void:
		rng.randomize()
		if label_blackout: label_blackout.visible = false
		if painel_loja: painel_loja.visible = false
		if painel_upgrades: painel_upgrades.visible = false
		if painel_conquistas: painel_conquistas.visible = false
		if label_conquista: 
				label_conquista.visible = false
				# Deixa mais bonito - pode ajustar no editor também
				label_conquista.modulate = Color(1, 1, 0.5) 
		
		if GameState.has_signal("recurso_mudou"):
				GameState.recurso_mudou.connect(atualizar_interface)
				GameState.producao_mudou.connect(atualizar_interface)
		
		if achievement_manager and achievement_manager.has_signal("conquista_desbloqueada"):
				if not achievement_manager.conquista_desbloqueada.is_connected(_on_conquista_desbloqueada):
						achievement_manager.conquista_desbloqueada.connect(_on_conquista_desbloqueada)
				
		atualizar_interface()

func _on_conquista_desbloqueada(msg: String) -> void:
		if label_conquista:
				label_conquista.text = "🏆 " + msg
				label_conquista.visible = true
				tempo_mensagem_conquista = 4
				# Animaçãozinha simples de aparecer
				label_conquista.modulate.a = 0
				var tween = create_tween()
				tween.tween_property(label_conquista, "modulate:a", 1.0, 0.3)

func atualizar_interface() -> void:
		var cap_max = GameState.calcular_capacidade_maxima()
		
		if label_ouro != null and label_energia != null:
				var estado_tempo = "DIA ☀" if eh_dia else "NOITE 🌙"
				label_ouro.text = "Ouro: $%d | %s" % [int(GameState.ouro), estado_tempo]
				label_energia.text = ("Oferta: %.1f MW/s | Demanda: %.1f MW/s\n" % [GameState.oferta_atual, GameState.demanda_cidade]) + \
														 ("Bateria: %.1f / %.1f MW" % [GameState.energia_armazenada, cap_max])
		
		# CLIMA AGORA SEMPRE APARECE - não é mais sobrescrito pela conquista
		if label_clima != null:
				var info = CLIMA_INFO[clima_atual]
				if clima_atual == Clima.NORMAL:
						label_clima.text = info.texto
				else:
						label_clima.text = "ALERTA: %s [%ds]" % [info.texto, tempo_clima_restante]

		if botao_manivela != null:
				botao_manivela.text = "Girar Manivela (+%.1f MW)" % GameState.poder_manivela
		
		if botao_comprar_solar != null:
				botao_comprar_solar.text = "Painel Solar ($%d)\nGera: +%.1f MW/s | Qtd: %d" % [int(GameState.get_preco("solar")), GameState.producao_solar, GameState.paineis_solares]
				botao_comprar_solar.disabled = not GameState.pode_comprar("solar")
		
		if botao_comprar_eolica != null:
				var desbloqueado = GameState.paineis_solares >= 5
				botao_comprar_eolica.visible = desbloqueado
				if desbloqueado:
						botao_comprar_eolica.text = "Turbina Eólica ($%d)\nGera: +%.1f MW/s | Qtd: %d" % [int(GameState.get_preco("eolica")), GameState.producao_eolica, GameState.turbinas_eolicas]
						botao_comprar_eolica.disabled = not GameState.pode_comprar("eolica")
		
		if botao_comprar_geotermica != null:
				var desbloqueado = GameState.turbinas_eolicas >= 5
				botao_comprar_geotermica.visible = desbloqueado
				if desbloqueado:
						botao_comprar_geotermica.text = "Usina Geotérmica ($%d)\nGera: +%.1f MW/s | Qtd: %d" % [int(GameState.get_preco("geotermica")), GameState.producao_geotermica, GameState.usinas_geotermicas]
						botao_comprar_geotermica.disabled = not GameState.pode_comprar("geotermica")
		
		if botao_comprar_nuclear != null:
				var desbloqueado = GameState.usinas_geotermicas >= 5
				botao_comprar_nuclear.visible = desbloqueado
				if desbloqueado:
						botao_comprar_nuclear.text = "Reator Nuclear ($%d)\nGera: +%.1f MW/s | Qtd: %d" % [int(GameState.get_preco("nuclear")), GameState.producao_nuclear, GameState.reatores_nucleares]
						botao_comprar_nuclear.disabled = not GameState.pode_comprar("nuclear")
		
		if botao_comprar_bateria != null:
				botao_comprar_bateria.text = "Bateria ($%d)\nCapacidade: +%.1f MW | Qtd: %d" % [int(GameState.get_preco("bateria")), GameState.capacidade_por_bateria, GameState.baterias]
				botao_comprar_bateria.disabled = not GameState.pode_comprar("bateria")

		if botao_upgrade_manivela != null:
				botao_upgrade_manivela.text = "Manivela Reforçada Lvl %d ($%d)\nAumenta para +%.1f MW por clique" % [GameState.nivel_manivela, int(GameState.get_preco("up_manivela")), GameState.poder_manivela + 1.5]
				botao_upgrade_manivela.disabled = not GameState.pode_comprar("up_manivela")
		
		if botao_upgrade_solar != null:
				botao_upgrade_solar.visible = GameState.paineis_solares > 0
				if botao_upgrade_solar.visible:
						botao_upgrade_solar.text = "Células Fotovoltaicas Lvl %d ($%d)\nAumenta solar para +%.1f MW/s" % [GameState.nivel_solar_upgrade, int(GameState.get_preco("up_solar")), GameState.producao_solar + 1.0]
						botao_upgrade_solar.disabled = not GameState.pode_comprar("up_solar")
		
		if botao_upgrade_eolica != null:
				botao_upgrade_eolica.visible = GameState.turbinas_eolicas > 0
				if botao_upgrade_eolica.visible:
						botao_upgrade_eolica.text = "Pás Aerodinâmicas Lvl %d ($%d)\nAumenta eólica para +%.1f MW/s" % [GameState.nivel_eolica_upgrade, int(GameState.get_preco("up_eolica")), GameState.producao_eolica + 1.5]
						botao_upgrade_eolica.disabled = not GameState.pode_comprar("up_eolica")
		
		if botao_upgrade_geotermica != null:
				botao_upgrade_geotermica.visible = GameState.usinas_geotermicas > 0
				if botao_upgrade_geotermica.visible:
						botao_upgrade_geotermica.text = "Perfuração Profunda Lvl %d ($%d)\nAumenta geotérmica para +%.1f MW/s" % [GameState.nivel_geotermica_upgrade, int(GameState.get_preco("up_geotermica")), GameState.producao_geotermica + 3.0]
						botao_upgrade_geotermica.disabled = not GameState.pode_comprar("up_geotermica")
		
		if botao_upgrade_nuclear != null:
				botao_upgrade_nuclear.visible = GameState.reatores_nucleares > 0
				if botao_upgrade_nuclear.visible:
						botao_upgrade_nuclear.text = "Fissão Avançada Lvl %d ($%d)\nAumenta nuclear para +%.1f MW/s" % [GameState.nivel_nuclear_upgrade, int(GameState.get_preco("up_nuclear")), GameState.producao_nuclear + 10.0]
						botao_upgrade_nuclear.disabled = not GameState.pode_comprar("up_nuclear")

func sortear_evento_climatico() -> void:
		var chance = rng.randf()
		if chance < 0.4:
				ativar_clima(Clima.TEMPESTADE)
		elif chance < 0.7:
				ativar_clima(Clima.ONDA_DE_CALOR)
		else:
				ativar_clima(Clima.ECLIPSE)

func ativar_clima(tipo: Clima):
		clima_atual = tipo
		var info = CLIMA_INFO[tipo]
		tempo_clima_restante = info.duracao
		mult_eolica = info.mult_eolica
		mult_solar = info.mult_solar

func resetar_clima() -> void:
		clima_atual = Clima.NORMAL
		mult_eolica = 1.0
		mult_solar = 1.0

func _on_button_pressed() -> void:
		_on_botao_manivela_pressed()

func _on_botao_manivela_pressed() -> void:
		if GameState.energia_armazenada < GameState.calcular_capacidade_maxima():
				GameState.energia_armazenada += GameState.poder_manivela

func _on_timer_timeout() -> void:
		tempo_ciclo += 1
		tempo_jogo += 1
		
		if tempo_mensagem_conquista > 0:
				tempo_mensagem_conquista -= 1
				if tempo_mensagem_conquista <= 0 and label_conquista:
						# Fade out suave
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
						tempo_proximo_evento = rng.randi_range(25, 45)
		
		if tempo_jogo % 20 == 0 and not GameState.em_blackout:
				GameState.demanda_cidade = min(GameState.demanda_cidade * 1.12, GameState.DEMANDA_MAX)

		if tempo_ciclo >= duracao_ciclo:
				tempo_ciclo = 0
				eh_dia = not eh_dia
		
		var demanda_efetiva = GameState.demanda_cidade * (1.5 if clima_atual == Clima.ONDA_DE_CALOR else 1.0)
		GameState.oferta_atual = GameState.calcular_oferta_bruta(eh_dia, mult_eolica, mult_solar)
		var cap_max = GameState.calcular_capacidade_maxima()
		
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

func _comprar(tipo: String):
		if GameState.comprar(tipo):
				if achievement_manager:
						achievement_manager.verificar_marcos_e_conquistas()

func _on_botao_comprar_solar_pressed(): _comprar("solar")
func _on_botao_comprar_eolica_pressed(): _comprar("eolica")
func _on_botao_comprar_geotermica_pressed(): _comprar("geotermica")
func _on_botao_comprar_nuclear_pressed(): _comprar("nuclear")
func _on_botao_comprar_bateria_pressed(): _comprar("bateria")
func _on_botao_upgrade_manivela_pressed(): _comprar("up_manivela")
func _on_botao_upgrade_solar_pressed(): _comprar("up_solar")
func _on_botao_upgrade_eolica_pressed(): _comprar("up_eolica")
func _on_botao_upgrade_geotermica_pressed(): _comprar("up_geotermica")
func _on_botao_upgrade_nuclear_pressed(): _comprar("up_nuclear")

# SkillTreeManager.gd - Árvore de Habilidades
extends Node

signal habilidade_desbloqueada(habilidade: Dictionary)
signal pontos_mudou(pontos: int)

# ============================================================================
# DEFINIÇÃO DAS 50 HABILIDADES
# ============================================================================
const HABILIDADES: Array[Dictionary] = [
	# ─── ÁRVORE SOLAR (10) ───
	{"id": "solar_1", "nome": "Células Eficientes I", "desc": "+20% produção solar", "arvore": "solar", "custo": 1, "requer": [], "efeito": {"producao_solar": 0.20}},
	{"id": "solar_2", "nome": "Células Eficientes II", "desc": "+20% produção solar", "arvore": "solar", "custo": 1, "requer": ["solar_1"], "efeito": {"producao_solar": 0.20}},
	{"id": "solar_3", "nome": "Células Eficientes III", "desc": "+20% produção solar", "arvore": "solar", "custo": 1, "requer": ["solar_2"], "efeito": {"producao_solar": 0.20}},
	{"id": "solar_4", "nome": "Painéis Noturnos", "desc": "Solar gera 10% à noite", "arvore": "solar", "custo": 1, "requer": [], "efeito": {"solar_noturno": 0.10}},
	{"id": "solar_5", "nome": "Resistência ao Calor", "desc": "Solar sofre -30% em Onda de Calor", "arvore": "solar", "custo": 1, "requer": ["solar_1"], "efeito": {"solar_resist_calor": 0.30}},
	{"id": "solar_6", "nome": "Auto-Limpeza", "desc": "Solar desgasta 25% mais devagar", "arvore": "solar", "custo": 1, "requer": ["solar_2"], "efeito": {"solar_desgaste": -0.25}},
	{"id": "solar_7", "nome": "Inversor Avançado", "desc": "+15% eficiência de solar", "arvore": "solar", "custo": 1, "requer": ["solar_3"], "efeito": {"producao_solar": 0.15}},
	{"id": "solar_8", "nome": "Fazenda Solar", "desc": "Cada painel dá +0.1 MW extra", "arvore": "solar", "custo": 1, "requer": ["solar_6"], "efeito": {"solar_bonus_fixo": 0.1}},
	{"id": "solar_9", "nome": "Resistente ao Eclipse", "desc": "Eclipse só reduz 50% (em vez de 100%)", "arvore": "solar", "custo": 1, "requer": ["solar_4"], "efeito": {"solar_eclipse_resist": 0.5}},
	{"id": "solar_10", "nome": "Supernova", "desc": "Solar ignora penalidade de poluição", "arvore": "solar", "custo": 1, "requer": ["solar_7", "solar_8"], "efeito": {"solar_ignora_poluicao": true}},
	
	# ─── ÁRVORE EÓLICA (10) ───
	{"id": "eolica_1", "nome": "Pás Aerodinâmicas I", "desc": "+20% produção eólica", "arvore": "eolica", "custo": 1, "requer": [], "efeito": {"producao_eolica": 0.20}},
	{"id": "eolica_2", "nome": "Pás Aerodinâmicas II", "desc": "+20% produção eólica", "arvore": "eolica", "custo": 1, "requer": ["eolica_1"], "efeito": {"producao_eolica": 0.20}},
	{"id": "eolica_3", "nome": "Pás Aerodinâmicas III", "desc": "+20% produção eólica", "arvore": "eolica", "custo": 1, "requer": ["eolica_2"], "efeito": {"producao_eolica": 0.20}},
	{"id": "eolica_4", "nome": "Tempestade Perfeita", "desc": "Eólica 4x em tempestade (em vez de 3x)", "arvore": "eolica", "custo": 1, "requer": [], "efeito": {"eolica_tempestade_bonus": 1.0}},
	{"id": "eolica_5", "nome": "Manutenção Preventiva", "desc": "Eólica desgasta 30% mais devagar", "arvore": "eolica", "custo": 1, "requer": ["eolica_1"], "efeito": {"eolica_desgaste": -0.30}},
	{"id": "eolica_6", "nome": "Torres Altas", "desc": "+15% produção base eólica", "arvore": "eolica", "custo": 1, "requer": ["eolica_2"], "efeito": {"producao_eolica": 0.15}},
	{"id": "eolica_7", "nome": "Rede Inteligente", "desc": "+5% eficiência global por turbina (max 50%)", "arvore": "eolica", "custo": 1, "requer": ["eolica_3"], "efeito": {"eolica_rede_inteligente": 0.05}},
	{"id": "eolica_8", "nome": "Fura-Vento", "desc": "Eólica não sofre com Seca", "arvore": "eolica", "custo": 1, "requer": ["eolica_5"], "efeito": {"eolica_ignora_seca": true}},
	{"id": "eolica_9", "nome": "Giro Contínuo", "desc": "Eólica gera 20% mesmo sem vento", "arvore": "eolica", "custo": 1, "requer": ["eolica_6"], "efeito": {"eolica_minimo": 0.20}},
	{"id": "eolica_10", "nome": "Furacão", "desc": "Tempestade dá 5x em vez de 3x", "arvore": "eolica", "custo": 1, "requer": ["eolica_4", "eolica_7"], "efeito": {"eolica_tempestade_bonus": 2.0}},
	
	# ─── ÁRVORE AMBIENTAL (10) ───
	{"id": "amb_1", "nome": "Filtro Básico", "desc": "-10% poluição de carvão", "arvore": "ambiental", "custo": 1, "requer": [], "efeito": {"carvao_poluicao": -0.10}},
	{"id": "amb_2", "nome": "Filtro Avançado", "desc": "-20% poluição de carvão", "arvore": "ambiental", "custo": 1, "requer": ["amb_1"], "efeito": {"carvao_poluicao": -0.20}},
	{"id": "amb_3", "nome": "Captura I", "desc": "Captura de carbono limpa 50% mais", "arvore": "ambiental", "custo": 1, "requer": [], "efeito": {"captura_bonus": 0.50}},
	{"id": "amb_4", "nome": "Captura II", "desc": "Captura limpa 100% mais", "arvore": "ambiental", "custo": 1, "requer": ["amb_3"], "efeito": {"captura_bonus": 1.0}},
	{"id": "amb_5", "nome": "Técnicos Verdes I", "desc": "Ambientais limpam 25% mais", "arvore": "ambiental", "custo": 1, "requer": [], "efeito": {"ambiental_bonus": 0.25}},
	{"id": "amb_6", "nome": "Técnicos Verdes II", "desc": "Ambientais limpam 50% mais", "arvore": "ambiental", "custo": 1, "requer": ["amb_5"], "efeito": {"ambiental_bonus": 0.50}},
	{"id": "amb_7", "nome": "Respiro Natural", "desc": "Limpeza passiva dobra (0.08 → 0.16/s)", "arvore": "ambiental", "custo": 1, "requer": ["amb_2"], "efeito": {"respiro_dobro": true}},
	{"id": "amb_8", "nome": "Biomassa Potente", "desc": "Biomassa limpa o dobro", "arvore": "ambiental", "custo": 1, "requer": ["amb_5"], "efeito": {"biomassa_limpeza_dobro": true}},
	{"id": "amb_9", "nome": "Fusão Limpa", "desc": "Fusão limpa o dobro (-0.6)", "arvore": "ambiental", "custo": 1, "requer": ["amb_6"], "efeito": {"fusao_limpeza_dobro": true}},
	{"id": "amb_10", "nome": "Carbono Zero", "desc": "Poluição nunca passa de 50%", "arvore": "ambiental", "custo": 1, "requer": ["amb_7", "amb_9"], "efeito": {"poluicao_max": 50.0}},
	
	# ─── ÁRVORE ECONOMIA (10) ───
	{"id": "eco_1", "nome": "Desconto Solar", "desc": "Solar 10% mais barato", "arvore": "economia", "custo": 1, "requer": [], "efeito": {"preco_solar": -0.10}},
	{"id": "eco_2", "nome": "Desconto Eólico", "desc": "Eólica 10% mais barato", "arvore": "economia", "custo": 1, "requer": [], "efeito": {"preco_eolica": -0.10}},
	{"id": "eco_3", "nome": "Desconto Nuclear", "desc": "Nuclear 10% mais barato", "arvore": "economia", "custo": 1, "requer": [], "efeito": {"preco_nuclear": -0.10}},
	{"id": "eco_4", "nome": "Desconto Fusão", "desc": "Fusão 15% mais barato", "arvore": "economia", "custo": 1, "requer": ["eco_3"], "efeito": {"preco_fusao": -0.15}},
	{"id": "eco_5", "nome": "Ouro Fácil I", "desc": "+10% ouro ganho", "arvore": "economia", "custo": 1, "requer": [], "efeito": {"ouro_bonus": 0.10}},
	{"id": "eco_6", "nome": "Ouro Fácil II", "desc": "+20% ouro ganho", "arvore": "economia", "custo": 1, "requer": ["eco_5"], "efeito": {"ouro_bonus": 0.20}},
	{"id": "eco_7", "nome": "Ouro Fácil III", "desc": "+30% ouro ganho", "arvore": "economia", "custo": 1, "requer": ["eco_6"], "efeito": {"ouro_bonus": 0.30}},
	{"id": "eco_8", "nome": "Preços Estáveis", "desc": "Multiplicador de preço 1.10 em vez de 1.15", "arvore": "economia", "custo": 1, "requer": ["eco_1", "eco_2"], "efeito": {"multiplicador_preco_reduz": true}},
	{"id": "eco_9", "nome": "Blackout Shield", "desc": "Em blackout, ganha 75% em vez de 50%", "arvore": "economia", "custo": 1, "requer": ["eco_5"], "efeito": {"blackout_melhor": true}},
	{"id": "eco_10", "nome": "Investidor", "desc": "Começa cada cidade com $500", "arvore": "economia", "custo": 1, "requer": ["eco_7", "eco_8"], "efeito": {"ouro_inicial": 500}},
	
	# ─── ÁRVORE GERAL (10) ───
	{"id": "geral_1", "nome": "Manivela Forte I", "desc": "+50% poder da manivela", "arvore": "geral", "custo": 1, "requer": [], "efeito": {"poder_manivela": 0.50}},
	{"id": "geral_2", "nome": "Manivela Forte II", "desc": "+100% poder da manivela", "arvore": "geral", "custo": 1, "requer": ["geral_1"], "efeito": {"poder_manivela": 1.0}},
	{"id": "geral_3", "nome": "Bateria Grande I", "desc": "+25% capacidade de bateria", "arvore": "geral", "custo": 1, "requer": [], "efeito": {"capacidade_bateria": 0.25}},
	{"id": "geral_4", "nome": "Bateria Grande II", "desc": "+50% capacidade de bateria", "arvore": "geral", "custo": 1, "requer": ["geral_3"], "efeito": {"capacidade_bateria": 0.50}},
	{"id": "geral_5", "nome": "Técnico Eficiente I", "desc": "Técnicos reparam 25% mais", "arvore": "geral", "custo": 1, "requer": [], "efeito": {"reparo_bonus": 0.25}},
	{"id": "geral_6", "nome": "Técnico Eficiente II", "desc": "Técnicos reparam 50% mais", "arvore": "geral", "custo": 1, "requer": ["geral_5"], "efeito": {"reparo_bonus": 0.50}},
	{"id": "geral_7", "nome": "Capacidade Extra", "desc": "Cada técnico suporta +3 geradores", "arvore": "geral", "custo": 1, "requer": ["geral_5"], "efeito": {"capacidade_tecnico_extra": 3}},
	{"id": "geral_8", "nome": "Resistência Global", "desc": "Todos desgastam 15% mais devagar", "arvore": "geral", "custo": 1, "requer": ["geral_6"], "efeito": {"desgaste_global": -0.15}},
	{"id": "geral_9", "nome": "Demanda Controlada", "desc": "Demanda cresce 10% mais devagar", "arvore": "geral", "custo": 1, "requer": ["geral_7"], "efeito": {"demanda_cresce_menos": 0.10}},
	{"id": "geral_10", "nome": "Migração Rápida", "desc": "+25% bônus ao migrar (substitui 15%)", "arvore": "geral", "custo": 1, "requer": ["geral_8", "geral_9"], "efeito": {"migracao_bonus": 0.25}},
]

# ============================================================================
# VARIÁVEIS DE ESTADO
# ============================================================================
var pontos_disponiveis: int = 0
var desbloqueadas: Dictionary = {}
var bonus_cache: Dictionary = {}

# ============================================================================
# INICIALIZAÇÃO
# ============================================================================
func _ready() -> void:
	for h in HABILIDADES:
		desbloqueadas[h.id] = false
	_calcular_bonus_cache()

# ============================================================================
# FUNÇÕES PRINCIPAIS
# ============================================================================
func _get_habilidade(id: String) -> Dictionary:
	for h in HABILIDADES:
		if h.id == id:
			return h
	return {}

func pode_desbloquear(id: String) -> bool:
	var hab = _get_habilidade(id)
	if hab.is_empty(): return false
	if desbloqueadas.get(id, false): return false
	if pontos_disponiveis < hab.custo: return false
	for req in hab.requer:
		if not desbloqueadas.get(req, false):
			return false
	return true

func desbloquear(id: String) -> bool:
	if not pode_desbloquear(id):
		return false
	
	desbloqueadas[id] = true
	pontos_disponiveis -= 1
	_calcular_bonus_cache()
	
	var hab = _get_habilidade(id)
	habilidade_desbloqueada.emit(hab)
	pontos_mudou.emit(pontos_disponiveis)
	
	print(" Habilidade desbloqueada: %s" % hab.nome)
	return true

func adicionar_pontos(qtd: int = 1):
	pontos_disponiveis += qtd
	pontos_mudou.emit(pontos_disponiveis)
	print(" +%d ponto(s) de habilidade! Total: %d" % [qtd, pontos_disponiveis])

# ============================================================================
# CÁLCULO DE BÔNUS
# ============================================================================
func _calcular_bonus_cache():
	bonus_cache = {
		"producao_solar": 0.0,
		"producao_eolica": 0.0,
		"producao_geotermica": 0.0,
		"producao_nuclear": 0.0,
		"producao_fusao": 0.0,
		"producao_hidreletrica": 0.0,
		"producao_carvao": 0.0,
		"producao_biomassa": 0.0,
		"poder_manivela": 0.0,
		"capacidade_bateria": 0.0,
		"ouro_bonus": 0.0,
		"reparo_bonus": 0.0,
		"ambiental_bonus": 0.0,
		"captura_bonus": 0.0,
		"carvao_poluicao": 0.0,
		"solar_noturno": 0.0,
		"solar_resist_calor": 0.0,
		"solar_desgaste": 0.0,
		"solar_bonus_fixo": 0.0,
		"solar_eclipse_resist": 0.0,
		"solar_ignora_poluicao": false,
		"eolica_tempestade_bonus": 0.0,
		"eolica_desgaste": 0.0,
		"eolica_rede_inteligente": 0.0,
		"eolica_ignora_seca": false,
		"eolica_minimo": 0.0,
		"desgaste_global": 0.0,
		"poluicao_max": 100.0,
		"ouro_inicial": 0,
		"migracao_bonus": 0.15,
		"demanda_cresce_menos": 0.0,
		"preco_solar": 0.0,
		"preco_eolica": 0.0,
		"preco_nuclear": 0.0,
		"preco_fusao": 0.0,
		"multiplicador_preco_reduz": false,
		"blackout_melhor": false,
		"respiro_dobro": false,
		"biomassa_limpeza_dobro": false,
		"fusao_limpeza_dobro": false,
		"capacidade_tecnico_extra": 0,
	}
	
	for id_hab in desbloqueadas.keys():
		var desbloqueada = desbloqueadas[id_hab]
		if not desbloqueada:
			continue
		
		var hab = _get_habilidade(id_hab)
		if hab.is_empty():
			continue
		
		for chave in hab.efeito.keys():
			var valor = hab.efeito[chave]
			if chave in bonus_cache:
				if typeof(bonus_cache[chave]) == TYPE_BOOL:
					bonus_cache[chave] = true
				elif typeof(bonus_cache[chave]) == TYPE_INT:
					bonus_cache[chave] += valor
				else:
					bonus_cache[chave] += valor

func get_bonus(chave: String):
	return bonus_cache.get(chave, 0)

# ============================================================================
# RESET
# ============================================================================
func resetar_tudo():
	pontos_disponiveis = 0
	for id in desbloqueadas.keys():
		desbloqueadas[id] = false
	_calcular_bonus_cache()
	pontos_mudou.emit(0)

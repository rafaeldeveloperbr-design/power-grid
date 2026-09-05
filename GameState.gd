# GameState.gd - V2 com 9 Cidades, Técnicos Múltiplos e Ordem por Valor
extends Node

signal recurso_mudou()
signal producao_mudou()
signal cidade_mudou()
signal poluicao_mudou()

# --- 9 CIDADES (Meta dobrando a cada nível) ---
const CIDADES = [
	{"nome": "Vilarejo", "cap": 40000.0, "desc": "Começo humilde", "desbloqueia": "hidreletrica"},
	{"nome": "Povoado", "cap": 80000.0, "desc": "Crescendo", "desbloqueia": "carvao"},
	{"nome": "Vila Rural", "cap": 160000.0, "desc": "Zona agrícola", "desbloqueia": "biomassa"},
	{"nome": "Cidade Pequena", "cap": 320000.0, "desc": "Primeiros prédios", "desbloqueia": "geotermica"},
	{"nome": "Cidade Média", "cap": 640000.0, "desc": "Centro regional", "desbloqueia": "nuclear"},
	{"nome": "Metrópole", "cap": 1280000.0, "desc": "Milhões de habitantes", "desbloqueia": "fusao"},
	{"nome": "Megalópole", "cap": 2560000.0, "desc": "Gigante urbana", "desbloqueia": "extra"},
	{"nome": "Nação Industrial", "cap": 5120000.0, "desc": "País inteiro", "desbloqueia": "extra"},
	{"nome": "Império Tecnológico", "cap": 10240000.0, "desc": "Fim do jogo", "desbloqueia": "fim"},
]

var cidade_atual: int = 0
var eficiencia_global: float = 1.0

const CAPACIDADE_BASE: float = 200.0
const CAPACIDADE_POR_BATERIA_BASE: float = 200.0
const DEMANDA_INICIAL: float = 5.0

# --- BALANCEAMENTO - mexe aqui pra testar ---
const CAPACIDADE_POR_TECNICO = 12
const REPARO_BASE_POR_TECNICO = 1.2 # % total por segundo
const DESGASTE_BASE = 0.35 # antes era 0.08, por isso não caia nunca
const LIMPEZA_BASE_AMBIENTAL = 0.45

const PRODUCAO_BASE = {
	"manivela": 2.0, "solar": 1.0, "eolica": 2.0, "geotermica": 6.0,
	"nuclear": 25.0, "hidreletrica": 15.0, "carvao": 12.0, "biomassa": 4.0,
	"fusao": 100.0 
}

const INCREMENTO_UPGRADE = {
	"manivela": 1.5, "solar": 1.0, "eolica": 1.5, "geotermica": 3.0,
	"nuclear": 10.0, "hidreletrica": 5.0, "carvao": 3.0, "biomassa": 1.5,
	"fusao": 35.0
}

# ORDEM POR VALOR/MW - mais barato primeiro
const PRECO_BASE = {
	"solar": 15.0,          # 1 MW - $15
	"eolica": 40.0,         # 2 MW - $40
	"bateria": 50.0,        # storage
	"carvao": 80.0,         # 12 MW - $80 mas polui
	"geotermica": 120.0,    # 6 MW
	"biomassa": 150.0,      # 4 MW limpa
	"hidreletrica": 300.0,  # 15 MW
	"nuclear": 450.0,       # 25 MW
	"fusao": 1500.0,        # 100 MW
	"up_manivela": 30.0,
	"up_solar": 60.0,
	"up_eolica": 100.0,
	"up_carvao": 120.0,
	"up_biomassa": 180.0,
	"up_geotermica": 250.0,
	"up_hidreletrica": 400.0,
	"up_nuclear": 800.0,
	"up_fusao": 3000.0,
	"filtro_carvao": 500.0,
	"captura_carbono": 2000.0,
	"tecnico_manutencao": 100.0,
	"tecnico_ambiental": 120.0,
}

const POLUICAO_POR_GERADOR = {
	"solar": 0.0, "eolica": 0.0, "geotermica": 0.05, "nuclear": 0.1,
	"hidreletrica": 0.0, "carvao": 0.5, "biomassa": -0.1, "fusao": -0.3
}

var ouro: float = 0.0:
	set(v):
		ouro = max(0.0, v)
		recurso_mudou.emit()

var energia_armazenada: float = 0.0:
	set(v):
		energia_armazenada = clamp(v, 0.0, calcular_capacidade_maxima())
		recurso_mudou.emit()

var demanda_cidade: float = DEMANDA_INICIAL
var oferta_atual: float = 0.0
var em_blackout: bool = false

var poluicao: float = 0.0
var saude: Dictionary = {}
var tecnicos_manutencao: int = 0
var tecnicos_ambientais: int = 0
var filtro_carvao_ativo: bool = false
var captura_carbono_ativa: bool = false

var paineis_solares: int = 0
var turbinas_eolicas: int = 0
var usinas_geotermicas: int = 0
var reatores_nucleares: int = 0
var reatores_fusao: int = 0
var hidreletricas: int = 0
var usinas_carvao: int = 0
var usinas_biomassa: int = 0
var baterias: int = 0

var nivel_manivela: int = 1
var nivel_solar_upgrade: int = 1
var nivel_eolica_upgrade: int = 1
var nivel_geotermica_upgrade: int = 1
var nivel_nuclear_upgrade: int = 1
var nivel_fusao_upgrade: int = 1
var nivel_hidreletrica_upgrade: int = 1
var nivel_carvao_upgrade: int = 1
var nivel_biomassa_upgrade: int = 1

var poder_manivela: float = PRODUCAO_BASE.manivela
var producao_solar: float = PRODUCAO_BASE.solar
var producao_eolica: float = PRODUCAO_BASE.eolica
var producao_geotermica: float = PRODUCAO_BASE.geotermica
var producao_nuclear: float = PRODUCAO_BASE.nuclear
var producao_fusao: float = PRODUCAO_BASE.fusao
var producao_hidreletrica: float = PRODUCAO_BASE.hidreletrica
var producao_carvao: float = PRODUCAO_BASE.carvao
var producao_biomassa: float = PRODUCAO_BASE.biomassa
var capacidade_por_bateria: float = CAPACIDADE_POR_BATERIA_BASE

var precos: Dictionary = {}
var bonus_conquistas: Dictionary = {}

func _ready() -> void:
	resetar_jogo_completo()

func resetar_jogo_completo():
	ouro = 0.0
	energia_armazenada = 0.0
	demanda_cidade = DEMANDA_INICIAL
	oferta_atual = 0.0
	poluicao = 0.0
	cidade_atual = 0
	eficiencia_global = 1.0
	paineis_solares = 0
	turbinas_eolicas = 0
	usinas_geotermicas = 0
	reatores_nucleares = 0
	reatores_fusao = 0
	hidreletricas = 0
	usinas_carvao = 0
	usinas_biomassa = 0
	baterias = 0
	nivel_manivela = 1
	nivel_solar_upgrade = 1
	nivel_eolica_upgrade = 1
	nivel_geotermica_upgrade = 1
	nivel_nuclear_upgrade = 1
	nivel_fusao_upgrade = 1
	nivel_hidreletrica_upgrade = 1
	nivel_carvao_upgrade = 1
	nivel_biomassa_upgrade = 1
	precos = PRECO_BASE.duplicate()
	bonus_conquistas.clear()
	saude = {
		"solar": 100.0, "eolica": 100.0, "geotermica": 100.0,
		"nuclear": 100.0, "fusao": 100.0, "hidreletrica": 100.0, "carvao": 100.0, "biomassa": 100.0, 
	}
	tecnicos_manutencao = 0
	tecnicos_ambientais = 0
	filtro_carvao_ativo = false
	captura_carbono_ativa = false
	recalcular_tudo()

func get_cidade_atual_info() -> Dictionary:
	if cidade_atual < CIDADES.size():
		return CIDADES[cidade_atual]
	return CIDADES[-1]

func get_cap_atual() -> float:
	return get_cidade_atual_info().cap

func pode_migrar_cidade() -> bool:
	return demanda_cidade >= get_cap_atual() and cidade_atual < CIDADES.size() - 1

func migrar_cidade() -> bool:
	if not pode_migrar_cidade():
		return false
	
	cidade_atual += 1
	eficiencia_global *= 1.15 # só isso que fica
	
	# --- ZERA TUDO ---
	ouro = 0.0
	energia_armazenada = 0.0
	demanda_cidade = DEMANDA_INICIAL
	oferta_atual = 0.0
	poluicao = 0.0
	em_blackout = false
	
	paineis_solares = 0
	turbinas_eolicas = 0
	usinas_geotermicas = 0
	reatores_nucleares = 0
	reatores_fusao = 0
	hidreletricas = 0
	usinas_carvao = 0
	usinas_biomassa = 0
	baterias = 0
	
	nivel_manivela = 1
	nivel_solar_upgrade = 1
	nivel_eolica_upgrade = 1
	nivel_geotermica_upgrade = 1
	nivel_nuclear_upgrade = 1
	nivel_fusao_upgrade = 1
	nivel_hidreletrica_upgrade = 1
	nivel_carvao_upgrade = 1
	nivel_biomassa_upgrade = 1
	
	tecnicos_manutencao = 0
	tecnicos_ambientais = 0
	filtro_carvao_ativo = false
	captura_carbono_ativa = false
	
	saude = {
		"solar": 100.0, "eolica": 100.0, "geotermica": 100.0,
		"nuclear": 100.0, "fusao": 100.0, "hidreletrica": 100.0, "carvao": 100.0, "biomassa": 100.0, 
	}
	
	precos = PRECO_BASE.duplicate()
	bonus_conquistas.clear()
	
	recalcular_tudo()
	cidade_mudou.emit()
	return true

func calcular_capacidade_maxima() -> float:
	return CAPACIDADE_BASE + (baterias * capacidade_por_bateria)

func get_multiplicador(tipo_bonus: String) -> float:
	return pow(2.0, float(bonus_conquistas.get(tipo_bonus, 0)))

func aplicar_bonus_conquista(bonus_key: String):
	bonus_conquistas[bonus_key] = bonus_conquistas.get(bonus_key, 0) + 1
	recalcular_tudo()

func recalcular_tudo():
	var mult_solar = get_multiplicador("producao_solar")
	var mult_eolica = get_multiplicador("producao_eolica")
	var mult_geo = get_multiplicador("producao_geotermica")
	var mult_nuc = get_multiplicador("producao_nuclear")
	var mult_fusao = get_multiplicador("producao_fusao")
	var mult_hidro = get_multiplicador("producao_hidreletrica")
	var mult_carvao = get_multiplicador("producao_carvao")
	var mult_bio = get_multiplicador("producao_biomassa")
	var mult_bat = get_multiplicador("capacidade_bateria")
	var mult_mani = get_multiplicador("poder_manivela")

	producao_solar = (PRODUCAO_BASE.solar + (nivel_solar_upgrade - 1) * INCREMENTO_UPGRADE.solar) * mult_solar * eficiencia_global
	producao_eolica = (PRODUCAO_BASE.eolica + (nivel_eolica_upgrade - 1) * INCREMENTO_UPGRADE.eolica) * mult_eolica * eficiencia_global
	producao_geotermica = (PRODUCAO_BASE.geotermica + (nivel_geotermica_upgrade - 1) * INCREMENTO_UPGRADE.geotermica) * mult_geo * eficiencia_global
	producao_nuclear = (PRODUCAO_BASE.nuclear + (nivel_nuclear_upgrade - 1) * INCREMENTO_UPGRADE.nuclear) * mult_nuc * eficiencia_global
	producao_fusao = (PRODUCAO_BASE.fusao + (nivel_fusao_upgrade - 1) * INCREMENTO_UPGRADE.fusao) * mult_fusao * eficiencia_global
	producao_hidreletrica = (PRODUCAO_BASE.hidreletrica + (nivel_hidreletrica_upgrade - 1) * INCREMENTO_UPGRADE.hidreletrica) * mult_hidro * eficiencia_global
	producao_carvao = (PRODUCAO_BASE.carvao + (nivel_carvao_upgrade - 1) * INCREMENTO_UPGRADE.carvao) * mult_carvao * eficiencia_global
	producao_biomassa = (PRODUCAO_BASE.biomassa + (nivel_biomassa_upgrade - 1) * INCREMENTO_UPGRADE.biomassa) * mult_bio * eficiencia_global
	capacidade_por_bateria = CAPACIDADE_POR_BATERIA_BASE * mult_bat
	poder_manivela = (PRODUCAO_BASE.manivela + (nivel_manivela - 1) * INCREMENTO_UPGRADE.manivela) * mult_mani * eficiencia_global
	producao_mudou.emit()

func get_preco(chave: String) -> float:
	return precos.get(chave, 999999.0)

func pode_comprar(chave: String) -> bool:
	if ouro < get_preco(chave):
		return false
	match chave:
		"eolica": return paineis_solares >= 5
		"carvao": return turbinas_eolicas >= 5
		"geotermica": return usinas_carvao >= 2
		"biomassa": return usinas_geotermicas >= 5
		"hidreletrica": return usinas_biomassa >= 5
		"nuclear": return hidreletricas >= 5
		"fusao": return reatores_nucleares >= 5
		"filtro_carvao": return usinas_carvao > 0 and not filtro_carvao_ativo
		"captura_carbono": return not captura_carbono_ativa and poluicao > 10
		"tecnico_manutencao": return get_total_geradores() >= 5
		"tecnico_ambiental": return poluicao > 5 or usinas_carvao >= 1
		_: return true

func get_total_geradores() -> int:
	return paineis_solares + turbinas_eolicas + usinas_geotermicas + reatores_nucleares + reatores_fusao + hidreletricas + usinas_carvao + usinas_biomassa

func comprar(chave: String) -> bool:
	if not pode_comprar(chave):
		return false
	
	ouro -= precos[chave]
	
	match chave:
		"solar":
			paineis_solares += 1
			precos[chave] *= 1.15
		"eolica":
			turbinas_eolicas += 1
			precos[chave] *= 1.15
		"bateria":
			baterias += 1
			precos[chave] *= 1.15
		"carvao":
			usinas_carvao += 1
			precos[chave] *= 1.12
		"geotermica":
			usinas_geotermicas += 1
			precos[chave] *= 1.15
		"biomassa":
			usinas_biomassa += 1
			precos[chave] *= 1.15
		"hidreletrica":
			hidreletricas += 1
			precos[chave] *= 1.15
		"nuclear":
			reatores_nucleares += 1
			precos[chave] *= 1.15
		"fusao":
			reatores_fusao += 1
			precos[chave] *= 1.2
		"up_manivela":
			nivel_manivela += 1
			precos[chave] *= 1.8
		"up_solar":
			nivel_solar_upgrade += 1
			precos[chave] *= 2.0
		"up_eolica":
			nivel_eolica_upgrade += 1
			precos[chave] *= 2.0
		"up_carvao":
			nivel_carvao_upgrade += 1
			precos[chave] *= 2.2
		"up_biomassa":
			nivel_biomassa_upgrade += 1
			precos[chave] *= 2.0
		"up_geotermica":
			nivel_geotermica_upgrade += 1
			precos[chave] *= 2.2
		"up_hidreletrica":
			nivel_hidreletrica_upgrade += 1
			precos[chave] *= 2.5
		"up_nuclear":
			nivel_nuclear_upgrade += 1
			precos[chave] *= 2.5
		"up_fusao":
			nivel_fusao_upgrade += 1
			precos[chave] *= 2.6
		"filtro_carvao":
			filtro_carvao_ativo = true
		"captura_carbono":
			captura_carbono_ativa = true
		"tecnico_manutencao":
			tecnicos_manutencao += 1
			precos[chave] *= 1.20
		"tecnico_ambiental":
			tecnicos_ambientais += 1
			precos[chave] *= 1.20
	
	recalcular_tudo()
	recurso_mudou.emit()
	return true


func get_quantidade(tipo: String) -> int:
	match tipo:
		"solar": return paineis_solares
		"eolica": return turbinas_eolicas
		"geotermica": return usinas_geotermicas
		"nuclear": return reatores_nucleares
		"fusao": return reatores_fusao
		"hidreletrica": return hidreletricas
		"carvao": return usinas_carvao
		"biomassa": return usinas_biomassa
		"bateria": return baterias
		"up_manivela": return nivel_manivela
		"up_solar": return nivel_solar_upgrade
		"up_eolica": return nivel_eolica_upgrade
		"up_geotermica": return nivel_geotermica_upgrade
		"up_nuclear": return nivel_nuclear_upgrade
		"up_hidreletrica": return nivel_hidreletrica_upgrade
		"up_carvao": return nivel_carvao_upgrade
		"up_biomassa": return nivel_biomassa_upgrade
		_: return 0

func calcular_oferta_bruta(eh_dia: bool, mult_eolica: float, mult_solar: float, mult_hidro: float) -> float:
	var h_solar = saude.get("solar", 100.0) / 100.0
	var h_eolica = saude.get("eolica", 100.0) / 100.0
	var h_geo = saude.get("geotermica", 100.0) / 100.0
	var h_nuc = saude.get("nuclear", 100.0) / 100.0
	var h_fusao = saude.get("fusao", 100.0) / 100.0
	var h_hidro = saude.get("hidreletrica", 100.0) / 100.0
	var h_carvao = saude.get("carvao", 100.0) / 100.0
	var h_bio = saude.get("biomassa", 100.0) / 100.0
	
	var penalidade_poluicao = 1.0 - (poluicao / 100.0 * 0.5)
	
	var prod_solar = (paineis_solares * producao_solar * mult_solar * penalidade_poluicao * h_solar) if eh_dia else 0.0
	var prod_eolica = turbinas_eolicas * producao_eolica * mult_eolica * h_eolica
	var prod_geo = usinas_geotermicas * producao_geotermica * h_geo
	var prod_nuc = reatores_nucleares * producao_nuclear * h_nuc
	var prod_fusao = reatores_fusao * producao_fusao * h_fusao
	var prod_hidro = hidreletricas * producao_hidreletrica * mult_hidro * h_hidro
	var prod_carvao = usinas_carvao * producao_carvao * h_carvao
	var prod_bio = usinas_biomassa * producao_biomassa * h_bio
	
	return prod_solar + prod_eolica + prod_geo + prod_nuc + prod_fusao + prod_hidro + prod_carvao + prod_bio


func atualizar_poluicao(delta: float):
	var producao = 0.0
	for tipo in POLUICAO_POR_GERADOR.keys():
		var qtd = get_quantidade(tipo)
		if qtd <= 0: continue
		var pol = POLUICAO_POR_GERADOR[tipo] * qtd
		if tipo == "carvao" and filtro_carvao_ativo: pol *= 0.5
		producao += pol
	
	if captura_carbono_ativa: producao -= 2.5
	producao -= 0.08 # respiro natural
	
	# Ambientais também com capacidade
	if tecnicos_ambientais > 0:
		var cap_amb = tecnicos_ambientais * 15
		var total_poluidores = usinas_carvao + reatores_nucleares + usinas_geotermicas
		var efic_amb = 1.0
		if total_poluidores > cap_amb:
			efic_amb = float(cap_amb) / float(max(total_poluidores, 1))
		var bonus = 1.0 + min((tecnicos_ambientais - 1) * 0.08, 0.4)
		var limpeza = tecnicos_ambientais * LIMPEZA_BASE_AMBIENTAL * bonus * efic_amb
		producao -= limpeza
	
	poluicao = clamp(poluicao + producao * delta, 0.0, 100.0)
	poluicao_mudou.emit()

func desgastar(delta: float, clima_atual: int):
	var fator_clima = 1.0
	if clima_atual == 1: fator_clima = 2.2 # tempestade pesa mais agora
	if clima_atual == 3: fator_clima = 1.6

	var total_geradores = get_total_geradores()
	var tipos_ativos = []
	for tipo in saude.keys():
		if get_quantidade(tipo) > 0:
			tipos_ativos.append(tipo)

	# Eficiência por sobrecarga
	var capacidade_total = tecnicos_manutencao * CAPACIDADE_POR_TECNICO
	var eficiencia_sobrecarga = 1.0
	if total_geradores > 0 and capacidade_total > 0:
		eficiencia_sobrecarga = min(1.0, float(capacidade_total) / float(total_geradores))
		if total_geradores > capacidade_total * 2: # muito sobrecarregado = penalidade extra
			eficiencia_sobrecarga *= 0.6

	for tipo in tipos_ativos:
		var fator_tipo = 1.0
		match tipo:
			"carvao": fator_tipo = 2.0
			"eolica": fator_tipo = 1.5
			"nuclear": fator_tipo = 1.6
			"fusao": fator_tipo = 2.2
		
		var qtd = get_quantidade(tipo)
		var fator_qtd = 1.0 + (qtd / 15.0) * 0.25 # quanto mais usina daquele tipo, mais desgasta
		
		var taxa = DESGASTE_BASE * fator_clima * fator_tipo * fator_qtd * delta
		saude[tipo] = max(0.0, saude[tipo] - taxa)

	# REPARO - só funciona bem se não estiver sobrecarregado
	if tecnicos_manutencao > 0 and tipos_ativos.size() > 0:
		var bonus = 1.0 + min((tecnicos_manutencao - 1) * 0.08, 0.4) # cap 40%
		var poder_total = tecnicos_manutencao * REPARO_BASE_POR_TECNICO * bonus * eficiencia_sobrecarga * delta
		
		var danificados = []
		for t in tipos_ativos:
			if saude[t] < 99.9:
				danificados.append(t)
		
		if danificados.size() > 0:
			var total_danificado_qtd = 0
			for t in danificados:
				total_danificado_qtd += get_quantidade(t)
			
			for t in danificados:
				var peso = float(get_quantidade(t)) / float(total_danificado_qtd)
				# reparo proporcional à quantidade daquele tipo
				var reparo = poder_total * peso * 2.5
				saude[t] = min(100.0, saude[t] + reparo)

func reparar(tipo: String) -> bool:
	var qtd = get_quantidade(tipo)
	if qtd <= 0: return false
	
	var saude_atual = saude.get(tipo, 100.0)
	if saude_atual >= 99.9: return false
	
	var dano = 100.0 - saude_atual
	var custo_base_por_unidade = 5.0
	match tipo:
		"solar": custo_base_por_unidade = 5
		"eolica": custo_base_por_unidade = 8
		"biomassa": custo_base_por_unidade = 10
		"carvao": custo_base_por_unidade = 15
		"geotermica": custo_base_por_unidade = 20
		"hidreletrica": custo_base_por_unidade = 40
		"nuclear": custo_base_por_unidade = 100
		"fusao": custo_base_por_unidade = 200
	
	# custo proporcional ao dano
	var custo = qtd * custo_base_por_unidade * (dano / 100.0)
	custo = max(custo, custo_base_por_unidade * 0.2) # mínimo 20% pra não ficar de graça
	
	if ouro < custo: return false
	
	ouro -= custo
	saude[tipo] = 100.0
	recurso_mudou.emit()
	return true

# Dicionários de Descrições para UI Mobile
const DESCRICOES_GERADORES = {
	"solar": "Painel fotovoltaico. Para de gerar à noite.",
	"eolica": "Turbina de vento. Gera mais durante tempestades.",
	"biomassa": "Queima resíduos orgânicos. Limpa a poluição.",
	"carvao": "Geração barata e rápida. Polui bastante.",
	"geotermica": "Calor do solo. Produção contínua e estável.",
	"hidreletrica": "Energia limpa em massa. Alto custo inicial.",
	"nuclear": "Produção extrema para grandes metrópoles.",
	"fusao": "Tecnologia de ponta. Gera energia massiva e limpa o ar."
}

const DESCRICOES_UPGRADES = {
	"up_manivela": "+100% de energia por clique manual.",
	"up_solar": "Painéis avançados: +50% de produção solar.",
	"up_eolica": "Pás leves: +50% de produção eólica.",
	"up_biomassa": "Compostagem rápida: +50% de eficiência.",
	"up_carvao": "Caldeira pressurizada: +50% de geração.",
	"up_geotermica": "Brocas profundas: +50% de eficiência.",
	"up_hidreletrica": "Turbinas magnéticas: +50% de geração.",
	"up_nuclear": "Urânio enriquecido: +50% de eficiência.",
	"up_fusao": "Confinamento Magnético: +50% na eficiência de fusão.",
	"filtro_carvao": "Reduz 50% da poluição das usinas de carvão.",
	"captura_carbono": "Suga parte da poluição do ar ativamente.",
	"tecnico_manutencao": "Repara a saúde das usinas automaticamente.",
	"tecnico_ambiental": "Aumenta a limpeza diária do planeta."
}

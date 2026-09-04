# GameState.gd - V2 com 9 Cidades, Técnicos Múltiplos e Ordem por Valor
extends Node

signal recurso_mudou()
signal producao_mudou()
signal cidade_mudou()
signal poluicao_mudou()

# --- 9 CIDADES - Nome que você pediu ---
const CIDADES = [
	{"nome": "Vilarejo", "cap": 20000.0, "desc": "Começo humilde", "desbloqueia": "hidreletrica"},
	{"nome": "Povoado", "cap": 50000.0, "desc": "Crescendo", "desbloqueia": "carvao"},
	{"nome": "Vila Rural", "cap": 100000.0, "desc": "Zona agrícola", "desbloqueia": "biomassa"},
	{"nome": "Cidade Pequena", "cap": 200000.0, "desc": "Primeiros prédios", "desbloqueia": "geotermica"},
	{"nome": "Cidade Média", "cap": 400000.0, "desc": "Centro regional", "desbloqueia": "nuclear"},
	{"nome": "Metrópole", "cap": 800000.0, "desc": "Milhões de habitantes", "desbloqueia": "extra"},
	{"nome": "Megalópole", "cap": 1500000.0, "desc": "Gigante urbana", "desbloqueia": "extra"},
	{"nome": "Nação Industrial", "cap": 3000000.0, "desc": "País inteiro", "desbloqueia": "extra"},
	{"nome": "Império Tecnológico", "cap": 6000000.0, "desc": "Fim do jogo", "desbloqueia": "fim"},
]

var cidade_atual: int = 0
var eficiencia_global: float = 1.0

const CAPACIDADE_BASE: float = 200.0
const CAPACIDADE_POR_BATERIA_BASE: float = 200.0
const DEMANDA_INICIAL: float = 5.0

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
	"fusao": 1500.0,		# 100 MW
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
	eficiencia_global *= 1.15
	demanda_cidade = DEMANDA_INICIAL
	energia_armazenada = 0.0
	poluicao *= 0.5
	cidade_mudou.emit()
	recalcular_tudo()
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
		"eolica": return paineis_solares >= 3
		"carvao": return paineis_solares >= 5
		"geotermica": return turbinas_eolicas >= 3 or usinas_carvao >= 2
		"biomassa": return usinas_carvao >= 2 or paineis_solares >= 15
		"hidreletrica": return usinas_geotermicas >= 2 or cidade_atual >= 1
		"nuclear": return usinas_geotermicas >= 3 or hidreletricas >= 3
		"fusao": return reatores_nucleares >= 3 
		"filtro_carvao": return usinas_carvao > 0 and not filtro_carvao_ativo
		"captura_carbono": return not captura_carbono_ativa and poluicao > 10
		"tecnico_manutencao": return get_total_geradores() >= 5
		"tecnico_ambiental": return poluicao > 5 or usinas_carvao >= 1
		_: return true

func get_total_geradores() -> int:
	return paineis_solares + turbinas_eolicas + usinas_geotermicas + reatores_nucleares + hidreletricas + usinas_carvao + usinas_biomassa

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
			precos[chave] *= 1.18
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
			precos[chave] *= 2.5
		"filtro_carvao":
			filtro_carvao_ativo = true
		"captura_carbono":
			captura_carbono_ativa = true
		"tecnico_manutencao":
			tecnicos_manutencao += 1
			precos[chave] *= 1.6
		"tecnico_ambiental":
			tecnicos_ambientais += 1
			precos[chave] *= 1.7
	
	recalcular_tudo()
	recurso_mudou.emit()
	return true

func reparar(tipo: String) -> bool:
	var custo = 0.0
	match tipo:
		"solar": custo = paineis_solares * 5
		"eolica": custo = turbinas_eolicas * 8
		"geotermica": custo = usinas_geotermicas * 20
		"nuclear": custo = reatores_nucleares * 100
		"hidreletrica": custo = hidreletricas * 40
		"carvao": custo = usinas_carvao * 15
		"biomassa": custo = usinas_biomassa * 10
		_: return false
	
	if ouro < custo: return false
	ouro -= custo
	saude[tipo] = 100.0
	recurso_mudou.emit()
	return true

func get_quantidade(tipo: String) -> int:
	match tipo:
		"solar": return paineis_solares
		"eolica": return turbinas_eolicas
		"geotermica": return usinas_geotermicas
		"nuclear": return reatores_nucleares
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
	var prod_poluicao = 0.0
	prod_poluicao += reatores_fusao + usinas_carvao * POLUICAO_POR_GERADOR.carvao
	if filtro_carvao_ativo:
		prod_poluicao *= 0.5
	prod_poluicao += reatores_nucleares * POLUICAO_POR_GERADOR.nuclear
	prod_poluicao += usinas_geotermicas * POLUICAO_POR_GERADOR.geotermica
	prod_poluicao += usinas_biomassa * POLUICAO_POR_GERADOR.biomassa
	if captura_carbono_ativa:
		prod_poluicao -= 1.0
	prod_poluicao -= tecnicos_ambientais * 0.6
	
	poluicao = clamp(poluicao + prod_poluicao * delta, 0.0, 100.0)
	poluicao_mudou.emit()

func desgastar(delta: float, clima_atual: int):
	var fator_clima = 1.0
	if clima_atual == 1: fator_clima = 2.5
	if clima_atual == 3: fator_clima = 1.5
	
	for tipo in saude.keys():
		var qtd = get_quantidade(tipo)
		if qtd > 0:
			var fator_tipo = 1.0
			if tipo == "carvao": fator_tipo = 2.0
			if tipo == "eolica": fator_tipo = 1.3
			saude[tipo] = max(0.0, saude[tipo] - 0.05 * fator_clima * fator_tipo * delta)
	
	if tecnicos_manutencao > 0:
		for tipo in saude.keys():
			if get_quantidade(tipo) > 0:
				saude[tipo] = min(100.0, saude[tipo] + 0.3 * tecnicos_manutencao * delta)

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

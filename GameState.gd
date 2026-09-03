# GameState.gd - Autoload Singleton (Project > Autoload > GameState)
extends Node

signal recurso_mudou()
signal producao_mudou()
signal blackout_mudou(em_blackout: bool)

# --- CONSTANTES DE BALANCEAMENTO ---
const CAPACIDADE_BASE: float = 200.0
const CAPACIDADE_POR_BATERIA_BASE: float = 200.0
const DEMANDA_INICIAL: float = 5.0
const DEMANDA_MAX: float = 20000.0

const PRODUCAO_BASE = {
		"manivela": 2.0,
		"solar": 1.0,
		"eolica": 2.0,
		"geotermica": 6.0,
		"nuclear": 25.0,
}

const INCREMENTO_UPGRADE = {
		"manivela": 1.5,
		"solar": 1.0,
		"eolica": 1.5,
		"geotermica": 3.0,
		"nuclear": 10.0,
}

const PRECO_BASE = {
		"solar": 15.0,
		"eolica": 40.0,
		"geotermica": 120.0,
		"nuclear": 450.0,
		"bateria": 50.0,
		"up_manivela": 30.0,
		"up_solar": 60.0,
		"up_eolica": 100.0,
		"up_geotermica": 250.0,
		"up_nuclear": 800.0,
}

const FATOR_PRECO_GERADOR: float = 1.15
const FATOR_PRECO_UP_MANIVELA: float = 1.8
const FATOR_PRECO_UP_COMUM: float = 2.0
const FATOR_PRECO_UP_GEO: float = 2.2
const FATOR_PRECO_UP_NUC: float = 2.5

# --- ESTADO REATIVO ---
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
var em_blackout: bool = false:
		set(v):
				if em_blackout != v:
						em_blackout = v
						blackout_mudou.emit(v)

# Geradores
var paineis_solares: int = 0
var turbinas_eolicas: int = 0
var usinas_geotermicas: int = 0
var reatores_nucleares: int = 0
var baterias: int = 0

# Upgrades
var nivel_manivela: int = 1
var nivel_solar_upgrade: int = 1
var nivel_eolica_upgrade: int = 1
var nivel_geotermica_upgrade: int = 1
var nivel_nuclear_upgrade: int = 1

# Valores calculados (nunca editar direto, sempre via recalcular_tudo())
var poder_manivela: float = PRODUCAO_BASE.manivela
var producao_solar: float = PRODUCAO_BASE.solar
var producao_eolica: float = PRODUCAO_BASE.eolica
var producao_geotermica: float = PRODUCAO_BASE.geotermica
var producao_nuclear: float = PRODUCAO_BASE.nuclear
var capacidade_por_bateria: float = CAPACIDADE_POR_BATERIA_BASE

var precos: Dictionary = {}
var bonus_conquistas: Dictionary = {}

func _ready() -> void:
		resetar_jogo()

func resetar_jogo():
		ouro = 0.0
		energia_armazenada = 0.0
		demanda_cidade = DEMANDA_INICIAL
		oferta_atual = 0.0
		em_blackout = false
		paineis_solares = 0
		turbinas_eolicas = 0
		usinas_geotermicas = 0
		reatores_nucleares = 0
		baterias = 0
		nivel_manivela = 1
		nivel_solar_upgrade = 1
		nivel_eolica_upgrade = 1
		nivel_geotermica_upgrade = 1
		nivel_nuclear_upgrade = 1
		precos = PRECO_BASE.duplicate()
		bonus_conquistas.clear()
		recalcular_tudo()

# --- CAPACIDADE ---
func calcular_capacidade_maxima() -> float:
		return CAPACIDADE_BASE + (baterias * capacidade_por_bateria)

# --- BÔNUS DE CONQUISTAS (seguro para save/load) ---
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
		var mult_bat = get_multiplicador("capacidade_bateria")
		var mult_mani = get_multiplicador("poder_manivela")

		producao_solar = (PRODUCAO_BASE.solar + (nivel_solar_upgrade - 1) * INCREMENTO_UPGRADE.solar) * mult_solar
		producao_eolica = (PRODUCAO_BASE.eolica + (nivel_eolica_upgrade - 1) * INCREMENTO_UPGRADE.eolica) * mult_eolica
		producao_geotermica = (PRODUCAO_BASE.geotermica + (nivel_geotermica_upgrade - 1) * INCREMENTO_UPGRADE.geotermica) * mult_geo
		producao_nuclear = (PRODUCAO_BASE.nuclear + (nivel_nuclear_upgrade - 1) * INCREMENTO_UPGRADE.nuclear) * mult_nuc
		capacidade_por_bateria = CAPACIDADE_POR_BATERIA_BASE * mult_bat
		poder_manivela = (PRODUCAO_BASE.manivela + (nivel_manivela - 1) * INCREMENTO_UPGRADE.manivela) * mult_mani
		producao_mudou.emit()

# --- LOJA / ECONOMIA ---
func get_preco(chave: String) -> float:
		return precos.get(chave, 999999.0)

func pode_comprar(chave: String) -> bool:
		if ouro < get_preco(chave):
				return false
		# Pré-requisitos de progressão
		match chave:
				"eolica":
						return paineis_solares >= 5
				"geotermica":
						return turbinas_eolicas >= 5
				"nuclear":
						return usinas_geotermicas >= 5
				_:
						return true

func comprar(chave: String) -> bool:
		if not pode_comprar(chave):
				return false
		
		ouro -= precos[chave]
		
		match chave:
				"solar":
						paineis_solares += 1
						precos[chave] *= FATOR_PRECO_GERADOR
				"eolica":
						turbinas_eolicas += 1
						precos[chave] *= FATOR_PRECO_GERADOR
				"geotermica":
						usinas_geotermicas += 1
						precos[chave] *= FATOR_PRECO_GERADOR
				"nuclear":
						reatores_nucleares += 1
						precos[chave] *= FATOR_PRECO_GERADOR
				"bateria":
						baterias += 1
						precos[chave] *= FATOR_PRECO_GERADOR
				"up_manivela":
						nivel_manivela += 1
						precos[chave] *= FATOR_PRECO_UP_MANIVELA
				"up_solar":
						nivel_solar_upgrade += 1
						precos[chave] *= FATOR_PRECO_UP_COMUM
				"up_eolica":
						nivel_eolica_upgrade += 1
						precos[chave] *= FATOR_PRECO_UP_COMUM
				"up_geotermica":
						nivel_geotermica_upgrade += 1
						precos[chave] *= FATOR_PRECO_UP_GEO
				"up_nuclear":
						nivel_nuclear_upgrade += 1
						precos[chave] *= FATOR_PRECO_UP_NUC
		
		recalcular_tudo()
		recurso_mudou.emit()
		return true

func get_quantidade(tipo: String) -> int:
		match tipo:
				"solar": return paineis_solares
				"eolica": return turbinas_eolicas
				"geotermica": return usinas_geotermicas
				"nuclear": return reatores_nucleares
				"bateria": return baterias
				"up_manivela": return nivel_manivela
				"up_solar": return nivel_solar_upgrade
				"up_eolica": return nivel_eolica_upgrade
				"up_geotermica": return nivel_geotermica_upgrade
				"up_nuclear": return nivel_nuclear_upgrade
				_: return 0

func calcular_oferta_bruta(eh_dia: bool, mult_eolica: float, mult_solar: float) -> float:
		var prod_solar = (paineis_solares * producao_solar * mult_solar) if eh_dia else 0.0
		var prod_eolica = turbinas_eolicas * producao_eolica * mult_eolica
		var prod_geo = usinas_geotermicas * producao_geotermica
		var prod_nuc = reatores_nucleares * producao_nuclear
		return prod_solar + prod_eolica + prod_geo + prod_nuc

# GameState.gd
extends Node

# --- RECURSOS & BATERIA ---
var ouro: float = 0.0
var energia_armazenada: float = 0.0
var capacidade_base: float = 200.0
var capacidade_bateria: float = 200.0
var baterias: int = 0

# --- OFERTA E DEMANDA ---
var demanda_cidade: float = 5.0
var oferta_atual: float = 0.0
var em_blackout: bool = false

# --- GERADORES ---
var paineis_solares: int = 0
var preco_painel_solar: float = 15.0

var turbinas_eolicas: int = 0
var preco_turbina_eolica: float = 40.0

var usinas_geotermicas: int = 0
var preco_geotermica: float = 120.0

var reatores_nucleares: int = 0
var preco_nuclear: float = 450.0

var preco_bateria: float = 50.0

# --- PODERES E UPGRADES ---
var poder_manivela: float = 2.0
var producao_solar: float = 1.0
var producao_eolica: float = 2.0
var producao_geotermica: float = 6.0
var producao_nuclear: float = 25.0

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

# --- FUNÇÕES ÚTEIS ---
func calcular_capacidade_maxima() -> float:
	return capacidade_base + (baterias * capacidade_bateria)

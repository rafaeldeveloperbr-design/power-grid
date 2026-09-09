# SaveSystem.gd - Sistema de Save/Load usando JSON
extends Node

# Caminho do arquivo de save (user:// é a pasta de dados do usuário)
const SAVE_PATH := "user://save_game.json"

# Versão do save (útil para migrações futuras)
const SAVE_VERSION := 1


# ============================================================================
# FUNÇÃO PRINCIPAL: SALVAR JOGO
# ============================================================================
func salvar_jogo() -> bool:
	print("💾 Salvando jogo...")
	
	var dados_save := {
		"versao": SAVE_VERSION,
		"data_salvamento": Time.get_datetime_string_from_system(),
		
		# --- GAMESTATE ---
		"cidade_atual": GameState.cidade_atual,
		"eficiencia_global": GameState.eficiencia_global,
		"ouro": GameState.ouro,
		"energia_armazenada": GameState.energia_armazenada,
		"demanda_cidade": GameState.demanda_cidade,
		"poluicao": GameState.poluicao,
		"saude": GameState.saude.duplicate(),
		"tecnicos_manutencao": GameState.tecnicos_manutencao,
		"tecnicos_ambientais": GameState.tecnicos_ambientais,
		"filtro_carvao_ativo": GameState.filtro_carvao_ativo,
		"captura_carbono_ativa": GameState.captura_carbono_ativa,
		
		# Quantidades de geradores
		"paineis_solares": GameState.paineis_solares,
		"turbinas_eolicas": GameState.turbinas_eolicas,
		"usinas_geotermicas": GameState.usinas_geotermicas,
		"reatores_nucleares": GameState.reatores_nucleares,
		"reatores_fusao": GameState.reatores_fusao,
		"hidreletricas": GameState.hidreletricas,
		"usinas_carvao": GameState.usinas_carvao,
		"usinas_biomassa": GameState.usinas_biomassa,
		"baterias": GameState.baterias,
		
		# Níveis de upgrade
		"nivel_manivela": GameState.nivel_manivela,
		"nivel_solar_upgrade": GameState.nivel_solar_upgrade,
		"nivel_eolica_upgrade": GameState.nivel_eolica_upgrade,
		"nivel_geotermica_upgrade": GameState.nivel_geotermica_upgrade,
		"nivel_nuclear_upgrade": GameState.nivel_nuclear_upgrade,
		"nivel_fusao_upgrade": GameState.nivel_fusao_upgrade,
		"nivel_hidreletrica_upgrade": GameState.nivel_hidreletrica_upgrade,
		"nivel_carvao_upgrade": GameState.nivel_carvao_upgrade,
		"nivel_biomassa_upgrade": GameState.nivel_biomassa_upgrade,
		
		# Dicionários
		"precos": GameState.precos.duplicate(),
		"bonus_conquistas": GameState.bonus_conquistas.duplicate(),
		
		"skill_pontos": SkillTreeManager.pontos_disponiveis,
		"skill_desbloqueadas": SkillTreeManager.desbloqueadas.duplicate(),
		
		# --- ACHIEVEMENT MANAGER ---
		"conquistas_desbloqueadas": AchievementManager.desbloqueadas.duplicate(),
	}
	
	# Converte o dicionário para JSON e salva no arquivo
	var arquivo := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if arquivo == null:
		push_error("Erro ao abrir arquivo para salvar: %s" % FileAccess.get_open_error())
		return false
	
	var json_string := JSON.stringify(dados_save, "\t")  # \t para indentação legível
	arquivo.store_string(json_string)
	arquivo.close()
	
	print("✅ Jogo salvo com sucesso!")
	return true


# ============================================================================
# FUNÇÃO PRINCIPAL: CARREGAR JOGO
# ============================================================================
func carregar_jogo() -> bool:
	# Verifica se o arquivo existe
	if not FileAccess.file_exists(SAVE_PATH):
		print("⚠️ Nenhum save encontrado.")
		return false
	
	print("📂 Carregando jogo...")
	
	# Lê o arquivo
	var arquivo := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if arquivo == null:
		push_error("Erro ao abrir arquivo para carregar: %s" % FileAccess.get_open_error())
		return false
	
	var json_string := arquivo.get_as_text()
	arquivo.close()
	
	# Parse do JSON
	var json := JSON.new()
	var erro := json.parse(json_string)
	if erro != OK:
		push_error("Erro ao parsear JSON: %s" % json.get_error_message())
		return false
	
	var dados_save: Dictionary = json.data
	
	# Validação básica de versão (útil para migrações futuras)
	if dados_save.get("versao", 0) != SAVE_VERSION:
		push_warning("Versão do save diferente! Pode haver incompatibilidades.")
	
	# --- RESTAURA GAMESTATE ---
	# Nota: atribuímos diretamente às variáveis, não usamos os setters
	# para evitar emitir sinais desnecessários durante o carregamento
	
	GameState.cidade_atual = dados_save.get("cidade_atual", 0)
	GameState.eficiencia_global = dados_save.get("eficiencia_global", 1.0)
	
	# Ouro e energia armazenada precisam usar os setters (têm clamp/validação)
	GameState.ouro = dados_save.get("ouro", 0.0)
	GameState.energia_armazenada = dados_save.get("energia_armazenada", 0.0)
	
	GameState.demanda_cidade = dados_save.get("demanda_cidade", 5.0)
	GameState.poluicao = dados_save.get("poluicao", 0.0)
	GameState.saude = dados_save.get("saude", {}).duplicate()
	GameState.tecnicos_manutencao = dados_save.get("tecnicos_manutencao", 0)
	GameState.tecnicos_ambientais = dados_save.get("tecnicos_ambientais", 0)
	GameState.filtro_carvao_ativo = dados_save.get("filtro_carvao_ativo", false)
	GameState.captura_carbono_ativa = dados_save.get("captura_carbono_ativa", false)
	
	# Geradores
	GameState.paineis_solares = dados_save.get("paineis_solares", 0)
	GameState.turbinas_eolicas = dados_save.get("turbinas_eolicas", 0)
	GameState.usinas_geotermicas = dados_save.get("usinas_geotermicas", 0)
	GameState.reatores_nucleares = dados_save.get("reatores_nucleares", 0)
	GameState.reatores_fusao = dados_save.get("reatores_fusao", 0)
	GameState.hidreletricas = dados_save.get("hidreletricas", 0)
	GameState.usinas_carvao = dados_save.get("usinas_carvao", 0)
	GameState.usinas_biomassa = dados_save.get("usinas_biomassa", 0)
	GameState.baterias = dados_save.get("baterias", 0)
	
	# Upgrades
	GameState.nivel_manivela = dados_save.get("nivel_manivela", 1)
	GameState.nivel_solar_upgrade = dados_save.get("nivel_solar_upgrade", 1)
	GameState.nivel_eolica_upgrade = dados_save.get("nivel_eolica_upgrade", 1)
	GameState.nivel_geotermica_upgrade = dados_save.get("nivel_geotermica_upgrade", 1)
	GameState.nivel_nuclear_upgrade = dados_save.get("nivel_nuclear_upgrade", 1)
	GameState.nivel_fusao_upgrade = dados_save.get("nivel_fusao_upgrade", 1)
	GameState.nivel_hidreletrica_upgrade = dados_save.get("nivel_hidreletrica_upgrade", 1)
	GameState.nivel_carvao_upgrade = dados_save.get("nivel_carvao_upgrade", 1)
	GameState.nivel_biomassa_upgrade = dados_save.get("nivel_biomassa_upgrade", 1)
	
	# Dicionários
	GameState.precos = dados_save.get("precos", GameState.PRECO_BASE.duplicate())
	GameState.bonus_conquistas = dados_save.get("bonus_conquistas", {}).duplicate()
	
	SkillTreeManager.pontos_disponiveis = dados_save.get("skill_pontos", 0)
	SkillTreeManager.desbloqueadas = dados_save.get("skill_desbloqueadas", {}).duplicate()
	SkillTreeManager._calcular_bonus_cache()
	
	# --- RESTAURA ACHIEVEMENTS ---
	AchievementManager.desbloqueadas = dados_save.get("conquistas_desbloqueadas", {}).duplicate()
	# Limpa as labels para recriar na próxima vez que abrir o painel
	AchievementManager._labels_conquistas.clear()
	
	# --- RECALCULA TUDO ---
	# Isso atualiza producao_solar, poder_manivela, etc. com base nos valores carregados
	GameState.recalcular_tudo()
	
	# Emite sinais para atualizar a interface
	GameState.recurso_mudou.emit()
	GameState.producao_mudou.emit()
	GameState.poluicao_mudou.emit()
	GameState.cidade_mudou.emit()
	
	print("✅ Jogo carregado com sucesso!")
	return true


# ============================================================================
# FUNÇÕES AUXILIARES
# ============================================================================

# Verifica se existe um save salvo
func existe_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# Deleta o save atual
func deletar_save() -> bool:
	if existe_save():
		var erro := DirAccess.remove_absolute(SAVE_PATH)
		if erro == OK:
			print("🗑️ Save deletado.")
			return true
		else:
			push_error("Erro ao deletar save: %s" % erro)
			return false
	return false

# Retorna informações básicas do save (para mostrar na tela de menu)
func get_info_save() -> Dictionary:
	if not existe_save():
		return {}
	
	var arquivo := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if arquivo == null:
		return {}
	
	var json_string := arquivo.get_as_text()
	arquivo.close()
	
	var json := JSON.new()
	if json.parse(json_string) != OK:
		return {}
	
	var dados: Dictionary = json.data
	
	return {
		"data": dados.get("data_salvamento", "Desconhecida"),
		"cidade": GameState.CIDADES[dados.get("cidade_atual", 0)].nome,
		"ouro": int(dados.get("ouro", 0)),
		"geradores": (
			dados.get("paineis_solares", 0) +
			dados.get("turbinas_eolicas", 0) +
			dados.get("usinas_carvao", 0) +
			dados.get("usinas_geotermicas", 0) +
			dados.get("usinas_biomassa", 0) +
			dados.get("hidreletricas", 0) +
			dados.get("reatores_nucleares", 0) +
			dados.get("reatores_fusao", 0)
		)
	}

class HomeController < ApplicationController
  def index
  end

  def run
    pessoas_por_decadas = {
      "decada_10" => 0,
      "decada_20" => 0,
      "decada_30" => 0,
      "decada_40" => 0,
      "decada_50" => 0,
      "decada_60" => 0,
      "decada_70" => 0,
      "decada_80" => 0,
      "decada_90" => 0,
      "decada_2000" => 0,
      "decada_2010" => 0,
      "decada_2020" => 0,
      "soma_total" => 0
    }

    epsilons = [0.01, 0.1, 0.5, 1.0]

    etapa_1()

    file_path = Rails.root.join('public', 'dados_covid-ce_02.csv')

    Rails.logger.info "Inicializando leitura do CSV"
    csv_data = CSV.read(file_path, headers: true, col_sep: ";")

    Rails.logger.info "Inicializando separação por decadas e raça"
    pessoas_por_decadas = separar_por_decadas(csv_data, pessoas_por_decadas)

    Rails.logger.info "Gerando histograma por epsilon"
    gerar_ruido_laplace(pessoas_por_decadas.dup, epsilons, 1)

    contagem_por_raca = {
      "PARDA" => 0,
      "AMARELA" => 0,
      "BRANCA" => 0,
      "PRETA" => 0,
      "INDIGENA" => 0
    }

    contagem_por_raca_morrinhos = {
      "PARDA" => 0,
      "AMARELA" => 0,
      "BRANCA" => 0,
      "PRETA" => 0,
      "INDIGENA" => 0
    }

    # 1. Gerar o histograma de raça/cor global
    contagem_por_raca = gerar_histograma_raca_global(csv_data,contagem_por_raca)

    # Salvando no db
    histograma_raca = HistogramaRaca.find_or_initialize_by(id: 1)
    histograma_raca.epsilon = nil
    histograma_raca.cidade = "GLOBAL"
    histograma_raca.branca_count = contagem_por_raca["BRANCA"]
    histograma_raca.amarela_count = contagem_por_raca["AMARELA"]
    histograma_raca.parda_count = contagem_por_raca["PARDA"]
    histograma_raca.preta_count = contagem_por_raca["PRETA"]
    histograma_raca.indigena_count = contagem_por_raca["INDIGENA"]
    histograma_raca.save!

    # 2. Gerar o histograma de raça/cor para a cidade alvo (MORRINHOS)
    contagem_por_raca_morrinhos = gerar_histograma_por_cidade(csv_data, contagem_por_raca_morrinhos , 'MORRINHOS')

    # Salvando no db
    histograma_raca = HistogramaRaca.find_or_initialize_by(id: 2)
    histograma_raca.epsilon = nil
    histograma_raca.cidade = "MORRINHOS"
    histograma_raca.branca_count = contagem_por_raca_morrinhos["BRANCA"]
    histograma_raca.amarela_count = contagem_por_raca_morrinhos["AMARELA"]
    histograma_raca.parda_count = contagem_por_raca_morrinhos["PARDA"]
    histograma_raca.preta_count = contagem_por_raca_morrinhos["PRETA"]
    histograma_raca.indigena_count = contagem_por_raca_morrinhos["INDIGENA"]
    histograma_raca.save!

    # 3. Aplicar o Mecanismo Exponencial 20 vezes para cada epsilon
    epsilons = [0.001, 0.01, 0.05, 0.5]
    aplicar_mecanismo_exponencial_raca(contagem_por_raca_morrinhos, epsilons, 1, 20)


    render plain: "Método run feito com sucesso!"
  end

  def get

    # Dados do Mecanismo de Laplace (Animais)
    animals_data = {}
    Animal.all.group_by(&:epsilon).each do |epsilon_val, animals|
      # Ordena por nome do animal para consistência no gráfico
      animals_data[epsilon_val.to_s] = animals.sort_by(&:animal).map do |a|
        { 'animal' => a.animal, 'count' => a.count, 'porcent' => a.porcent }
      end
    end

    # Dados do Mecanismo de Laplace (Décadas - HistrogramaGeral)
    decades_data = {}
    HistrogramaGeral.all.each do |hg|
      decade_counts = {
        'decada_10' => hg.decada_10,
        'decada_20' => hg.decada_20,
        'decada_30' => hg.decada_30,
        'decada_40' => hg.decada_40,
        'decada_50' => hg.decada_50,
        'decada_60' => hg.decada_60,
        'decada_70' => hg.decada_70,
        'decada_80' => hg.decada_80,
        'decada_90' => hg.decada_90,
        'decada_2000' => hg.decada_2000,
        'decada_2010' => hg.decada_2010,
        'decada_2020' => hg.decada_2020,
        'soma_total' => hg.soma_total # Inclui a soma total se necessário
      }
      decades_data[hg.epsilon.to_s] = decade_counts # Converte epsilon para string como chave
    end

    # Dados do Histograma de Raças (Global e Morrinhos)
    race_histograms = {}
    HistogramaRaca.all.each do |hr|
      race_counts = {
        'BRANCA' => hr.branca_count,
        'AMARELA' => hr.amarela_count,
        'PARDA' => hr.parda_count,
        'PRETA' => hr.preta_count,
        'INDIGENA' => hr.indigena_count
      }
      # Cria uma chave única combinando cidade e epsilon (se houver)
      key = "#{hr.cidade.downcase}_#{hr.epsilon.to_s || 'original'}"
      race_histograms[key] = race_counts
    end

    # Dados do Mecanismo Exponencial (Probabilidades e Simulações de Raça)
    race_probs_sims = {}
    RacasProb.all.each do |rp|
      probs = {
        'PARDA' => rp.parda,
        'AMARELA' => rp.amarela,
        'BRANCA' => rp.branca,
        'PRETA' => rp.preta,
        'INDIGENA' => rp.indigena
      }
      sims = {
        'PARDA' => rp.sim_parda,
        'AMARELA' => rp.sim_amarela,
        'BRANCA' => rp.sim_branca,
        'PRETA' => rp.sim_preta,
        'INDIGENA' => rp.sim_indigena
      }
      race_probs_sims[rp.epsilon.to_s] = { 'probabilities' => probs, 'simulations' => sims }
    end

    render json: {
      data: {
        animals_data: animals_data,
        decades_data: decades_data,
        race_histograms: race_histograms,
        race_probs_sims: race_probs_sims
      }
    }
  end

  private

  # Etapa 1 trabalho (Mecanismo de Laplace para Frequência de Animais)
  def etapa_1()
    frequencia_animais_original = { # Renomeado para clareza
                                    "gato" => 15,
                                    "cachorro" => 35,
                                    "coelho" => 5
    }

    # Seus epsilons para o ruído de Laplace
    epsilons_laplace = [0.01, 0.1, 0.5, 1.0]

    # Sensibilidade para contagens é 1.0
    sensibilidade_contagem = 1.0

    Rails.logger.info "Iniciando Etapa 1: Mecanismo de Laplace para Frequência de Animais"

    # --- Salvar as Frequências Originais (epsilon = 0 para representar 'sem privacidade') ---
    frequencia_animais_original.each do |animal_nome, count_original|
      animal_db = Animal.find_or_initialize_by(epsilon: 0.0, animal: animal_nome) # Use 0.0 para float
      animal_db.count = count_original
      # Se você tiver uma coluna 'porcent' no modelo Animal, pode deixar nil ou 0.0,
      # ou ajustar o modelo para não ter essa coluna se ela for específica do Exp. Mecanismo.
      animal_db.porcent = nil # Ou 0.0, ou remova se a coluna não for aplicável
      animal_db.save!
    end
    Rails.logger.info "Frequências Originais de Animais salvas (epsilon = 0.0)."


    # --- Aplicar o Mecanismo de Laplace para cada epsilon ---
    epsilons_laplace.each do |epsilon|
      Rails.logger.info "Processando animais para epsilon (ε) = #{epsilon}"

      # O parâmetro de escala 'b' para a distribuição de Laplace
      b = sensibilidade_contagem / epsilon

      frequencia_anonimizado = {}
      frequencia_animais_original.each do |animal, count_original|
        noise = generate_laplace_noise(b)
        noisy_count = (count_original + noise).round # Adiciona o ruído e arredonda
        frequencia_anonimizado[animal] = [0, noisy_count].max # Garante que a contagem não seja negativa

        # Salvando no banco de dados a frequência anonimizada
        animal_db = Animal.find_or_initialize_by(epsilon: epsilon, animal: animal)
        animal_db.count = frequencia_anonimizado[animal]
        animal_db.porcent = nil # Ou 0.0, ou remova se a coluna não for aplicável
        animal_db.save!
      end

      Rails.logger.info "Frequências Anonimizadas de Animais para ε=#{epsilon} salvas no Banco de Dados."
    end
  end

  # ----------------------------------------------------------------
  # Etapa 2 trabalho

  def separar_por_decadas(csv_data, pessoas_por_decadas)
    csv_data.map do |row|
      date = Date.strptime(row[3], '%d/%m/%Y')

      case date.year
      when 1910..1919
        # Década 10 (1910 - 1919)
        pessoas_por_decadas["decada_10"] += 1
      when 1920..1929
        # Década 20 (1920 - 1929)
        pessoas_por_decadas["decada_20"] += 1
      when 1930..1939
        # Década 30 (1930 - 1939)
        pessoas_por_decadas["decada_30"] += 1
      when 1940..1949
        # Década 40 (1940 - 1949)
        pessoas_por_decadas["decada_40"] += 1
      when 1950..1959
        # Década 50 (1950 - 1959)
        pessoas_por_decadas["decada_50"] += 1
      when 1960..1969
        # Década 60 (1960 - 1969)
        pessoas_por_decadas["decada_60"] += 1
      when 1970..1979
        # Década 70 (1970 - 1979)
        pessoas_por_decadas["decada_70"] += 1
      when 1980..1989
        # Década 80 (1980 - 1989)
        pessoas_por_decadas["decada_80"] += 1
      when 1990..1999
        # Década 90 (1990 - 1999)
        pessoas_por_decadas["decada_90"] += 1
      when 2000..2009
        # Década 2000 (2000 - 2009)
        pessoas_por_decadas["decada_2000"] += 1
      when 2010..2019
        # Década 2010 (2010 - 2019)
        pessoas_por_decadas["decada_2010"] += 1
      when 2020..2029
        # Década de 2020 (2020 - 2029)
        pessoas_por_decadas["decada_2020"] += 1
      else
        # Caso o ano esteja fora de qualquer década especificada
        Rails.logger.info "Ano #{date.year} fora das décadas definidas."
      end
    end
    pessoas_por_decadas["soma_total"] = csv_data.size

    return pessoas_por_decadas
  end

  # Implementação da função para gerar ruído de Laplace
  # Parâmetros:
  #   b (escala) = Delta_f / epsilon
  def generate_laplace_noise(b, rng = Random.new)
    u = rng.rand - 0.5 # Gera um número uniformemente aleatório entre -0.5 e 0.5

    # ALTERAÇÃO AQUI: Implementação do 'sinal' para Ruby 3.3.3
    sinal_u = if u > 0
                1
              elsif u < 0
                -1
              else
                0
              end

    -b * sinal_u * Math.log(1 - 2 * u.abs)
  end

  def gerar_ruido_laplace(histograma_original, epsilons, sensibilidade)

    histograma_original_db = HistrogramaGeral.find_or_initialize_by(epsilon: 0)
    histograma_original_db.epsilon = 0
    histograma_original_db.decada_10 = histograma_original["decada_10"]
    histograma_original_db.decada_20 = histograma_original["decada_20"]
    histograma_original_db.decada_30 = histograma_original["decada_30"]
    histograma_original_db.decada_40 = histograma_original["decada_40"]
    histograma_original_db.decada_50 = histograma_original["decada_50"]
    histograma_original_db.decada_60 = histograma_original["decada_60"]
    histograma_original_db.decada_70 = histograma_original["decada_70"]
    histograma_original_db.decada_80 = histograma_original["decada_80"]
    histograma_original_db.decada_90 = histograma_original["decada_90"]
    histograma_original_db.decada_2000 = histograma_original["decada_2000"]
    histograma_original_db.decada_2010 = histograma_original["decada_2010"]
    histograma_original_db.decada_2020 = histograma_original["decada_2020"]
    histograma_original_db.soma_total = histograma_original["soma_total"]
    histograma_original_db.save!

    epsilons.each do |epsilon|

      histograma_anonimizado = {}
      b = sensibilidade.to_f / epsilon # Parâmetro de escala para a distribuição de Laplace

      # Itera sobre cada década e sua contagem no histograma original
      histograma_original.each do |key, count|
        next if key == "soma_total" # Não adiciona ruído à soma total

        noise = generate_laplace_noise(b)
        noisy_count = (count + noise).round # Adiciona ruído e arredonda

        # Garante que a contagem não seja negativa (número de pessoas não pode ser negativo)
        histograma_anonimizado[key] = [0, noisy_count].max
      end

      # Calcular a soma total anonimizada (opcional, pode ser a soma dos bins ruidosos)
      histograma_anonimizado["soma_total_anonimizado"] = histograma_anonimizado.values.sum

      histograma_db = HistrogramaGeral.find_or_initialize_by(epsilon: epsilon)
      histograma_db.epsilon = epsilon
      histograma_db.decada_10 = histograma_anonimizado["decada_10"]
      histograma_db.decada_20 = histograma_anonimizado["decada_20"]
      histograma_db.decada_30 = histograma_anonimizado["decada_30"]
      histograma_db.decada_40 = histograma_anonimizado["decada_40"]
      histograma_db.decada_50 = histograma_anonimizado["decada_50"]
      histograma_db.decada_60 = histograma_anonimizado["decada_60"]
      histograma_db.decada_70 = histograma_anonimizado["decada_70"]
      histograma_db.decada_80 = histograma_anonimizado["decada_80"]
      histograma_db.decada_90 = histograma_anonimizado["decada_90"]
      histograma_db.decada_2000 = histograma_anonimizado["decada_2000"]
      histograma_db.decada_2010 = histograma_anonimizado["decada_2010"]
      histograma_db.decada_2020 = histograma_anonimizado["decada_2020"]
      histograma_db.soma_total = histograma_anonimizado["soma_total_anonimizado"]

      histograma_db.save!

    end
  end

  # ----------------------------------------------------------------
  # Etapa 3 trabalho

  def gerar_histograma_raca_global(csv_data, contagem_por_raca)
    csv_data.each do |row|
      case row[4].upcase
      when 'PARDA'
        contagem_por_raca["PARDA"] += 1
      when 'AMARELA'
        contagem_por_raca["AMARELA"] += 1
      when 'BRANCA'
        contagem_por_raca["BRANCA"] += 1
      when 'PRETA'
        contagem_por_raca["PRETA"] += 1
      when 'INDÍGENA'
        contagem_por_raca["INDIGENA"] += 1
      end
    end

    return contagem_por_raca
  end

  def gerar_histograma_por_cidade(csv_data, contagem_por_raca_morrinhos, cidade_alvo)
    csv_data.map do |row|
      if row[2].to_s.split('/')[1].eql?(cidade_alvo)
        case row[4].upcase
        when 'PARDA'
          contagem_por_raca_morrinhos["PARDA"] += 1
        when 'AMARELA'
          contagem_por_raca_morrinhos["AMARELA"] += 1
        when 'BRANCA'
          contagem_por_raca_morrinhos["BRANCA"] += 1
        when 'PRETA'
          contagem_por_raca_morrinhos["PRETA"] += 1
        when 'INDÍGENA'
          contagem_por_raca_morrinhos["INDIGENA"] += 1
        end
      end
    end
    return contagem_por_raca_morrinhos
  end

  def aplicar_mecanismo_exponencial_raca(histograma_raca, epsilons, sensibilidade_score, num_repeticoes = 20)

    if histograma_raca.values.all?(&:zero?)
      Rails.logger.error "Aviso: O histograma de raça/cor para a cidade alvo contém apenas zeros. O mecanismo exponencial produzirá probabilidades uniformes ou zero."
    end

    epsilons.each do |epsilon|

      attributes_to_set = {}
      racas_probs = RacasProb.find_or_initialize_by(epsilon: epsilon)

      scores = {}
      histograma_raca.each do |raca, count|
        exponent = (epsilon * count) / (2.0 * sensibilidade_score)
        score = Math.exp(exponent)
        scores[raca] = score
      end

      sum_of_scores = scores.values.sum

      # Calcula as probabilidades de seleção para cada categoria
      probabilities = {}
      scores.each do |raca, score|
        probability = score / sum_of_scores
        probabilities[raca] = probability

        # Atributos para DB
        attributes_to_set[raca.downcase.to_sym] = probability * 100

      end


      # Aplica o mecanismo Exponencial 'num_repeticoes' vezes
      selecoes_resultantes = Hash.new(0)

      candidates = probabilities.keys
      weights = probabilities.values

      total_normalized_weight = weights.sum

      # Garante que os pesos sejam válidos e somem 1 (ou próximo disso)
      normalized_weights = weights.map do |w|
        w.nan? ? 0.0 : w / total_normalized_weight
      end

      num_repeticoes.times do
        r = Random.new.rand # Gera um número aleatório entre 0.0 e 1.0
        cumulative_weight = 0.0
        selected_candidate = nil

        # Lógica para amostragem ponderada
        normalized_weights.each_with_index do |weight, index|
          cumulative_weight += weight
          if r <= cumulative_weight
            selected_candidate = candidates[index]
            break # Sai do loop assim que um candidato é selecionado
          end
        end

        selecoes_resultantes[selected_candidate] += 1
      end

      # Apresenta os resultados das simulações
      selecoes_resultantes.sort_by { |_, count| -count }.each do |raca, count| # Ordena do mais frequente para o menos
        # Atributos para DB
        attributes_to_set["sim_".concat(raca).downcase.to_sym] = count

      end

      racas_probs.assign_attributes(attributes_to_set)
      racas_probs.save!
    end
  end

end

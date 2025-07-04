-- Pergunta 1
-- Em quais bairros a imobiliária tem o maior volume de negócios (vendas e aluguéis) e qual a receita média por transação nesses bairros?
SELECT 
  e.Bairro,
  COUNT(t.idTransacao) AS total_transacoes,
  SUM(t.valorReal) AS receita_total,
  AVG(t.valorReal) AS receita_media
FROM Transacao t
JOIN Imovel i ON t.imovel_id = i.idImovel
JOIN Endereco e ON i.idImovel = e.idEndereco
GROUP BY e.Bairro
ORDER BY total_transacoes DESC;

-- Pergunta 2
-- Funcionários mais eficazes em termos de comissão gerada e número de transações fechadas
SELECT 
  f.idFuncionario,
  p.Nome AS nome_funcionario,
  COUNT(t.idTransacao) AS transacoes_fechadas,
  SUM(t.Comissao) AS total_comissao,
  SUM(t.valorReal) AS receita_gerada
FROM Funcionario f
JOIN Pessoa p ON f.pessoa_id = p.idPessoa
JOIN Transacao t ON f.transacao_id = t.idTransacao
GROUP BY f.idFuncionario
ORDER BY total_comissao DESC, transacoes_fechadas DESC;

-- Pergunta 3
-- Média de tempo para transacionar imóveis, por categoria e bairro
SELECT 
  i.Bairro,
  'Casa' AS categoria,
  AVG(DATEDIFF(t.Data, i.dataConstrucao)) AS media_dias
FROM Transacao t
JOIN Imovel i ON t.imovel_id = i.idImovel
JOIN Casa c ON i.idImovel = c.imovel_id
GROUP BY i.Bairro

UNION ALL

SELECT 
  i.Bairro,
  'Apartamento' AS categoria,
  AVG(DATEDIFF(t.Data, i.dataConstrucao)) AS media_dias
FROM Transacao t
JOIN Imovel i ON t.imovel_id = i.idImovel
JOIN Apartamento a ON i.idImovel = a.imovel_id
GROUP BY i.Bairro

UNION ALL

SELECT 
  i.Bairro,
  'Terreno' AS categoria,
  AVG(DATEDIFF(t.Data, i.dataConstrucao)) AS media_dias
FROM Transacao t
JOIN Imovel i ON t.imovel_id = i.idImovel
JOIN Terreno te ON i.idImovel = te.imovel_id
GROUP BY i.Bairro

UNION ALL

SELECT 
  i.Bairro,
  'Sala Comercial' AS categoria,
  AVG(DATEDIFF(t.Data, i.dataConstrucao)) AS media_dias
FROM Transacao t
JOIN Imovel i ON t.imovel_id = i.idImovel
JOIN salaComercial s ON i.idImovel = s.imovel_id
GROUP BY i.Bairro;

-- Pergunta 4
-- Categoria que gera mais receita e sua margem de comissão
SELECT 
  'Casa' AS categoria,
  SUM(t.valorReal) AS receita_total,
  AVG(t.Comissao / t.valorReal) * 100 AS margem_comissao
FROM Transacao t
JOIN Imovel i ON t.imovel_id = i.idImovel
JOIN Casa c ON i.idImovel = c.imovel_id

UNION ALL

SELECT 
  'Apartamento',
  SUM(t.valorReal),
  AVG(t.Comissao / t.valorReal) * 100
FROM Transacao t
JOIN Imovel i ON t.imovel_id = i.idImovel
JOIN Apartamento a ON i.idImovel = a.imovel_id

UNION ALL

SELECT 
  'Terreno',
  SUM(t.valorReal),
  AVG(t.Comissao / t.valorReal) * 100
FROM Transacao t
JOIN Imovel i ON t.imovel_id = i.idImovel
JOIN Terreno te ON i.idImovel = te.imovel_id

UNION ALL

SELECT 
  'Sala Comercial',
  SUM(t.valorReal),
  AVG(t.Comissao / t.valorReal) * 100
FROM Transacao t
JOIN Imovel i ON t.imovel_id = i.idImovel
JOIN salaComercial s ON i.idImovel = s.imovel_id;

-- Pergunta 5
-- Quantos imóveis foram retirados e sua proporção nos últimos 12 meses
SELECT 
  categoria,
  COUNT(*) AS total_retirados,
  ROUND(COUNT(*) / (SELECT COUNT(*) FROM Imovel WHERE YEAR(dataConstrucao) = YEAR(CURDATE()) AND MONTH(dataConstrucao) >= MONTH(DATE_SUB(CURDATE(), INTERVAL 12 MONTH))), 2) AS proporcao
FROM (
  SELECT 'Casa' AS categoria FROM Casa
  UNION ALL
  SELECT 'Apartamento' FROM Apartamento
  UNION ALL
  SELECT 'Terreno' FROM Terreno
  UNION ALL
  SELECT 'Sala Comercial' FROM salaComercial
) AS sub
GROUP BY categoria;

-- Pergunta 6
-- Clientes proprietários com mais transações e valor total
SELECT 
  cp.idclienteProprietario,
  p.Nome,
  COUNT(t.idTransacao) AS transacoes,
  SUM(t.valorReal) AS valor_total
FROM clienteProprietario cp
JOIN Pessoa p ON cp.pessoa_id = p.idPessoa
JOIN Imovel i ON cp.imovel_id = i.idImovel
JOIN Transacao t ON i.idImovel = t.imovel_id
GROUP BY cp.idclienteProprietario
ORDER BY valor_total DESC;

-- Pergunta 7
-- Perfil demográfico dos clientes que mais alugam e compram imóveis
SELECT 
  s.descricao AS sexo,
  ec.Descricao AS estado_civil,
  pr.Descricao AS profissao,
  COUNT(*) AS total_transacoes
FROM clienteUsuario cu
JOIN Pessoa p ON cu.idclienteUsuario = p.idPessoa
JOIN Sexo s ON p.sexo_id = s.idSexo
JOIN estadoCivil ec ON p.estado_civil_id = ec.idestadoCivil
JOIN Profissao pr ON p.profissao_id = pr.idProfissao
GROUP BY sexo, estado_civil, profissao
ORDER BY total_transacoes DESC;

-- Pergunta 8
-- Média de quartos e suítes por bairro
SELECT 
  i.Bairro,
  'Casa' AS categoria,
  AVG(c.qntQuartos) AS media_quartos,
  NULL AS media_suites
FROM Casa c
JOIN Imovel i ON c.imovel_id = i.idImovel
GROUP BY i.Bairro

UNION ALL

SELECT 
  i.Bairro,
  'Apartamento',
  AVG(a.qntQuartos),
  AVG(a.qntSuites)
FROM Apartamento a
JOIN Imovel i ON a.imovel_id = i.idImovel
GROUP BY i.Bairro;

-- Pergunta 9
-- Performance mensal em número de transações e receita
SELECT 
  DATE_FORMAT(Data, '%Y-%m') AS mes,
  COUNT(*) AS total_transacoes,
  SUM(valorReal) AS receita_mensal
FROM Transacao
GROUP BY mes
ORDER BY mes;

-- Pergunta 10
-- Distribuição das formas de pagamento e valor médio
SELECT 
  formaPagamento,
  COUNT(*) AS total_transacoes,
  AVG(valorReal) AS valor_medio
FROM Transacao
GROUP BY formaPagamento
ORDER BY total_transacoes DESC;

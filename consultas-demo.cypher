// =====================================================================
// CONSULTAS PARA A DEMONSTRAÇÃO - Loja virtual (Neo4j)
// Rode uma de cada vez no Query. Nas que retornam nós e caminhos,
// use a visualização em grafo.
// =====================================================================


// 1. Quanto existe no banco (nós por tipo)
MATCH (n)
RETURN labels(n)[0] AS tipo, count(*) AS quantidade
ORDER BY quantidade DESC;


// 2. Quantos relacionamentos de cada tipo
MATCH ()-[r]->()
RETURN type(r) AS relacionamento, count(*) AS quantidade
ORDER BY quantidade DESC;


// 3. O exemplo dos slides: o que a Ana comprou (cliente, pedido, produto e categoria)
MATCH (c:Cliente {nome: 'Ana'})-[:COMPROU]->(ped:Pedido)-[:CONTEM]->(p:Produto)-[:PERTENCE_A]->(cat:Categoria)
RETURN c, ped, p, cat;


// 4. Recomendação: quem comprou o mesmo que a Ana também comprou...
MATCH (ana:Cliente {nome: 'Ana'})-[:COMPROU]->(:Pedido)-[:CONTEM]->(:Produto)<-[:CONTEM]-(:Pedido)<-[:COMPROU]-(outro:Cliente)
WHERE outro <> ana
MATCH (outro)-[:COMPROU]->(:Pedido)-[:CONTEM]->(rec:Produto)
WHERE NOT EXISTS { (ana)-[:COMPROU]->(:Pedido)-[:CONTEM]->(rec) }
RETURN rec.nome AS recomendado, count(DISTINCT outro) AS clientes
ORDER BY clientes DESC
LIMIT 5;


// 5. Faturamento por categoria (sem contar pedidos cancelados)
MATCH (cat:Categoria)<-[:PERTENCE_A]-(:Produto)<-[r:CONTEM]-(ped:Pedido)
WHERE ped.status <> 'Cancelado'
RETURN cat.nome AS categoria,
       round(sum(r.quantidade * r.precoUnitario)) AS faturamento
ORDER BY faturamento DESC;


// 6. Produtos mais bem avaliados (com pelo menos 5 avaliações)
MATCH (p:Produto)
WHERE p.qtdAvaliacoes >= 5
RETURN p.nome AS produto, p.notaMedia AS nota, p.qtdAvaliacoes AS avaliacoes
ORDER BY nota DESC, avaliacoes DESC
LIMIT 10;


// 7. Melhores clientes (quanto gastaram)
MATCH (c:Cliente)-[:COMPROU]->(p:Pedido)
WHERE p.status <> 'Cancelado'
RETURN c.nome AS cliente, count(p) AS pedidos, round(sum(p.total)) AS gasto
ORDER BY gasto DESC
LIMIT 10;


// 8. Rede de indicações a partir da Ana (até 3 saltos)
MATCH path = (:Cliente {nome: 'Ana'})-[:INDICOU*1..3]-(:Cliente)
RETURN path
LIMIT 50;


// 9. Estados que mais compram
MATCH (e:Estado)<-[:EM]-(:Cidade)<-[:MORA_EM]-(:Cliente)-[:COMPROU]->(p:Pedido)
WHERE p.status <> 'Cancelado'
RETURN e.uf AS estado, count(p) AS pedidos, round(sum(p.total)) AS faturamento
ORDER BY faturamento DESC;


// 10. Cupons mais usados
MATCH (cp:Cupom)<-[:USOU_CUPOM]-(p:Pedido)
RETURN cp.codigo AS cupom, cp.desconto AS desconto_percentual, count(p) AS usos
ORDER BY usos DESC;

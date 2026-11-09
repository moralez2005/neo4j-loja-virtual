// =====================================================================
// LOJA VIRTUAL - banco de dados em grafos (Neo4j)
// Trabalho de Neo4j
//
// Como usar:
//   1. Crie uma instância AuraDB Free em console.neo4j.io
//   2. Abra a ferramenta Query, cole este arquivo inteiro e execute
//      (os comandos são separados por ponto e vírgula)
//   3. Rode: MATCH (n) RETURN labels(n)[0] AS tipo, count(*) AS qtd
//
// Para recomeçar do zero (apaga tudo!), descomente a linha abaixo:
// MATCH (n) DETACH DELETE n;
//
// Modelo:
//   (Cliente)-[:COMPROU]->(Pedido)-[:CONTEM]->(Produto)-[:PERTENCE_A]->(Categoria)
//   (Produto)-[:DA_MARCA]->(Marca)   (Produto)-[:FORNECIDO_POR]->(Fornecedor)
//   (Cliente)-[:MORA_EM]->(Cidade)-[:EM]->(Estado)
//   (Cliente)-[:AVALIOU {nota, comentario}]->(Produto)
//   (Pedido)-[:USOU_CUPOM]->(Cupom)   (Cliente)-[:INDICOU]->(Cliente)
// =====================================================================


// ---------------------------------------------------------------------
// 1. Restrições (garantem ids únicos e aceleram as buscas)
// ---------------------------------------------------------------------
CREATE CONSTRAINT cliente_id IF NOT EXISTS FOR (c:Cliente) REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT pedido_id IF NOT EXISTS FOR (p:Pedido) REQUIRE p.id IS UNIQUE;
CREATE CONSTRAINT produto_sku IF NOT EXISTS FOR (p:Produto) REQUIRE p.sku IS UNIQUE;
CREATE CONSTRAINT categoria_nome IF NOT EXISTS FOR (c:Categoria) REQUIRE c.nome IS UNIQUE;
CREATE CONSTRAINT marca_nome IF NOT EXISTS FOR (m:Marca) REQUIRE m.nome IS UNIQUE;
CREATE CONSTRAINT fornecedor_nome IF NOT EXISTS FOR (f:Fornecedor) REQUIRE f.nome IS UNIQUE;
CREATE CONSTRAINT cidade_nome IF NOT EXISTS FOR (c:Cidade) REQUIRE c.nome IS UNIQUE;
CREATE CONSTRAINT estado_uf IF NOT EXISTS FOR (e:Estado) REQUIRE e.uf IS UNIQUE;
CREATE CONSTRAINT cupom_codigo IF NOT EXISTS FOR (c:Cupom) REQUIRE c.codigo IS UNIQUE;


// ---------------------------------------------------------------------
// 2. Cidades e estados
// ---------------------------------------------------------------------
UNWIND [
  {nome: 'São Paulo', uf: 'SP'},
  {nome: 'Campinas', uf: 'SP'},
  {nome: 'Sorocaba', uf: 'SP'},
  {nome: 'Santos', uf: 'SP'},
  {nome: 'Ribeirão Preto', uf: 'SP'},
  {nome: 'Rio de Janeiro', uf: 'RJ'},
  {nome: 'Niterói', uf: 'RJ'},
  {nome: 'Belo Horizonte', uf: 'MG'},
  {nome: 'Uberlândia', uf: 'MG'},
  {nome: 'Curitiba', uf: 'PR'},
  {nome: 'Londrina', uf: 'PR'},
  {nome: 'Florianópolis', uf: 'SC'},
  {nome: 'Joinville', uf: 'SC'},
  {nome: 'Porto Alegre', uf: 'RS'},
  {nome: 'Caxias do Sul', uf: 'RS'},
  {nome: 'Salvador', uf: 'BA'},
  {nome: 'Recife', uf: 'PE'},
  {nome: 'Fortaleza', uf: 'CE'},
  {nome: 'Brasília', uf: 'DF'},
  {nome: 'Goiânia', uf: 'GO'}
] AS x
MERGE (e:Estado {uf: x.uf})
CREATE (ci:Cidade {nome: x.nome})
CREATE (ci)-[:EM]->(e);


// ---------------------------------------------------------------------
// 3. Catálogo: 64 produtos, 8 categorias, 9 marcas, 6 fornecedores
// ---------------------------------------------------------------------
UNWIND [
  // Áudio
  {sku: 'AUD-001', nome: 'Fone BT', preco: 199.90, estoque: 120, categoria: 'Áudio', marca: 'SonoMax', fornecedor: 'TechDistrib'},
  {sku: 'AUD-002', nome: 'Fone com Fio P2', preco: 49.90, estoque: 300, categoria: 'Áudio', marca: 'SonoMax', fornecedor: 'TechDistrib'},
  {sku: 'AUD-003', nome: 'Caixa de Som Portátil', preco: 229.90, estoque: 85, categoria: 'Áudio', marca: 'SonoMax', fornecedor: 'TechDistrib'},
  {sku: 'AUD-004', nome: 'Soundbar 2.1', preco: 549.00, estoque: 40, categoria: 'Áudio', marca: 'Voltix', fornecedor: 'Importadora Aurora'},
  {sku: 'AUD-005', nome: 'Microfone USB', preco: 189.90, estoque: 60, categoria: 'Áudio', marca: 'Voltix', fornecedor: 'Importadora Aurora'},
  {sku: 'AUD-006', nome: 'Headset Gamer 7.1', preco: 299.90, estoque: 75, categoria: 'Áudio', marca: 'Voltix', fornecedor: 'Importadora Aurora'},
  {sku: 'AUD-007', nome: 'Fone Intra-auricular', preco: 79.90, estoque: 210, categoria: 'Áudio', marca: 'SonoMax', fornecedor: 'TechDistrib'},
  {sku: 'AUD-008', nome: 'Caixa Bluetooth à Prova de Água', preco: 259.90, estoque: 55, categoria: 'Áudio', marca: 'SonoMax', fornecedor: 'Importadora Aurora'},
  // Informática
  {sku: 'INF-001', nome: 'Webcam Full HD', preco: 150.00, estoque: 90, categoria: 'Informática', marca: 'Voltix', fornecedor: 'TechDistrib'},
  {sku: 'INF-002', nome: 'Mouse Sem Fio', preco: 79.90, estoque: 250, categoria: 'Informática', marca: 'Nexora', fornecedor: 'TechDistrib'},
  {sku: 'INF-003', nome: 'Teclado Mecânico', preco: 349.90, estoque: 70, categoria: 'Informática', marca: 'Nexora', fornecedor: 'TechDistrib'},
  {sku: 'INF-004', nome: 'Monitor 24 polegadas', preco: 899.00, estoque: 35, categoria: 'Informática', marca: 'Nexora', fornecedor: 'Importadora Aurora'},
  {sku: 'INF-005', nome: 'Notebook 15 polegadas', preco: 3299.00, estoque: 18, categoria: 'Informática', marca: 'Nexora', fornecedor: 'Importadora Aurora'},
  {sku: 'INF-006', nome: 'Hub USB-C 7 em 1', preco: 159.90, estoque: 110, categoria: 'Informática', marca: 'Voltix', fornecedor: 'TechDistrib'},
  {sku: 'INF-007', nome: 'SSD 480 GB', preco: 219.90, estoque: 140, categoria: 'Informática', marca: 'Nexora', fornecedor: 'TechDistrib'},
  {sku: 'INF-008', nome: 'Mousepad Grande', preco: 39.90, estoque: 400, categoria: 'Informática', marca: 'Voltix', fornecedor: 'Atacado Sul'},
  // Celulares
  {sku: 'CEL-001', nome: 'Smartphone 128 GB', preco: 1499.00, estoque: 60, categoria: 'Celulares', marca: 'Kairo', fornecedor: 'Importadora Aurora'},
  {sku: 'CEL-002', nome: 'Smartphone 256 GB', preco: 2199.00, estoque: 40, categoria: 'Celulares', marca: 'Kairo', fornecedor: 'Importadora Aurora'},
  {sku: 'CEL-003', nome: 'Carregador Turbo 25W', preco: 89.90, estoque: 320, categoria: 'Celulares', marca: 'Kairo', fornecedor: 'TechDistrib'},
  {sku: 'CEL-004', nome: 'Cabo USB-C', preco: 49.90, estoque: 600, categoria: 'Celulares', marca: 'Kairo', fornecedor: 'Atacado Sul'},
  {sku: 'CEL-005', nome: 'Capa Protetora', preco: 34.90, estoque: 500, categoria: 'Celulares', marca: 'Kairo', fornecedor: 'Atacado Sul'},
  {sku: 'CEL-006', nome: 'Película de Vidro', preco: 24.90, estoque: 700, categoria: 'Celulares', marca: 'Kairo', fornecedor: 'Atacado Sul'},
  {sku: 'CEL-007', nome: 'Power Bank 10000 mAh', preco: 129.90, estoque: 150, categoria: 'Celulares', marca: 'Voltix', fornecedor: 'TechDistrib'},
  {sku: 'CEL-008', nome: 'Smartwatch', preco: 399.90, estoque: 65, categoria: 'Celulares', marca: 'Kairo', fornecedor: 'Importadora Aurora'},
  // Games
  {sku: 'GAM-001', nome: 'Controle Sem Fio', preco: 249.90, estoque: 100, categoria: 'Games', marca: 'Playon', fornecedor: 'Importadora Aurora'},
  {sku: 'GAM-002', nome: 'Console Portátil', preco: 1899.00, estoque: 25, categoria: 'Games', marca: 'Playon', fornecedor: 'Importadora Aurora'},
  {sku: 'GAM-003', nome: 'Jogo de Aventura', preco: 199.90, estoque: 150, categoria: 'Games', marca: 'Playon', fornecedor: 'Importadora Aurora'},
  {sku: 'GAM-004', nome: 'Jogo de Corrida', preco: 179.90, estoque: 130, categoria: 'Games', marca: 'Playon', fornecedor: 'Importadora Aurora'},
  {sku: 'GAM-005', nome: 'Cadeira Gamer', preco: 1099.00, estoque: 30, categoria: 'Games', marca: 'Playon', fornecedor: 'Global Eletro'},
  {sku: 'GAM-006', nome: 'Volante com Pedais', preco: 899.00, estoque: 20, categoria: 'Games', marca: 'Playon', fornecedor: 'Importadora Aurora'},
  {sku: 'GAM-007', nome: 'Cartão Pré-pago R$ 100', preco: 100.00, estoque: 999, categoria: 'Games', marca: 'Playon', fornecedor: 'TechDistrib'},
  {sku: 'GAM-008', nome: 'Suporte para Controle', preco: 59.90, estoque: 180, categoria: 'Games', marca: 'Playon', fornecedor: 'Atacado Sul'},
  // Casa Inteligente
  {sku: 'CAS-001', nome: 'Lâmpada Inteligente Wi-Fi', preco: 59.90, estoque: 260, categoria: 'Casa Inteligente', marca: 'Luminar', fornecedor: 'TechDistrib'},
  {sku: 'CAS-002', nome: 'Tomada Inteligente', preco: 69.90, estoque: 220, categoria: 'Casa Inteligente', marca: 'Luminar', fornecedor: 'TechDistrib'},
  {sku: 'CAS-003', nome: 'Câmera de Segurança', preco: 229.90, estoque: 80, categoria: 'Casa Inteligente', marca: 'Luminar', fornecedor: 'Importadora Aurora'},
  {sku: 'CAS-004', nome: 'Fechadura Digital', preco: 799.00, estoque: 22, categoria: 'Casa Inteligente', marca: 'Luminar', fornecedor: 'Importadora Aurora'},
  {sku: 'CAS-005', nome: 'Assistente de Voz', preco: 349.00, estoque: 70, categoria: 'Casa Inteligente', marca: 'Luminar', fornecedor: 'TechDistrib'},
  {sku: 'CAS-006', nome: 'Sensor de Presença', preco: 89.90, estoque: 140, categoria: 'Casa Inteligente', marca: 'Luminar', fornecedor: 'TechDistrib'},
  {sku: 'CAS-007', nome: 'Fita de LED 5 m', preco: 79.90, estoque: 190, categoria: 'Casa Inteligente', marca: 'Luminar', fornecedor: 'Atacado Sul'},
  {sku: 'CAS-008', nome: 'Roteador Wi-Fi 6', preco: 399.90, estoque: 75, categoria: 'Casa Inteligente', marca: 'Nexora', fornecedor: 'Importadora Aurora'},
  // Eletrodomésticos
  {sku: 'ELE-001', nome: 'Cafeteira Elétrica', preco: 189.90, estoque: 95, categoria: 'Eletrodomésticos', marca: 'Casalar', fornecedor: 'Global Eletro'},
  {sku: 'ELE-002', nome: 'Liquidificador', preco: 159.90, estoque: 110, categoria: 'Eletrodomésticos', marca: 'Casalar', fornecedor: 'Global Eletro'},
  {sku: 'ELE-003', nome: 'Sanduicheira', preco: 119.90, estoque: 130, categoria: 'Eletrodomésticos', marca: 'Casalar', fornecedor: 'Global Eletro'},
  {sku: 'ELE-004', nome: 'Aspirador Robô', preco: 1299.00, estoque: 24, categoria: 'Eletrodomésticos', marca: 'Casalar', fornecedor: 'Global Eletro'},
  {sku: 'ELE-005', nome: 'Air Fryer 5 L', preco: 449.00, estoque: 55, categoria: 'Eletrodomésticos', marca: 'Casalar', fornecedor: 'Global Eletro'},
  {sku: 'ELE-006', nome: 'Ventilador de Mesa', preco: 129.90, estoque: 120, categoria: 'Eletrodomésticos', marca: 'Casalar', fornecedor: 'Atacado Sul'},
  {sku: 'ELE-007', nome: 'Micro-ondas 20 L', preco: 599.00, estoque: 38, categoria: 'Eletrodomésticos', marca: 'Casalar', fornecedor: 'Global Eletro'},
  {sku: 'ELE-008', nome: 'Chaleira Elétrica', preco: 99.90, estoque: 170, categoria: 'Eletrodomésticos', marca: 'Casalar', fornecedor: 'Atacado Sul'},
  // Livros
  {sku: 'LIV-001', nome: 'Introdução a Banco de Dados', preco: 89.90, estoque: 80, categoria: 'Livros', marca: 'Páginas Vivas', fornecedor: 'Editora Fonte'},
  {sku: 'LIV-002', nome: 'Modelagem de Dados na Prática', preco: 94.90, estoque: 70, categoria: 'Livros', marca: 'Páginas Vivas', fornecedor: 'Editora Fonte'},
  {sku: 'LIV-003', nome: 'Algoritmos Ilustrados', preco: 79.90, estoque: 90, categoria: 'Livros', marca: 'Páginas Vivas', fornecedor: 'Editora Fonte'},
  {sku: 'LIV-004', nome: 'Lógica de Programação', preco: 59.90, estoque: 120, categoria: 'Livros', marca: 'Páginas Vivas', fornecedor: 'Editora Fonte'},
  {sku: 'LIV-005', nome: 'Redes de Computadores', preco: 109.90, estoque: 60, categoria: 'Livros', marca: 'Páginas Vivas', fornecedor: 'Editora Fonte'},
  {sku: 'LIV-006', nome: 'Segurança da Informação', preco: 99.90, estoque: 65, categoria: 'Livros', marca: 'Páginas Vivas', fornecedor: 'Editora Fonte'},
  {sku: 'LIV-007', nome: 'Romance de Ficção Científica', preco: 49.90, estoque: 140, categoria: 'Livros', marca: 'Páginas Vivas', fornecedor: 'Editora Fonte'},
  {sku: 'LIV-008', nome: 'Guia de Produtividade', preco: 44.90, estoque: 160, categoria: 'Livros', marca: 'Páginas Vivas', fornecedor: 'Editora Fonte'},
  // Esporte
  {sku: 'ESP-001', nome: 'Garrafa Térmica', preco: 69.90, estoque: 200, categoria: 'Esporte', marca: 'Vigor', fornecedor: 'Esportes Brasil'},
  {sku: 'ESP-002', nome: 'Tênis de Corrida', preco: 349.90, estoque: 90, categoria: 'Esporte', marca: 'Vigor', fornecedor: 'Esportes Brasil'},
  {sku: 'ESP-003', nome: 'Bicicleta Ergométrica', preco: 1599.00, estoque: 15, categoria: 'Esporte', marca: 'Vigor', fornecedor: 'Esportes Brasil'},
  {sku: 'ESP-004', nome: 'Halteres 5 kg (par)', preco: 119.90, estoque: 80, categoria: 'Esporte', marca: 'Vigor', fornecedor: 'Esportes Brasil'},
  {sku: 'ESP-005', nome: 'Tapete de Yoga', preco: 79.90, estoque: 150, categoria: 'Esporte', marca: 'Vigor', fornecedor: 'Esportes Brasil'},
  {sku: 'ESP-006', nome: 'Corda de Pular', preco: 29.90, estoque: 400, categoria: 'Esporte', marca: 'Vigor', fornecedor: 'Esportes Brasil'},
  {sku: 'ESP-007', nome: 'Mochila Esportiva', preco: 139.90, estoque: 110, categoria: 'Esporte', marca: 'Vigor', fornecedor: 'Esportes Brasil'},
  {sku: 'ESP-008', nome: 'Relógio Esportivo', preco: 299.90, estoque: 60, categoria: 'Esporte', marca: 'Vigor', fornecedor: 'Esportes Brasil'}
] AS p
MERGE (cat:Categoria {nome: p.categoria})
MERGE (m:Marca {nome: p.marca})
MERGE (f:Fornecedor {nome: p.fornecedor})
CREATE (pr:Produto {sku: p.sku, nome: p.nome, preco: p.preco, estoque: p.estoque})
CREATE (pr)-[:PERTENCE_A]->(cat)
CREATE (pr)-[:DA_MARCA]->(m)
CREATE (pr)-[:FORNECIDO_POR]->(f);


// ---------------------------------------------------------------------
// 4. Cupons de desconto
// ---------------------------------------------------------------------
CREATE (:Cupom {codigo: 'BEMVINDO10', desconto: 10}),
       (:Cupom {codigo: 'FRETEGRATIS', desconto: 5}),
       (:Cupom {codigo: 'BLACK15', desconto: 15}),
       (:Cupom {codigo: 'VOLTA7', desconto: 7}),
       (:Cupom {codigo: 'ANIVERSARIO20', desconto: 20}),
       (:Cupom {codigo: 'ESTUDANTE8', desconto: 8});


// ---------------------------------------------------------------------
// 5. Clientes: a Ana (usada nos slides) e mais 500 gerados
// ---------------------------------------------------------------------
CREATE (:Cliente {id: 0, nome: 'Ana', email: 'ana@exemplo.com.br', nivel: 'Ouro', cadastro: date('2024-03-15')});

WITH [
  'Bruno', 'Carla', 'Diego', 'Elisa', 'Fábio', 'Gabriela', 'Henrique', 'Isabela',
  'João', 'Karina', 'Lucas', 'Mariana', 'Nicolas', 'Olívia', 'Pedro', 'Quésia',
  'Rafael', 'Sofia', 'Thiago', 'Valentina', 'Wagner', 'Yasmin', 'Zélia', 'Amanda',
  'Beatriz', 'Caio', 'Daniela', 'Eduardo', 'Fernanda', 'Guilherme', 'Helena', 'Igor',
  'Juliana', 'Kaique', 'Larissa', 'Marcelo', 'Natália', 'Otávio', 'Patrícia', 'Renato'
] AS nomes,
[
  'Silva', 'Souza', 'Oliveira', 'Santos', 'Pereira', 'Lima', 'Costa', 'Ferreira',
  'Rodrigues', 'Almeida', 'Nascimento', 'Carvalho', 'Araújo', 'Ribeiro', 'Martins',
  'Barbosa', 'Gomes', 'Rocha', 'Dias', 'Moreira', 'Mendes', 'Cardoso', 'Teixeira',
  'Correia', 'Freitas', 'Ramos', 'Nunes', 'Vieira', 'Monteiro', 'Cavalcanti'
] AS sobrenomes
UNWIND range(1, 500) AS i
CREATE (:Cliente {
  id: i,
  nome: nomes[i % size(nomes)] + ' ' + sobrenomes[(i * 7 + i / 40) % size(sobrenomes)],
  email: 'cliente' + toString(i) + '@exemplo.com.br',
  nivel: ['Bronze', 'Prata', 'Ouro'][i % 3],
  cadastro: date('2024-01-01') + duration({days: (i * 13) % 700})
});

// Cada cliente mora em uma cidade
MATCH (ci:Cidade)
WITH collect(ci) AS cidades
MATCH (c:Cliente)
WITH c, cidades[(c.id * 3 + c.id / 20) % size(cidades)] AS cidade
CREATE (c)-[:MORA_EM]->(cidade);


// ---------------------------------------------------------------------
// 6. Pedido #1042 da Ana (o exemplo dos slides): Fone BT + Webcam = 349,90
// ---------------------------------------------------------------------
MATCH (ana:Cliente {id: 0}), (fone:Produto {sku: 'AUD-001'}), (cam:Produto {sku: 'INF-001'})
CREATE (ped:Pedido {id: 1042, data: date('2026-11-01'), status: 'Entregue', pagamento: 'Pix'})
CREATE (ana)-[:COMPROU {em: date('2026-11-01')}]->(ped)
CREATE (ped)-[:CONTEM {quantidade: 1, precoUnitario: fone.preco}]->(fone)
CREATE (ped)-[:CONTEM {quantidade: 1, precoUnitario: cam.preco}]->(cam);


// ---------------------------------------------------------------------
// 7. 1.500 pedidos gerados, distribuídos entre os clientes
// ---------------------------------------------------------------------
UNWIND range(1, 1500) AS n
WITH n, date('2025-01-01') + duration({days: (n * 11) % 670}) AS dia
MATCH (c:Cliente {id: 1 + (n * 37) % 500})
CREATE (p:Pedido {
  id: 1100 + n,
  data: dia,
  status: CASE
    WHEN dia > date('2026-10-20') THEN ['Pago', 'Enviado'][n % 2]
    WHEN n % 17 = 0 THEN 'Cancelado'
    ELSE 'Entregue'
  END,
  pagamento: ['Pix', 'Cartão de crédito', 'Boleto', 'Cartão de débito'][n % 4]
})
CREATE (c)-[:COMPROU {em: dia}]->(p);

// Itens de cada pedido (de 1 a 4 produtos diferentes)
MATCH (pr:Produto)
WITH collect(pr) AS produtos
MATCH (p:Pedido) WHERE p.id >= 1101
UNWIND range(0, p.id % 4) AS k
WITH p, k, produtos[(p.id * 7 + k * 13) % size(produtos)] AS prod
CREATE (p)-[:CONTEM {quantidade: 1 + (p.id + k) % 3, precoUnitario: prod.preco}]->(prod);

// Total de cada pedido = soma dos itens
MATCH (p:Pedido)-[r:CONTEM]->(:Produto)
WITH p, sum(r.quantidade * r.precoUnitario) AS subtotal
SET p.total = round(subtotal * 100) / 100.0;

// Um em cada cinco pedidos usou cupom (o total recebe o desconto)
MATCH (cp:Cupom)
WITH collect(cp) AS cupons
MATCH (p:Pedido) WHERE p.id >= 1101 AND p.id % 5 = 0
WITH p, cupons[p.id % size(cupons)] AS cp
CREATE (p)-[:USOU_CUPOM]->(cp)
SET p.desconto = cp.desconto,
    p.total = round(p.total * (100 - cp.desconto)) / 100.0;


// ---------------------------------------------------------------------
// 8. Avaliações (só de pedidos entregues), com nota e comentário
// ---------------------------------------------------------------------
MATCH (c:Cliente)-[:COMPROU]->(p:Pedido {status: 'Entregue'})-[:CONTEM]->(prod:Produto)
WHERE (p.id + prod.estoque) % 3 = 0
WITH c, p, prod, [5, 5, 4, 4, 4, 3, 5, 2, 4, 1][(p.id + c.id) % 10] AS nota
MERGE (c)-[a:AVALIOU]->(prod)
SET a.nota = nota,
    a.data = p.data + duration({days: 7}),
    a.comentario = CASE nota
      WHEN 5 THEN 'Excelente, superou as expectativas.'
      WHEN 4 THEN 'Muito bom, recomendo.'
      WHEN 3 THEN 'Cumpre o que promete.'
      WHEN 2 THEN 'Abaixo do esperado.'
      ELSE 'Não recomendo.'
    END;

// Nota média e quantidade de avaliações guardadas em cada produto
MATCH (prod:Produto)<-[a:AVALIOU]-(:Cliente)
WITH prod, avg(a.nota) AS media, count(a) AS qtd
SET prod.notaMedia = round(media * 10) / 10.0,
    prod.qtdAvaliacoes = qtd;


// ---------------------------------------------------------------------
// 9. Rede de indicações entre clientes ("indique um amigo")
// ---------------------------------------------------------------------
MATCH (a:Cliente) WHERE a.id % 4 = 0
MATCH (b:Cliente {id: (a.id * 3 + 11) % 500 + 1})
WHERE a <> b
CREATE (a)-[:INDICOU]->(b);


// ---------------------------------------------------------------------
// 10. Conferência final
// ---------------------------------------------------------------------
MATCH (n)
RETURN labels(n)[0] AS tipo, count(*) AS quantidade
ORDER BY quantidade DESC;

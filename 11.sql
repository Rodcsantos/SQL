SELECT 
e.descricao as Quadra_Origem,
e.cod_composicao2 as Fila_Origem,
e.cod_composicao3 as Lastro_Origem,
e.cod_composicao4 as Altura_Origem,
e2.descricao as Quadra_destino,
e2.cod_composicao2 as Fila_Destino,
e2.cod_composicao3 as Lastro_Destino,
e2.cod_composicao4 as Altura_Destino,
tm.descricao  ,
me.data_hora ,
u.nome ,
c.numero as Container

FROM movimentacoes_estoques me
left join enderecos e on e.id = me.endereco_origem_id 
left join enderecos e2 on e2.id = me.endereco_destino_id 
left join tipo_movimentacoes tm on tm.id = me.tipo_movimentacao_id 
LEFT join usuarios u on u.id = me.usuario_conectado_id 
LEFT JOIN estoques e3 on e3.id = me.created_at_estoque 
LEFT JOIN unidade_medidas um on um.id = me.unidade_medida_anterior_id 
LEFT JOIN containers c on c.id = me.container_id 
WHERE c.numero IS NOT NULL 
AND (({{TEXT/Container}}) = '' OR (c.numero LIKE {{TEXT/Container}}))
order by me.data_hora desc
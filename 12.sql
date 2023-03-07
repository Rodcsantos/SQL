SELECT me.id 
,tm.descricao Tipo_Movimentacao
,me.data_hora
,me.quantidade_movimentada
,COALESCE(dm.numero_documento,'VAZIO') documento
,c.numero container
,u.nome usuario


FROM movimentacoes_estoques me
LEFT JOIN tipo_movimentacoes tm ON tm.id = me.tipo_movimentacao_id
LEFT JOIN containers c ON c.id = me.container_id
LEFT JOIN usuarios u ON u.id = me.usuario_conectado_id
LEFT JOIN documentos_mercadorias dm ON dm.lote_codigo = me.lote_codigo
WHERE (({{TEXT/container}}) = '' OR (c.numero LIKE {{TEXT/container}}))
AND (({{TEXT/Documento}}) = '' OR (dm.numero_documento LIKE {{TEXT/Documento}})) 
ORDER BY me.id DESC
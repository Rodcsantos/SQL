SELECT esc.id Entrada_Saida
,c.numero Container
,u.nome Usuario
,lt.create_at Data
,lt.valores Alteracoes

FROM ctl_wms.entrada_saida_containers esc 
, ctl_wms_logs.logs_tabelas lt 
, ctl_wms.usuarios u 
, ctl_wms.containers c

WHERE lt.tabela ='EntradaSaidaContainers'

AND lt.id_coluna=esc.id
AND u.id=lt.created_by
AND esc.container_id = c.id

AND (c.numero LIKE {{TEXT/Container}})
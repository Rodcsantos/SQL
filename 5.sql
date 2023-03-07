SELECT de.descricao
      ,u.nome
      ,lt.create_at
      ,lt.operacao
      ,lt.valores

FROM ctl_wms.drive_espacos de , ctl_wms_logs.logs_tabelas lt , ctl_wms.usuarios u 

WHERE lt.tabela ='DriveEspacos'

AND lt.id_coluna=de.id
AND u.id=lt.created_by

AND (de.descricao LIKE {{TEXT/Drive_reserva}})
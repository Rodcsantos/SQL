SELECT distinct a.id as 'resv',
      b.id as 'Agendamento',
      b.data_hora_programada as 'DATA_AGENDAMENTO',
     a.data_hora_chegada as 'CHEGADA',
      a.data_hora_entrada as 'GATE_IN',
      os.data_hora_fim as 'HORA_OS_FIM',
      a.data_hora_saida as 'GATE_OUT',
      UPPER (f.descricao) as 'operacao',
      d.veiculo_identificacao as 'veiculo',
      e.razao_social as 'transportadora',
      c.descricao as 'motorista',
      g.descricao as 'grade_horario',
      GROUP_CONCAT(DISTINCT 
      (case when ben.descricao IS NULL then bennn.descricao  else ben.descricao end)separator ' /&/ ') as 'Beneficiario',
      GROUP_CONCAT(DISTINCT (cont.numero) separator ' /&/ ') as 'numero',
      TIMEDIFF (a.data_hora_entrada,a.data_hora_chegada) AS 'Tempo Bolsão',
      TIMEDIFF (os.data_hora_fim,os.data_hora_inicio) AS 'Tempo Operação',
      TIMEDIFF (a.data_hora_saida,os.data_hora_fim) AS 'Tempo Diversos',
      TIMEDIFF (a.data_hora_saida,a.data_hora_chegada) AS 'Truck',  
      upper(CASE WHEN HOUR(a.data_hora_chegada) = 07 THEN 'Turno A'
      WHEN HOUR(a.data_hora_chegada) = 08 THEN 'Turno A'
      WHEN HOUR(a.data_hora_chegada) = 09 THEN 'Turno A'
      WHEN HOUR(a.data_hora_chegada) = 10 THEN 'Turno A'
      WHEN HOUR(a.data_hora_chegada) = 11 THEN 'Turno A'
      WHEN HOUR(a.data_hora_chegada) = 12 THEN 'Turno A'
      WHEN HOUR(a.data_hora_chegada) = 13 THEN 'Turno A'
      WHEN HOUR(a.data_hora_chegada) = 14 THEN 'Turno A'
      WHEN HOUR(a.data_hora_chegada) = 15 THEN 'Turno B'
      WHEN HOUR(a.data_hora_chegada) = 16 THEN 'Turno B' 
      WHEN HOUR(a.data_hora_chegada) = 17 THEN 'Turno B'
      WHEN HOUR(a.data_hora_chegada) = 18 THEN 'Turno B'
      WHEN HOUR(a.data_hora_chegada) = 19 THEN 'Turno B'
      WHEN HOUR(a.data_hora_chegada) = 20 THEN 'Turno B'
      WHEN HOUR(a.data_hora_chegada) = 21 THEN 'Turno B'
      WHEN HOUR(a.data_hora_chegada) = 22 THEN 'Turno B'
      ELSE 'Turno C' END) 'Turno',    
      a.observacao as 'Observação'
    
FROM  resvs a 
LEFT JOIN programacoes b on a.programacao_id=b.id
LEFT JOIN resvs_containers rc ON rc.resv_id = a.id
LEFT JOIN empresas bennn ON bennn.id = rc.beneficiario_id
LEFT JOIN containers cont ON cont.id = rc.container_id
LEFT JOIN pessoas c on c.id=a.pessoa_id
LEFT JOIN veiculos d on d.id=a.veiculo_id
LEFT JOIN transportadoras e on e.id=a.transportador_id
LEFT JOIN operacoes f on f.id=a.operacao_id
LEFT JOIN grade_horarios g on g.id=b.grade_horario_id
LEFT JOIN resvs_documentos_transportes h on h.resv_id=a.id
LEFT JOIN documentos_transportes i on i.id=h.documento_transporte_id
LEFT JOIN resvs_liberacoes_documentais j on j.resv_id=a.id
LEFT JOIN liberacoes_documentais k on k.id=j.liberacao_documental_id
LEFT JOIN documentos_mercadorias dm ON dm.documento_transporte_id = i.id and dm.peso_bruto
LEFT JOIN drive_espacos de ON de.id = rc.drive_espaco_id
LEFT JOIN empresas cli ON cli.id = de.cliente_id
LEFT JOIN empresas ben ON ben.id = de.beneficiario_id
LEFT JOIN empresas clii ON clii.id = dm.cliente_id
LEFT JOIN empresas benn ON benn.id = dm.beneficiario_id
LEFT JOIN vistorias v ON v.resv_id = a.id 
LEFT JOIN ordem_servicos os ON os.resv_id = a.id 
WHERE a.modal_id=2
AND a.data_hora_entrada > (NOW() - INTERVAL 60 DAY)
group by a.id
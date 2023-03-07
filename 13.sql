SELECT p.id programacao_id
, p.data_hora_programada
, p.data_hora_chegada
, r.data_hora_chegada chegada_bolsao
, r.data_hora_entrada
, r.data_hora_saida
, t.razao_social transportadora
, gh.descricao grade_horario
, GROUP_CONCAT(DISTINCT (c.numero) separator ' /-/ ') as container
, op.descricao operacao
, cli.descricao cliente
, amr.descricao as 'armador'
, ben.descricao beneficiario
, v.descricao veiculo
, pe.descricao motorista
, dt.numero documento
, dt.peso_bruto peso
, ps.descricao
,us.nome



  FROM programacoes p
  LEFT JOIN programacao_containers pc ON pc.programacao_id = p.id
  LEFT JOIN containers c ON pc.container_id = c.id
  left join usuarios us on us.id = p.created_by_log_at
  LEFT JOIN resvs r ON r.id = p.resv_id
  LEFT JOIN operacoes op ON op.id = p.operacao_id
  LEFT JOIN empresas cli ON cli.id = pc.cliente_id
  LEFT JOIN empresas ben ON ben.id = pc.beneficiario_id
  LEFT JOIN empresas amr on amr.id = c.armador_id
  LEFT JOIN transportadoras t ON t.id = p.transportadora_id
  LEFT JOIN veiculos v ON v.id = p.veiculo_id
  LEFT JOIN pessoas pe ON pe.id = p.pessoa_id
  LEFT JOIN grade_horarios gh ON gh.id = p.grade_horario_id
  LEFT JOIN programacao_situacoes ps on ps.id = p.programacao_situacao_id
  LEFT JOIN programacao_documento_transportes pdt ON pdt.programacao_id = p.id
  LEFT JOIN documentos_transportes dt ON dt.id = pdt.documento_transporte_id
  
  
 WHERE p.modal_id=2
  
    and (({{datepicker/data_inicio}} = '') or (convert(p.data_hora_programada,date) >= {{datepicker/data_inicio}}))
    and (({{datepicker/data_fim}} = '') or (convert(p.data_hora_programada,date) <= {{datepicker/data_fim}}))
    and (({{text/container}}) = '' or (c.numero like {{text/container}}))
    and (({{text/tipo}}) = '' or (cli.descricao like {{text/tipo}}))
GROUP BY p.id
ORDER BY r.data_hora_chegada asc
SELECT p.id programacao_id
, c.numero container
, op.descricao operacao
, p.data_hora_programada
, cli.descricao cliente
, ben.descricao beneficiario
, v.descricao veiculo
, t.razao_social transportadora
, pe.descricao motorista
, gh.descricao grade_horario
, dt.numero documento
, dt.peso_bruto peso


  FROM programacoes p
  LEFT JOIN programacao_containers pc ON pc.programacao_id = p.id
  LEFT JOIN containers c ON pc.container_id = c.id
  LEFT JOIN resvs r ON r.id = p.resv_id
  LEFT JOIN operacoes op ON op.id = p.operacao_id
  LEFT JOIN empresas cli ON cli.id = pc.cliente_id
  LEFT JOIN empresas ben ON ben.id = pc.beneficiario_id
  LEFT JOIN transportadoras t ON t.id = p.transportadora_id
  LEFT JOIN veiculos v ON v.id = p.veiculo_id
  LEFT JOIN pessoas pe ON pe.id = p.pessoa_id
  LEFT JOIN grade_horarios gh ON gh.id = p.grade_horario_id
  LEFT JOIN programacao_documento_transportes pdt ON pdt.programacao_id = p.id
  LEFT JOIN documentos_transportes dt ON dt.id = pdt.documento_transporte_id
  
 WHERE ( p.resv_id IS NULL OR r.data_hora_saida IS NULL )

 ORDER BY p.data_hora_programada desc
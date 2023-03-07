SELECT
     vi.codigo as Composição,
     UPPER (f.descricao) as Tipo_Operação,
     a.data_hora_chegada as Chegada_Trem,
    os.data_hora_fim Fim_Operacional,
      a.data_hora_saida as Saída_Trem,      
       UPPER (ben.descricao) AS Beneficiário,
      UPPER(case  when cli.descricao IS NULL THEN 'Container Vazio' else cli.descricao end) as 'Cliente',
      -- UPPER (cli.descricao) AS Cliente,     
      cont.numero as Container 
FROM  resvs a 
LEFT JOIN programacoes b on a.programacao_id=b.id
LEFT JOIN operacoes f on f.id=a.operacao_id
LEFT JOIN resvs_containers rc ON rc.resv_id = a.id
LEFT JOIN drive_espacos de ON de.id = rc.drive_espaco_id
LEFT JOIN empresas cli ON cli.id = de.cliente_id
LEFT JOIN empresas ben ON ben.id = de.beneficiario_id
LEFT JOIN containers cont ON cont.id = rc.container_id
left join viagens vi on vi.id=a.viagem_id
LEFT JOIN ordem_servicos os ON os.resv_id = a.id 
WHERE a.modal_id=4 
AND (({{TEXT/Tipo_Operação}}) = '' OR (f.descricao LIKE {{TEXT/Tipo_Operação}}))
AND (({{TEXT/Composição}}) = '' OR (vi.codigo LIKE {{TEXT/Composição}})) 
AND (({{TEXT/Container}}) = '' OR (cont.numero LIKE {{TEXT/Container}}))
AND (({{DATEPICKER/DATA_INÍCIO}} = '') OR (convert(a.data_hora_chegada,DATE) >= {{DATEPICKER/DATA_INÍCIO}}))
AND (({{DATEPICKER/DATA_FIM}} = '') OR (convert(a.data_hora_chegada,DATE) <= {{DATEPICKER/DATA_FIM}}))
order by a.data_hora_chegada desc
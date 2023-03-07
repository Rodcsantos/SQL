select  a.id,
     a.resv_codigo,
      
      case when f.id = 8 then GROUP_CONCAT(distinct cont.numero)
      ELSE cont.numero END AS 'Container',
      
      b.data_hora_programada,
      a.data_hora_chegada,
      -- a.data_hora_entrada,
      f.descricao as operacao,
      cli.descricao AS 'Cliente',
      ben.descricao AS 'Beneciario',
      d.veiculo_identificacao as veiculo,
      e.razao_social as transportadora,
      c.descricao as motorista,
      g.descricao as grade_horario,
      i.numero as doc_entrada,
      k.numero as doc_saida,
      dm.peso_bruto AS 'Peso',
      a.data_hora_entrada as 'gate_in',
      a.data_hora_saida as 'gate_out'
    --  '' as tempo_bolsao,    
    --  '' as truck_cycle,
    --  '' as Inicio_Coletor,
    --  '' as situacao

from  resvs a left join programacoes b on a.programacao_id=b.id
      left join pessoas c on c.id=a.pessoa_id
      left join veiculos d on d.id=a.veiculo_id
      left join transportadoras e on e.id=a.transportador_id
      left join operacoes f on f.id=a.operacao_id
      left join grade_horarios g on g.id=b.grade_horario_id
      left join resvs_documentos_transportes h on h.resv_id=a.id
      left join documentos_transportes i on i.id=h.documento_transporte_id
      left join resvs_liberacoes_documentais j on j.resv_id=a.id
      left join liberacoes_documentais k on k.id=j.liberacao_documental_id
    	LEFT JOIN resvs_containers rc ON rc.resv_id = a.id
    	LEFT JOIN drive_espacos de ON de.id = rc.drive_espaco_id
    	LEFT JOIN empresas cli ON cli.id = de.cliente_id
    	LEFT JOIN empresas ben ON ben.id = de.beneficiario_id
    	LEFT JOIN documentos_mercadorias dm ON dm.documento_transporte_id = i.id AND dm.peso_bruto IS NOT NULL
   	LEFT JOIN containers cont ON cont.id = rc.container_id
   
   where a.modal_id=2



   GROUP BY a.id
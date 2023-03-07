select
--  a.id,
      a.resv_codigo,   
      b.data_hora_programada,
      a.data_hora_chegada,
      a.data_hora_entrada,
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
      a.data_hora_entrada as gate_in,
      a.data_hora_saida as gate_out

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
        LEFT JOIN documentos_mercadorias dm ON dm.documento_transporte_id = i.id AND dm.peso_bruto IS NOT NULL
    	LEFT JOIN empresas cli ON cli.id = dm.cliente_id
    	LEFT JOIN empresas ben ON ben.id = dm.beneficiario_id
    	-- LEFT JOIN documentos_mercadorias dm ON dm.documento_transporte_id = i.id AND dm.peso_bruto IS NOT NULL
   	LEFT JOIN containers cont ON cont.id = rc.container_id
   
   where a.modal_id=2 and g.descricao LIKE '%SOLTA%'

and (({{DATETIMEPICKER/DATA_PROGRAMADA_INI}} = '') OR (

        DATE_FORMAT(b.data_hora_programada,CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i')) 
        >=
        DATE_FORMAT({{DATETIMEPICKER/DATA_PROGRAMADA_INI}}, CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i', ':00'))

    ))
    AND (({{DATETIMEPICKER/DATA_PROGRAMADA_FIM}} = '') OR (

        DATE_FORMAT(b.data_hora_programada,CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i')) 
         <=
        DATE_FORMAT({{DATETIMEPICKER/DATA_PROGRAMADA_FIM}}, CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i', ':00'))

    ))


    and (({{DATETIMEPICKER/DATA_CHEGADA_INI}} = '') OR (

        DATE_FORMAT( a.data_hora_chegada,CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i')) 
        >=
        DATE_FORMAT({{DATETIMEPICKER/DATA_CHEGADA_INI}}, CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i', ':00'))

    ))
    AND (({{DATETIMEPICKER/DATA_CHEGADA_FIM}} = '') OR (

        DATE_FORMAT( a.data_hora_chegada,CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i')) 
         <=
        DATE_FORMAT({{DATETIMEPICKER/DATA_CHEGADA_FIM}}, CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i', ':00'))

    ))

     
 AND  (({{TEXT/Operacao}}) = '' OR (f.descricao LIKE {{TEXT/Operacao}})) 

  
 AND  (({{TEXT/Transportadora}}) = '' OR ( e.razao_social LIKE {{TEXT/Transportadora}})) 
 
  AND  (({{TEXT/Cliente}}) = '' OR ( cli.descricao LIKE {{TEXT/Cliente}})) 
  
   AND  (({{TEXT/Beneficiario}}) = '' OR ( ben.descricao LIKE {{TEXT/Beneficiario}})) 

   GROUP BY a.id
   ORDER BY a.data_hora_chegada DESC
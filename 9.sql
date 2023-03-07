-- Descarga de carga solta

select a.id as os,
       b.descricao as tipo_servico,
       cast(a.data_hora_fim as date) as  data,
      DATE_FORMAT(a.data_hora_inicio,'%H:%i') as hora_inicio,
      DATE_FORMAT(a.data_hora_fim,'%H:%i') as hora_fim,
      f.descricao as cliente,
      g.descricao as beneficiario,
      e.numero_documento as nf,
      a.observacao
      
   

from ordem_servicos a join ordem_servico_tipos b on a.ordem_servico_tipo_id=b.id
                     and b.id = 1
                     join ordem_servico_itens c on c.ordem_servico_id=a.id
                        and c.container_id is null
                      join documentos_mercadorias_itens d on d.id=c.documento_mercadoria_item_id
                      join documentos_mercadorias e on e.id=d.documentos_mercadoria_id
                      join empresas f on f.id=e.cliente_id
                      left join empresas g on g.id=e.beneficiario_id

 where  (({{DATETIMEPICKER/DATA_INI}} = '') OR (

        DATE_FORMAT(a.data_hora_fim,CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i')) 
        >=
        DATE_FORMAT({{DATETIMEPICKER/DATA_INI}}, CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i', ':00'))

    ))
    AND (({{DATETIMEPICKER/DATA_FIM}} = '') OR (

        DATE_FORMAT(a.data_hora_fim,CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i')) 
         <=
        DATE_FORMAT({{DATETIMEPICKER/DATA_FIM}}, CONCAT(UPPER('%Y'), '-%m-%d', UPPER(' %H'), ':%i', ':00'))

    ))
    order by a.data_hora_fim DESC
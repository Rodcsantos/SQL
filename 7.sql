SELECT * FROM
(select 
os.id as 'ID_OS',
UPPER(case  when os.ordem_servico_tipo_id = 11 then 'OVA' else 'Desova' end) as 'Tipo_de_Operação',
UPPER(case when os.data_hora_fim is null then 'Pendente' else 'Realizado' end) as 'Status',
GROUP_CONCAT(DISTINCT (lt.numero) separator ' / ') as 'Documento',
-- GROUP_CONCAT(DISTINCT (osi.peso) separator ' / ') as 'PESO',
GROUP_CONCAT(DISTINCT (b.numero) separator ' / ') as 'Container',
f.sigla as 'Tipo_Iso',
UPPER (g.descricao) as 'Lacre',
case 
	        when (select concat(ex.descricao,'<br>',ex.cnpj)
				       from ordem_servicos os
			         join ordem_servico_itens osi on osi.ordem_servico_id = os.id
			         join ordem_servico_item_lote_estufados osile on osile.ordem_servico_id = os.id
			         join documentos_mercadorias dmx on dmx.lote_codigo = osile.lote_codigo
			         join empresas ex on ex.id = dmx.cliente_id
			        where os.ordem_servico_tipo_id = 11
			          and a.id = osi.entrada_saida_container_id
			          and a.container_id = osi.container_id
			        limit 1) is not null then
			        
	           (SELECT concat(ex.descricao,'<br>',ex.cnpj)
				     from ordem_servicos os
		         join ordem_servico_itens osi on osi.ordem_servico_id = os.id
		         join ordem_servico_item_lote_estufados osile on osile.ordem_servico_id = os.id
		         join documentos_mercadorias dmx on dmx.lote_codigo = osile.lote_codigo
		         join empresas ex on ex.id = dmx.cliente_id
		        where os.ordem_servico_tipo_id = 11
		          and a.id = osi.entrada_saida_container_id
		          and a.container_id = osi.container_id
		        limit 1)
	        else
	          concat(cli.descricao,'<br>',cli.cnpj)
	        end as cliente,
            h.descricao as 'Armador',
i.descricao as 'Reserva'   ,
os.created as 'Data criação OS', 
os.data_hora_inicio as 'Inicio_OS',
os.data_hora_fim as 'Fim_OS',
TIMEDIFF (os.data_hora_fim,os.data_hora_inicio) AS 'Tempo Opração'      
         
from entrada_saida_containers a  join containers b on b.id=a.container_id
     join resvs c on c.id=a.resv_entrada_id
     left join resvs d on d.id=a.resv_saida_id 
     join resvs_containers rc on rc.resv_id = c.id and rc.container_id = a.container_id
     join transportadoras e on e.id=c.transportador_id
     join tipo_isos f on f.id=b.tipo_iso_id
     left join lacres g on g.entrada_saida_container_id=a.id
     left  join empresas h on h.id=b.armador_id
     left  join empresas cli on cli.id=a.cliente_id
     LEFT JOIN drive_espaco_containers dc ON dc.container_id=b.id
     left join drive_espacos i on dc.drive_espaco_id=i.id
     left join empresas em on em.id=i.cliente_id
    left join container_entradas j on j.container_id=a.container_id and a.id = j.entrada_saida_container_id
     left join resvs_documentos_transportes k on k.resv_id=a.resv_entrada_id
         and k.documento_transporte_id=j.documento_transporte_id
     left join documentos_transportes lt on lt.id=j.documento_transporte_id
     
     #left join documentos_mercadorias dm on (dm.documento_transporte_id=l.id and dm.documento_mercadoria_id_master is not null)
     #left join empresas cli on cli.id=dm.cliente_id
     
     join ordem_servico_itens osi on osi.entrada_saida_container_id=a.id
     join ordem_servicos os on os.id=osi.ordem_servico_id and os.ordem_servico_tipo_id
     where os.ordem_servico_tipo_id = 11 or os.ordem_servico_tipo_id = 12
     group by os.id
     order by os.created DESC)
     relatorio
     where (({{text/Container}}) = '' or (relatorio.Container like {{text/Container}}))
	   and (({{text/Cliente}}) = '' or (relatorio.Cliente like {{text/Cliente}}))	
	   and (({{datepicker/data_inicio}} = '') or (convert(relatorio.Inicio_OS,date) >= {{datepicker/data_inicio}}))
	   and (({{datepicker/data_fim}} = '') or (convert(relatorio.Fim_OS,date) <= {{datepicker/data_fim}}))
	select * from 
	  	 (select distinct concat ('2021',substring(c.resv_codigo,10,11)) as 'resv de entrada',
	  	 c.programacao_id AS 'Agendamento Entrada',
	    -- concat('2021',substring(d.resv_codigo,10,11)) as 'resv de saida' ,
	       -- d.programacao_id AS 'Agendamento Saida',
	      case when  rc.tipo = 'vazio' then '' else lt.numero  end 'Documento',
	      case  
	          when a.data_hora_entrada_importacao is not null then
			  a.data_hora_entrada_importacao
	          else
			c.data_hora_entrada
	      end as data_entrada,
	      DATEDIFF(d.data_hora_saida,c.data_hora_saida) AS 'Dias de Armazenagem',
	      b.numero as 'container',
	      cfu.descricao as 'forma de uso',
	      f.sigla as 'tipo iso',
	      b.tara as 'tara',
	      b.mgw as 'mgw',     
	      case when g.descricao is not null then g.descricao 
	        else
			(select group_concat(l.descricao separator ', ')
			 from lacres l 
			 join container_entradas ce 
			 on ce.documento_transporte_id = l.documento_transporte_id 
			 and l.container_id = ce.container_id
			 join resvs_documentos_transportes rdt
			 where l.container_id = a.container_id
			 and rdt.documento_transporte_id = ce.documento_transporte_id
			 and rdt.resv_id = a.resv_entrada_id
			 ) end as 'lacre',
	
	      e.razao_social as  'transportadora',
	      rc.tipo as nat_desc,
	
	      case 
	        when rc.tipo = 'vazio' then 
	          ( SELECT CONCAT (z.descricao,'<br>',z.cnpj) 
	              from resvs_containers x 
	              join empresas z on x.cliente_id=z.id
	             where x.resv_id=a.resv_entrada_id and x.container_id=a.container_id
	             limit 1)
	        else
	         (    SELECT CONCAT( emp_cli.descricao,'<br>',emp_cli.cnpj)
	              from container_entradas ce
	              join documentos_transportes dt on dt.id = ce.documento_transporte_id
	              join documentos_mercadorias dm on dm.documento_transporte_id = dt.id and dm.documento_mercadoria_id_master is not null
	              join empresas emp_cli on emp_cli.id = dm.cliente_id
	             where ce.entrada_saida_container_id = a.id
	             LIMIT 1 )  
	      END 
	       as cliente,
	        		
	       h.descricao as armador,
	       i.descricao as reserva ,
	       '' as 'data desova',
	       cd.descricao as destino
	        
	from entrada_saida_containers a
	    join containers b on b.id=a.container_id
	     join resvs c on c.id=a.resv_entrada_id
	     join resvs_containers rc on rc.resv_id = c.id and rc.container_id = a.container_id
	     left join resvs d on d.id=a.resv_saida_id 
	     join transportadoras e on e.id=c.transportador_id
	     join tipo_isos f on f.id=b.tipo_iso_id
	     left join lacres g on g.container_id=b.id and g.entrada_saida_container_id=a.id
	     left  join empresas h on h.id=b.armador_id
	     left join drive_espacos i on i.id=rc.drive_espaco_id
	     left join container_forma_usos cfu on cfu.id = rc.container_forma_uso_id
	     left join container_destinos cd on cd.id=a.container_destino_id 
	  	  left join container_entradas j on j.container_id=a.container_id and a.id = j.entrada_saida_container_id
	     left join resvs_documentos_transportes k on k.resv_id=a.resv_entrada_id and k.documento_transporte_id=j.documento_transporte_id
	     left join documentos_transportes lt on lt.id=j.documento_transporte_id
	
	where (({{text/transportador}}) = '' or (e.razao_social like {{text/transportador}})) 
	  and (({{text/container}}) = '' or (b.numero like {{text/container}}))
	  and (({{text/tipo}}) = '' or (rc.tipo like {{text/tipo}}))
	  
	    order by c.id
		) relatorio
		where 
	
	(({{datepicker/data_inicio}} = '') or (convert(relatorio.data_entrada,date) >= {{datepicker/data_inicio}}))
	and (({{datepicker/data_fim}} = '') or (convert(relatorio.data_entrada,date) <= {{datepicker/data_fim}}))

	union all
	
	  -- ova
SELECT * FROM
( select 
'' as resv_entrada,
'' AS 'Agendamento Entrada',
lt.numero as 'Documento',
os.data_hora_inicio as data_entrada,
	        '' AS 'Dias de Armazenagem',
	        b.numero as 'container',
	        '' as 'forma de uso',
	       f.sigla as 'tipo iso',
			
	       b.tara as 'tara',
	       b.mgw as 'mgw',
	       g.descricao as 'lacre',
	       '' as  'transportadora',
		   (case  when os.ordem_servico_tipo_id = 11 then 'OVA'
		   when os.ordem_servico_tipo_id = 12 then 'DESOVA' else 'Verificar' end) as status,
		   
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
	        
	        h.descricao as armador,
	       i.descricao as reserva   ,
		   '-' as datadesova,
	       'armazém' as  destino
         
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
     ova
	


order by data_entrada
			
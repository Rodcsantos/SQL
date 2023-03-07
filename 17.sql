select 
	      case  
	          when a.data_hora_entrada_importacao is not null then
			  a.data_hora_entrada_importacao
	          else
			c.data_hora_entrada
	      end as data_entrada,
	      b.numero as 'container',
	      cfu.descricao as 'forma de uso',
	      f.sigla as 'tipo iso',
	      b.tara as 'tara',
	      b.mgw as 'mgw',     
	      rc.tipo as nat_desc,
	
	      case 
	        when rc.tipo = 'vazio' then 
	          ( SELECT CONCAT (z.descricao,'<br>',z.cnpj) 
	              from resvs_containers x 
	              join empresas z on x.cliente_id=z.id
	             where x.resv_id=a.resv_entrada_id and x.container_id=a.container_id and z.descricao not like '%toyota%'
	             limit 1)
	        else
	         (    SELECT CONCAT( emp_cli.descricao,'<br>',emp_cli.cnpj)
	              from container_entradas ce
	              join documentos_transportes dt on dt.id = ce.documento_transporte_id
	              join documentos_mercadorias dm on dm.documento_transporte_id = dt.id and dm.documento_mercadoria_id_master is not null
	              join empresas emp_cli on emp_cli.id = dm.cliente_id
	             where ce.entrada_saida_container_id = a.id and emp_cli.descricao not like '%toyota%'
	             LIMIT 1 ) END as cliente, 		
	       h.descricao as armador,
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
	
	    where DATE(c.data_hora_entrada) = SUBDATE(CURDATE(), 1) 
		AND cd.descricao LIKE 'depot' and h.id = 2826

		
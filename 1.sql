SELECT c.numero as cnt_id,
       ct.tamanho as CNT_tipo,
       i.sigla sigla_tiso,
       format(c.mgw,3,'de_de') mgw,
       i.descricao tiso_descricao,
       format(c.tara,3,'de_de') tara,
       e.id resv_id,
	   
       
       case 
	    when b.data_hora_desova_importacao is not null then
		  date_format(b.data_hora_desova_importacao, concat( '%d/%m/', upper('%y'), upper(' %h'), ':%i'))
       	when (SELECT max(pdc.created_at)
			 		  FROM plano_desova_containers pdc
					 WHERE pdc.container_id = a.container_id 
					  LIMIT 1) > e.data_hora_entrada then
				(SELECT date_format(max(pdc.created_at), concat( '%d/%m/', upper('%y'), upper(' %h'), ':%i'))
			 		  FROM plano_desova_containers pdc
					 WHERE pdc.container_id = a.container_id 
					  LIMIT 1)
			ELSE null
		end mcnt_dt_desova,

      case 
	  	when b.data_hora_entrada_importacao is not null then 
		  date_format(b.data_hora_entrada_importacao, concat( '%d/%m/', upper('%y'), upper(' %h'), ':%i'))
		else 
		  date_format(e.data_hora_entrada, concat( '%d/%m/', upper('%y'), upper(' %h'), ':%i'))
	  end
	   as resv_dt_entrada,
      
	  case 
	  	when b.data_hora_entrada_importacao is not null then 
		  datediff(now(), b.data_hora_entrada_importacao)
		else 
		  datediff(now(), e.data_hora_entrada)
	  end
	   as dias_armazenagem,
      
      format(d.peso_bruto,3,'de_de') peso_bruto,
      
      (SELECT GROUP_CONCAT( l.descricao SEPARATOR ', ')
		  FROM lacres l
		  WHERE l.documento_transporte_id = d.documento_transporte_id
		    AND l.container_id = a.container_id ) lac_numero,
          
	  (SELECT max(emp1.descricao)
		  FROM documentos_mercadorias dm1
		  join estoques e1 on e1.lote_codigo = dm1.lote_codigo
		  join empresas emp1 on emp1.id = dm1.cliente_id
		  WHERE b.container_id = e1.container_id 
		  ) as cliente_documento,
      
	  #f.descricao as cliente_documento,
      
      cnt_arm.descricao as ARMADOR,
      
      case 
      	when a.unidade_medida_id = 22 AND a.produto_id IS NULL then 
      	  'VAZIO'
      	ELSE 
      	  'CHEIO'
     	end AS "STATUS",
		   
      dm_benef.descricao as beneficiario_documento,
   
      case 
	 		 when b.drive_espaco_atual_id IS NOT NULL then
			  de_atual.descricao
      		when b.drive_espaco_saida_id IS NOT NULL then
			  de_saida.descricao
			when b.drive_espaco_id IS NOT NULL then
			  de_entrada.descricao
			ELSE '-'      	  
      end as res_numero,
      
      case 
			when b.drive_espaco_atual_id IS NOT NULL then
			  benef_de_atual.descricao
      	when b.drive_espaco_saida_id IS NOT NULL then
			  benef_de_entrada.descricao
			when b.drive_espaco_id IS NOT NULL then
			  benef_de_saida.descricao
			ELSE benef_de_atual2.descricao     	  
      end as bnef_reserva,
      
      case 
			when b.drive_espaco_atual_id IS NOT NULL then
			  cliente_de_atual.descricao
      	when b.drive_espaco_saida_id IS NOT NULL then
			  cliente_de_entrada.descricao
			when b.drive_espaco_id IS NOT NULL then
			  cliente_de_saida.descricao
			ELSE cli_cnt.descricao     	  
      end as cliente_reserva,
      
      case 
      	when b.drive_espaco_saida_id IS NOT NULL then
			  de_saida.data_hora_ddl
			when b.drive_espaco_atual_id IS NOT NULL then
			  de_atual.data_hora_ddl
			when b.drive_espaco_id IS NOT NULL then
			  de_entrada.data_hora_ddl
			ELSE '-'      	  
      end as res_ddl,
      
      case 
      	when b.drive_espaco_saida_id IS NOT NULL then
			  de_saida.data_hora_validade
			when b.drive_espaco_atual_id IS NOT NULL then
			  de_atual.data_hora_validade
			when b.drive_espaco_id IS NOT NULL then
			  de_entrada.data_hora_validade
			ELSE '-'      	  
      end as res_validade,

      UPPER(case 
      	when b.drive_espaco_saida_id IS NOT NULL then
			  detc_saida.descricao
			when b.drive_espaco_atual_id IS NOT NULL then
			  detc_atual.descricao
			when b.drive_espaco_id IS NOT NULL then
			  detc_entrada.descricao
			  when e.modal_id = 4 AND vei.descricao like 'S%' then 'SUBIDA'
			ELSE '' end) as res_tipo_carga,
	        
      j.descricao as classificacao_container,
      
       (SELECT GROUP_CONCAT( ar.descricao SEPARATOR ', ')
			FROM entrada_saida_container_vistorias escv
			JOIN vistorias visto ON escv.vistoria_id = visto.id
			JOIN vistoria_itens vi ON vi.vistoria_id = visto.id
			JOIN vistoria_avarias va ON va.vistoria_item_id = vi.id
			JOIN vistoria_avaria_respostas var ON var.vistoria_avaria_id = va.vistoria_item_id
			JOIN avaria_respostas ar ON ar.id = var.avaria_resposta_id
		  WHERE escv.entrada_saida_container_id = b.id
		  	 AND vi.container_id = a.container_id
		   ) AS 'Avarias',
		   
        ifnull ((select distinct 'Armazem'
           from ordem_servico_itens osi join ordem_servicos os on os.id=osi.ordem_servico_id
            where os.ordem_servico_tipo_id=11 and os.data_hora_fim is null
                and osi.container_id=b.container_id),
		case 
      	when a.unidade_medida_id = 22 AND a.produto_id IS NULL then 
      	  cd.descricao
      	ELSE 
      	  'Terminal'
     	end ) destino,
		 
		   de_atual.referencia,
		   de_atual.observacao,
		   sc.descricao as situacao_container,


       -- concat(te.composicao1 , ' - ' , ende.cod_composicao1 ) as QUADRA,
       upper(case when ende.cod_composicao1 = '1' then 'A'
	   when ende.cod_composicao1 = '2' then 'B'
	   when ende.cod_composicao1 = '3' then 'C'
	   when ende.cod_composicao1 = '4' then 'D'
	   when ende.cod_composicao1 = '5' then 'E'
	   when ende.cod_composicao1 = '6' then 'F'
	   when ende.cod_composicao1 = '7' then 'G'
	   when ende.cod_composicao1 = '8' then 'H'
	   when ende.cod_composicao1 = '9' then 'I'
	   when ende.cod_composicao1 = '10' then 'J'
	   when ende.cod_composicao1 = '11' then 'K'
	   when ende.cod_composicao1 = '12' then 'L'
	   when ende.cod_composicao1 = '13' then 'M'
	   when ende.cod_composicao1 = '14' then 'N'
	   when ende.cod_composicao1 = '15' then 'O'
	   when ende.cod_composicao1 = '16' then 'P'
	   when ende.cod_composicao1 = '17' then 'Q'
	   when ende.cod_composicao1 = '18' then 'R'
	   when ende.cod_composicao1 = '19' then 'S'
	   when ende.cod_composicao1 = '20' then 'T'
	   when ende.cod_composicao1 = '21' then 'U'
	   when ende.cod_composicao1 = '22' then 'V'
	   when ende.cod_composicao1 = '23' then 'W'
	   when ende.cod_composicao1 = '24' then 'X'
	   when ende.cod_composicao1 = '25' then 'Y'
	   when ende.cod_composicao1 = '26' then 'Z'
	   ELSE 'X9'END) as QUADRA,
	   -- ende.cod_composicao1 as QUADRA,
       -- concat(te.composicao2 , ' - ' , ende.cod_composicao2 )  as FILA,
	   ende.cod_composicao2 as FILA,
       -- concat(te.composicao3 , ' - ' , ende.cod_composicao3 ) as LASTRO,
	   ende.cod_composicao3 as LASTRO,
       -- concat(te.composicao4 , ' - ' ,ende.cod_composicao4 ) as NIVEL
	   ende.cod_composicao4 as ALTURA
       
from estoques a 
   left join entrada_saida_containers b on a.container_id=b.container_id
   left join containers c on c.id=a.container_id
   left join documentos_mercadorias d on d.lote_codigo=a.lote_codigo
   left join resvs e on e.id=b.resv_entrada_id
   left join veiculos vei on vei.id=e.veiculo_id
   
   
   left join resvs_containers g ON (g.resv_id=b.resv_entrada_id and g.container_id=c.id)
   left join empresas cli_cnt on cli_cnt.id=b.cliente_id
   
   left join drive_espacos de_entrada on de_entrada.id = b.drive_espaco_id
   left join drive_espacos de_atual   on de_atual.id     = b.drive_espaco_atual_id
   left join drive_espacos de_saida   on de_saida.id     = b.drive_espaco_saida_id

   left join drive_espaco_tipo_cargas detc_entrada on detc_entrada.id = de_entrada.drive_espaco_tipo_carga_id
   left join drive_espaco_tipo_cargas detc_atual   on detc_atual.id   = de_atual.drive_espaco_tipo_carga_id
   left join drive_espaco_tipo_cargas detc_saida   on detc_saida.id   = de_saida.drive_espaco_tipo_carga_id
   
   left join empresas benef_de_entrada on benef_de_entrada.id = de_entrada.beneficiario_id
   left join empresas benef_de_atual   on benef_de_atual.id = de_atual.beneficiario_id
   left join empresas benef_de_saida   on benef_de_saida.id = de_saida.beneficiario_id
   left join empresas benef_de_atual2 on benef_de_atual2.id = b.beneficiario_id
      
   left join empresas cliente_de_entrada on cliente_de_entrada.id = de_entrada.cliente_id
   left join empresas cliente_de_atual   on cliente_de_atual.id = de_atual.cliente_id
   left join empresas cliente_de_saida   on cliente_de_saida.id = de_saida.cliente_id
   
   left join empresas f on f.id = d.cliente_id
   left join empresas dm_benef on dm_benef.id = d.beneficiario_id
   left join empresas cnt_arm on cnt_arm.id = c.armador_id
   
   left join tipo_isos i on i.id=c.tipo_iso_id
   LEFT JOIN container_tamanhos ct ON ct.id = i.container_tamanho_id
   left join container_forma_usos j on j.id=b.container_forma_uso_id
    
   left join container_destinos cd on cd.id=b.container_destino_id 

   left join situacao_containers sc on sc.id=b.situacao_container_id


   left join estoque_enderecos  estend on estend.estoque_id=a.id
   left join enderecos ende on ende.id=estend.endereco_id
    left join areas area on area.id=ende.area_id
     left join tipo_estruturas te on te.id=area.tipo_estrutura_id
   
   
   
 where a.container_id IS NOT NULL AND b.resv_saida_id IS NULL
 
 
 GROUP BY a.container_id



 ORDER BY a.created_at desc
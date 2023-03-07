SELECT c.numero as cnt_id,
       ct.tamanho as CNT_tipo,
       i.sigla sigla_tiso,
       format(c.mgw,3,'de_de') mgw,
       i.descricao tiso_descricao,
       format(c.tara,3,'de_de') tara,
    
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
      
      cnt_arm.descricao as ARMADOR,
      
      case when a.unidade_medida_id = 22 AND a.produto_id IS NULL then 'VAZIO' ELSE null end AS 'Status',
  
      j.descricao as classificacao_container,
      ifnull ((select distinct 'Armazem'
           from ordem_servico_itens osi join ordem_servicos os on os.id=osi.ordem_servico_id
            where os.ordem_servico_tipo_id=11 and os.data_hora_fim is null
                and osi.container_id=b.container_id not like '%armazem%' ),
		case 
      	when a.unidade_medida_id = 22 AND a.produto_id IS NULL then 
      	  cd.descricao
      	ELSE 
      	  'Terminal'
     	end ) as 'Destino'
            
from estoques a 
   left join entrada_saida_containers b on a.container_id=b.container_id
   left join containers c on c.id=a.container_id
   left join documentos_mercadorias d on d.lote_codigo=a.lote_codigo
   left join resvs e on e.id=b.resv_entrada_id

   
   
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
 AND cnt_arm.id = 2826 and cd.descricao = 'Depot'
 and a.unidade_medida_id = 22 AND a.produto_id IS NULL
 

 GROUP BY a.container_id



 ORDER BY a.created_at desc
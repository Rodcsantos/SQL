select   distinct  b.numero as 'Container',
             
     date_format(d.data_hora_saida, concat( '%d/%m/', upper('%y'), upper(' %h'), ':%i')) as 'Data_Saida',   
    	f.sigla as 'Tipo Iso',
      j.tamanho as tipo, 
      b.tara as 'Tara',
      b.mgw as 'NGW',  
      rc.tipo as status, 
      
      case 
        when rc.tipo = 'VAZIO' then 
          ( SELECT concat(z.descricao,'<br>',z.cnpj) 
              from empresas z
             where z.id = rc.cliente_id
             limit 1
          )
        else
         (
            SELECT concat(emp_cli.descricao,'<br>',emp_cli.cnpj)
              from container_entradas ce
              join documentos_transportes dt on dt.id = ce.documento_transporte_id
              join documentos_mercadorias dm on dm.documento_transporte_id = dt.id and dm.documento_mercadoria_id_master is not null
              join empresas emp_cli on emp_cli.id = dm.cliente_id
             where ce.entrada_saida_container_id = a.id
             limit 1
         )  
      end
       as cliente,
      h.descricao as armador,
      i.descricao as reserva ,

     -- i.referencia as referencia,
 
     -- emp_benef.descricao as  beneficiario, 

      k.descricao as modal,

    cd.descricao as destino
           
        
from entrada_saida_containers a  join containers b on b.id=a.container_id
     join resvs c on c.id=a.resv_entrada_id
      join resvs d on d.id=a.resv_saida_id 
     join resvs_containers rc on rc.resv_id = d.id and rc.container_id = a.container_id
     join transportadoras e on e.id=d.transportador_id
     join tipo_isos f on f.id=b.tipo_iso_id
     left  join empresas h on h.id=b.armador_id
     LEFT JOIN lacres g ON g.container_id = b.id AND g.entrada_saida_container_id = a.id
     LEFT JOIN empresas cli ON cli.id = rc.cliente_id
     left join drive_espacos i on i.id=a.drive_espaco_atual_id
     left join empresas emp_benef on emp_benef.id = i.beneficiario_id
     left join container_tamanhos j on j.id=f.container_tamanho_id
     left join modais k on k.id=d.modal_id
    left join container_destinos cd on cd.id=a.container_destino_id
     left join container_entradas ce on ce.container_id=a.container_id AND a.id = ce.entrada_saida_container_id
     LEFT JOIN documentos_transportes dt ON dt.id = g.documento_transporte_id
     left join container_forma_usos cfu on cfu.id=a.container_forma_uso_id
     
     where d.data_hora_saida IS NOT NULL 
     AND cd.descricao LIKE 'depot' and h.id = 2826
     and rc.tipo = 'VAZIO'
	 AND DATE(d.data_hora_saida) = SUBDATE(CURDATE(), 1)
     
	    